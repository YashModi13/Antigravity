package com.mms.backend.service;

import com.mms.backend.dto.CreateDepositRequest;
import com.mms.backend.dto.DepositItemRequest;
import com.mms.backend.dto.RedemptionRequest;
import com.mms.backend.dto.UpdateDepositRequest;
import com.mms.backend.entity.*;
import com.mms.backend.repository.*;
import static com.mms.backend.util.Constants.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.NoSuchElementException;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DepositService {

    private final CustomerDepositEntryRepository depositRepository;
    private final CustomerDepositItemsRepository itemsRepository;
    private final CustomerDepositTransactionRepository transactionRepository;
    private final CustomerMasterRepository customerRepository;
    private final ItemMasterRepository itemRepository;
    private final UnitMasterRepository unitRepository;
    private final MerchantItemEntryRepository merchantEntryRepository;

    public boolean isTokenExists(Integer tokenNo) {
        return depositRepository.existsByTokenNo(tokenNo);
    }

    public Integer generateNextToken() {
        Integer maxToken = depositRepository.findMaxTokenNo();
        return (maxToken == null) ? 1 : maxToken + 1;
    }

    @Transactional
    public void createDeposit(CreateDepositRequest request) {
        log.info("[DepositService] Creating Deposit. Token: {}, CustomerID: {}", request.getTokenNo(),
                request.getCustomerId());
        // 1. Create Entry
        CustomerDepositEntry entry = new CustomerDepositEntry();
        entry.setCustomer(customerRepository.findById(Objects.requireNonNull(request.getCustomerId()))
                .orElseThrow(() -> new IllegalArgumentException("Customer not found")));
        entry.setDepositDate(request.getDepositDate());
        entry.setTotalInterestRate(request.getInterestRate());
        entry.setNotes(request.getNotes());
        entry.setTokenNo(request.getTokenNo());
        entry.setEntryStatus(STATUS_ACTIVE);
        entry.setCreatedDate(LocalDateTime.now());
        entry = depositRepository.save(entry);

        // 2. Create Items
        if (request.getItems() != null) {
            for (var itemReq : request.getItems()) {
                createItemForDeposit(entry, itemReq);
            }
        }

        // 3. Create Transaction (Initial Loan)
        if (request.getInitialLoanAmount() != null && request.getInitialLoanAmount().compareTo(BigDecimal.ZERO) > 0) {
            createTransaction(entry, TX_INITIAL_MONEY, request.getInitialLoanAmount(), request.getDepositDate());
        }
    }

    private void createItemForDeposit(CustomerDepositEntry entry, DepositItemRequest itemReq) {
        CustomerDepositItems item = new CustomerDepositItems();
        item.setDepositEntry(entry);
        item.setItem(itemRepository.findById(Objects.requireNonNull(itemReq.getItemId()))
                .orElseThrow(() -> new IllegalArgumentException("Item not found")));
        item.setItemDate(entry.getDepositDate());
        item.setWeightReceived(itemReq.getWeight());
        item.setWeightUnit(unitRepository.findById(Objects.requireNonNull(itemReq.getUnitId()))
                .orElseThrow(() -> new IllegalArgumentException("Unit not found")));
        item.setFineWeight(itemReq.getFineWeight());
        item.setItemDescription(itemReq.getDescription());
        item.setCreatedDate(LocalDateTime.now());
        item.setItemStatus(STATUS_ACTIVE);
        itemsRepository.save(item);
    }

    private void createTransaction(CustomerDepositEntry entry, String type, BigDecimal amount, LocalDate date) {
        CustomerDepositTransaction tx = new CustomerDepositTransaction();
        tx.setDepositEntry(entry);
        tx.setTransactionType(type);
        tx.setAmount(amount);
        tx.setTransactionDate(date);
        tx.setCreatedDate(LocalDateTime.now());
        transactionRepository.save(tx);
    }

    @Transactional
    public void updateDeposit(Integer id, UpdateDepositRequest request) {
        log.info("[DepositService] Updating Deposit. ID: {}", id);
        CustomerDepositEntry entry = depositRepository.findById(Objects.requireNonNull(id))
                .orElseThrow(() -> new NoSuchElementException("Deposit not found with ID: " + id));

        updateDepositDetails(entry, request);
        depositRepository.save(Objects.requireNonNull(entry));

        if (request.getDepositDate() != null) {
            propagateDepositDateUpdate(entry.getId(), request.getDepositDate());
        }

        if (request.getInitialLoanAmount() != null) {
            updateInitialLoanAmount(entry.getId(), request.getInitialLoanAmount());
        }

        if (request.getItems() != null) {
            updateDepositItems(entry, request.getItems());
        }
    }

    private void updateDepositDetails(CustomerDepositEntry entry, UpdateDepositRequest request) {
        if (request.getDepositDate() != null) {
            entry.setDepositDate(request.getDepositDate());
        }
        if (request.getInterestRate() != null) {
            entry.setTotalInterestRate(request.getInterestRate());
        }
        if (request.getTokenNo() != null) {
            entry.setTokenNo(request.getTokenNo());
        }
        if (request.getNotes() != null) {
            entry.setNotes(request.getNotes());
        }
    }

    private void propagateDepositDateUpdate(Integer depositId, LocalDate newDate) {
        // Cascade update to Items
        List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(depositId);
        for (CustomerDepositItems item : items) {
            item.setItemDate(newDate);
            itemsRepository.save(item);
        }
        // Cascade update to Initial Transaction
        List<CustomerDepositTransaction> txs = transactionRepository.findByDepositEntry_Id(depositId);
        for (CustomerDepositTransaction tx : txs) {
            if (TX_INITIAL_MONEY.equals(tx.getTransactionType())) {
                tx.setTransactionDate(newDate);
                transactionRepository.save(tx);
            }
        }
    }

    private void updateInitialLoanAmount(Integer depositId, BigDecimal newAmount) {
        transactionRepository.findByDepositEntry_Id(depositId).stream()
                .filter(t -> TX_INITIAL_MONEY.equals(t.getTransactionType()))
                .findFirst()
                .ifPresent(tx -> {
                    tx.setAmount(newAmount);
                    transactionRepository.save(tx);
                });
    }

    private void updateDepositItems(CustomerDepositEntry entry, List<DepositItemRequest> requestItems) {
        List<CustomerDepositItems> existingItems = itemsRepository.findByDepositEntry_Id(entry.getId());
        List<CustomerDepositItems> itemsToKeep = new ArrayList<>();
        List<DepositItemRequest> itemsToCreate = new ArrayList<>(requestItems); // Mutable copy

        // Identify Pledged Items to prevent their deletion
        List<MerchantItemEntry> activePledges = merchantEntryRepository
                .findActiveByDepositId(Long.valueOf(entry.getId()));
        Set<Integer> pledgedItemIds = activePledges.stream()
                .map(p -> p.getCustomerDepositItem().getId())
                .collect(Collectors.toSet());

        for (CustomerDepositItems existing : existingItems) {
            int matchIndex = findMatchingItemIndex(existing, itemsToCreate);

            if (matchIndex != -1) {
                // Keep Existing
                DepositItemRequest req = itemsToCreate.get(matchIndex);
                existing.setItemDescription(req.getDescription());
                itemsRepository.save(existing);
                itemsToKeep.add(existing);
                itemsToCreate.remove(matchIndex);
            } else {
                // Check if pledged before deleting
                if (pledgedItemIds.contains(existing.getId())) {
                    throw new IllegalStateException("Cannot modify/remove Item '" + existing.getItemDescription()
                            + "' because it is currently pledged.");
                }
            }
        }

        // Delete items NOT in itemsToKeep
        existingItems.removeAll(itemsToKeep);
        if (!existingItems.isEmpty()) {
            itemsRepository.deleteAll(existingItems);
        }

        // Create remaining new items
        for (DepositItemRequest itemReq : itemsToCreate) {
            createItemForDeposit(entry, itemReq);
        }
    }

    private int findMatchingItemIndex(CustomerDepositItems existing, List<DepositItemRequest> itemsToCreate) {
        for (int i = 0; i < itemsToCreate.size(); i++) {
            DepositItemRequest req = itemsToCreate.get(i);
            boolean sameItem = req.getItemId().equals(existing.getItem().getId());
            int reqUnitId = req.getUnitId() != null ? req.getUnitId() : 1;
            boolean sameUnit = (existing.getWeightUnit() != null) && (existing.getWeightUnit().getId() == reqUnitId);
            boolean sameWeight = req.getWeight().compareTo(existing.getWeightReceived()) == 0;
            boolean sameFine = req.getFineWeight().compareTo(existing.getFineWeight()) == 0;

            if (sameItem && sameUnit && sameWeight && sameFine) {
                return i;
            }
        }
        return -1;
    }

    @Transactional
    public void addPaymentTransaction(Integer depositId, RedemptionRequest request) {
        log.info("[DepositService] Adding Payment Transaction. Deposit ID: {}", depositId);
        CustomerDepositEntry entry = depositRepository.findById(Objects.requireNonNull(depositId))
                .orElseThrow(() -> new NoSuchElementException("Deposit not found"));

        if (request.getPrincipalPaid() != null && request.getPrincipalPaid().compareTo(BigDecimal.ZERO) > 0) {
            createTransaction(entry, TX_PRINCIPAL_PAYMENT, request.getPrincipalPaid(), LocalDate.now());
        }

        if (request.getInterestPaid() != null && request.getInterestPaid().compareTo(BigDecimal.ZERO) > 0) {
            createTransaction(entry, TX_INTEREST_PAYMENT, request.getInterestPaid(), LocalDate.now());
        }

        entry.setUpdatedDate(LocalDateTime.now());
        depositRepository.save(entry);
    }

    @Transactional
    public void closeDeposit(Integer id) {
        log.info("[DepositService] Closing Deposit. ID: {}", id);
        CustomerDepositEntry entry = depositRepository.findById(Objects.requireNonNull(id))
                .orElseThrow(() -> new NoSuchElementException("Deposit not found"));
        entry.setEntryStatus(STATUS_CLOSED);
        entry.setUpdatedDate(LocalDateTime.now());
        depositRepository.save(entry);

        List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(id);
        for (CustomerDepositItems item : items) {
            item.setItemStatus(STATUS_RETURNED);
            item.setUpdatedDate(LocalDateTime.now());
            itemsRepository.save(item);
        }
    }
}

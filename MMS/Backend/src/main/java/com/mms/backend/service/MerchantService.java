package com.mms.backend.service;

import com.mms.backend.dto.B2BTransferRequest;
import com.mms.backend.dto.AvailableItemDTO;
import com.mms.backend.dto.MerchantItemDTO;
import com.mms.backend.dto.RedemptionRequest;
import com.mms.backend.entity.*;
import com.mms.backend.repository.*;
import static com.mms.backend.util.Constants.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Period;
import java.util.List;
import java.util.Map;
import com.mms.backend.dto.MerchantEntryDetailsDTO;
import com.mms.backend.dto.MerchantTransactionDTO;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MerchantService {

    private final MerchantMasterRepository merchantRepository;
    private final CustomerDepositItemsRepository itemsRepository;
    private final MerchantItemEntryRepository merchantItemEntryRepository;
    private final ItemPriceHistoryRepository priceRepository;
    private final MerchantItemTransactionRepository transactionRepository;
    private final CustomerDepositTransactionRepository custTxnRepo;

    public List<MerchantMaster> getAllMerchants() {
        return merchantRepository.findAll();
    }

    @Transactional(readOnly = true)
    public List<AvailableItemDTO> getAvailableItems() {
        Map<Integer, ItemPriceHistory> latestPricesMap = priceRepository.findLatestPricePerItem().stream()
                .collect(Collectors.toMap(p -> p.getItem().getId(), p -> p));

        List<CustomerDepositItems> availableItems = itemsRepository.findByItemStatusIn(List.of(STATUS_ACTIVE, "DEPOSITED"));
        
        // Optimize Principal calc by fetching in bulk per deposit
        List<Integer> depositIds = availableItems.stream()
                .map(item -> item.getDepositEntry().getId())
                .distinct()
                .toList();

        Map<Integer, BigDecimal> loanMap = depositIds.stream().collect(Collectors.toMap(
                id -> id,
                id -> {
                    List<CustomerDepositTransaction> txns = custTxnRepo.findByDepositEntry_Id(id);
                    BigDecimal added = txns.stream()
                            .filter(t -> TX_INITIAL_MONEY.equals(t.getTransactionType()) || TX_EXTRA_WITHDRAWAL.equals(t.getTransactionType()))
                            .map(CustomerDepositTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
                    BigDecimal paid = txns.stream()
                            .filter(t -> TX_PRINCIPAL_PAYMENT.equals(t.getTransactionType()))
                            .map(CustomerDepositTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
                    return added.subtract(paid);
                }
        ));

        return availableItems.stream()
                .map(item -> {
                    AvailableItemDTO dto = new AvailableItemDTO();
                    dto.setId(item.getId());
                    dto.setDepositEntryId(item.getDepositEntry().getId());
                    dto.setTokenNo(item.getDepositEntry().getTokenNo());
                    dto.setCustomerName(item.getDepositEntry().getCustomer().getCustomerName());
                    dto.setItemName(item.getItem().getItemName());
                    dto.setWeight(item.getWeightReceived());
                    dto.setFineWeight(item.getFineWeight());
                    dto.setItemStatus(item.getItemStatus());

                    // Calculate value
                    ItemPriceHistory latestPrice = latestPricesMap.get(item.getItem().getId());
                    if (latestPrice != null) {
                        BigDecimal unitQty = item.getItem().getUnitQuantity();
                        BigDecimal unitInGram = (item.getItem().getUnit() != null)
                                ? item.getItem().getUnit().getUnitInGram()
                                : BigDecimal.ONE;

                        BigDecimal baseWeightInGrams = unitQty.multiply(unitInGram);

                        if (baseWeightInGrams.compareTo(BigDecimal.ZERO) > 0) {
                            BigDecimal itemValue = item.getFineWeight()
                                    .divide(baseWeightInGrams, 6, RoundingMode.HALF_UP)
                                    .multiply(latestPrice.getPrice());
                            dto.setCurrentAssetValue(itemValue.setScale(2, RoundingMode.HALF_UP));
                        }
                    }
                    
                    dto.setPrincipalAmount(loanMap.getOrDefault(item.getDepositEntry().getId(), BigDecimal.ZERO));

                    return dto;
                })
                .toList();
    }

    @Transactional
    public MerchantMaster saveMerchant(MerchantMaster merchant) {
        if (merchant.getCreatedDate() == null) {
            merchant.setCreatedDate(LocalDateTime.now());
        }
        merchant.setUpdatedDate(LocalDateTime.now());
        return merchantRepository.save(merchant);
    }

    @Transactional
    public MerchantMaster updateMerchant(Integer id, MerchantMaster merchantDetails) {
        MerchantMaster merchant = merchantRepository.findById(java.util.Objects.requireNonNull(id))
                .orElseThrow(() -> new RuntimeException(MSG_MERCHANT_NOT_FOUND));

        merchant.setMerchantName(merchantDetails.getMerchantName());
        merchant.setMerchantType(merchantDetails.getMerchantType());
        merchant.setMobileNumber(merchantDetails.getMobileNumber());
        merchant.setAddress(merchantDetails.getAddress());
        merchant.setVillage(merchantDetails.getVillage());
        merchant.setDistrict(merchantDetails.getDistrict());
        merchant.setState(merchantDetails.getState());
        merchant.setPincode(merchantDetails.getPincode());
        merchant.setDefaultInterestRate(merchantDetails.getDefaultInterestRate());
        merchant.setIsActive(merchantDetails.getIsActive());
        merchant.setUpdatedDate(LocalDateTime.now());

        return merchantRepository.save(merchant);
    }

    @Transactional
    public void deleteMerchant(Integer id) {
        MerchantMaster merchant = merchantRepository.findById(java.util.Objects.requireNonNull(id))
                .orElseThrow(() -> new RuntimeException(MSG_MERCHANT_NOT_FOUND));

        // Soft delete
        merchant.setIsActive(false);
        merchant.setUpdatedDate(LocalDateTime.now());
        merchantRepository.save(merchant);
    }

    @Transactional
    public void transferToMerchant(B2BTransferRequest request) {
        CustomerDepositItems item = itemsRepository
                .findById(java.util.Objects.requireNonNull(request.getDepositItemId()))
                .orElseThrow(() -> new RuntimeException("Item not found"));

        MerchantMaster merchant = merchantRepository.findById(java.util.Objects.requireNonNull(request.getMerchantId()))
                .orElseThrow(() -> new RuntimeException(MSG_MERCHANT_NOT_FOUND));

        // Update Item Status
        item.setItemStatus("PLEDGED_TO_MERCHANT");
        itemsRepository.save(item);

        // Create Merchant Entry
        MerchantItemEntry entry = new MerchantItemEntry();
        entry.setMerchant(merchant);
        entry.setCustomerDepositItem(item);
        entry.setEntryDate(request.getEntryDate());
        entry.setInterestRate(request.getInterestRate());
        entry.setPrincipalAmount(request.getPrincipalAmount());
        entry.setNotes(request.getNotes());
        entry.setCreatedDate(LocalDateTime.now());
        entry.setEntryStatus(STATUS_ACTIVE);

        merchantItemEntryRepository.save(entry);

        // Record Initial Pledge Transaction Log
        MerchantItemTransaction txn = new MerchantItemTransaction();
        txn.setMerchantItemEntry(entry);
        txn.setTransactionType("PLEDGE");
        txn.setAmount(request.getPrincipalAmount());
        txn.setTransactionDate(request.getEntryDate());
        txn.setDescription(request.getNotes() != null ? request.getNotes() : "Initial Pledge");
        txn.setCreatedDate(LocalDateTime.now());
        transactionRepository.save(txn);
    }

    @Transactional
    public void updateMerchantEntry(Integer entryId, B2BTransferRequest request) {
        MerchantItemEntry entry = merchantItemEntryRepository.findById(java.util.Objects.requireNonNull(entryId))
                .orElseThrow(() -> new RuntimeException(MSG_ENTRY_NOT_FOUND));

        if (request.getMerchantId() != null) {
            MerchantMaster merchant = merchantRepository
                    .findById(java.util.Objects.requireNonNull(request.getMerchantId()))
                    .orElseThrow(() -> new RuntimeException(MSG_MERCHANT_NOT_FOUND));
            entry.setMerchant(merchant);
        }

        if (request.getPrincipalAmount() != null)
            entry.setPrincipalAmount(request.getPrincipalAmount());
        if (request.getInterestRate() != null)
            entry.setInterestRate(request.getInterestRate());
        if (request.getEntryDate() != null)
            entry.setEntryDate(request.getEntryDate());
        if (request.getNotes() != null)
            entry.setNotes(request.getNotes());

        entry.setUpdatedDate(LocalDateTime.now());
        merchantItemEntryRepository.save(entry);
    }

    @Transactional(readOnly = true)
    public List<MerchantItemDTO> getActiveMerchantEntries() {
        Map<Integer, ItemPriceHistory> latestPricesMap = priceRepository.findLatestPricePerItem().stream()
                .collect(Collectors.toMap(p -> p.getItem().getId(), p -> p));

        return merchantItemEntryRepository.findByEntryStatus(STATUS_ACTIVE).stream()
                .map(e -> mapToMerchantItemDTO(e, latestPricesMap.get(e.getCustomerDepositItem().getItem().getId())))
                .toList();
    }

    @Transactional
    public void addTransaction(Integer entryId, RedemptionRequest request) {
        MerchantItemEntry entry = merchantItemEntryRepository.findById(java.util.Objects.requireNonNull(entryId))
                .orElseThrow(() -> new RuntimeException(MSG_ENTRY_NOT_FOUND));

        // 1. Handle Principal Payment
        if (request.getPrincipalPaid() != null && request.getPrincipalPaid().compareTo(BigDecimal.ZERO) > 0) {
            MerchantItemTransaction txn = new MerchantItemTransaction();
            txn.setMerchantItemEntry(entry);
            txn.setTransactionType(TX_PRINCIPAL_PAYMENT);
            txn.setAmount(request.getPrincipalPaid());
            txn.setTransactionDate(request.getTransactionDate() != null ? request.getTransactionDate() : LocalDate.now());
            txn.setDescription(request.getNotes());
            txn.setCreatedDate(LocalDateTime.now());
            transactionRepository.save(txn);

            // Update Entry Principal
            if (entry.getPrincipalAmount() != null) {
                entry.setPrincipalAmount(entry.getPrincipalAmount().subtract(request.getPrincipalPaid()));
            }
        }

        // 2. Handle Interest Payment
        if (request.getInterestPaid() != null && request.getInterestPaid().compareTo(BigDecimal.ZERO) > 0) {
            MerchantItemTransaction txn = new MerchantItemTransaction();
            txn.setMerchantItemEntry(entry);
            txn.setTransactionType(TX_INTEREST_PAYMENT);
            txn.setAmount(request.getInterestPaid());
            txn.setTransactionDate(request.getTransactionDate() != null ? request.getTransactionDate() : LocalDate.now());
            txn.setDescription(request.getNotes());
            txn.setCreatedDate(LocalDateTime.now());
            transactionRepository.save(txn);
        }

        entry.setUpdatedDate(LocalDateTime.now());
        merchantItemEntryRepository.save(entry);
    }

    @Transactional
    public void returnFromMerchant(Integer entryId, RedemptionRequest request) {
        MerchantItemEntry entry = merchantItemEntryRepository.findById(java.util.Objects.requireNonNull(entryId))
                .orElseThrow(() -> new RuntimeException(MSG_ENTRY_NOT_FOUND));

        // 1. Record Interest Payment if any
        if (request.getInterestPaid() != null && request.getInterestPaid().compareTo(BigDecimal.ZERO) > 0) {
            MerchantItemTransaction txn = new MerchantItemTransaction();
            txn.setMerchantItemEntry(entry);
            txn.setTransactionType(TX_INTEREST_PAYMENT);
            txn.setAmount(request.getInterestPaid());
            txn.setTransactionDate(request.getTransactionDate() != null ? request.getTransactionDate() : LocalDate.now());
            txn.setDescription(request.getNotes() != null ? request.getNotes() : "Interest Settled on Return");
            txn.setCreatedDate(LocalDateTime.now());
            transactionRepository.save(txn);
        }

        // 2. Record the RETURN event
        MerchantItemTransaction returnTx = new MerchantItemTransaction();
        returnTx.setMerchantItemEntry(entry);
        returnTx.setTransactionType("RETURN");
        // We use the principalPaid from the request as the amount for the return log
        BigDecimal pAmount = request.getPrincipalPaid() != null ? request.getPrincipalPaid()
                : entry.getPrincipalAmount();
        returnTx.setAmount(pAmount);
        returnTx.setTransactionDate(request.getTransactionDate() != null ? request.getTransactionDate() : LocalDate.now());
        returnTx.setDescription("Item Returned to Inventory");
        returnTx.setCreatedDate(LocalDateTime.now());
        transactionRepository.save(returnTx);

        // Update Entry Status
        entry.setEntryStatus("RETURNED");
        entry.setUpdatedDate(LocalDateTime.now());
        merchantItemEntryRepository.save(entry);

        // Update Item Status back to DEPOSITED
        CustomerDepositItems item = entry.getCustomerDepositItem();
        item.setItemStatus(STATUS_ACTIVE);
        itemsRepository.save(item);
    }

    @Transactional
    public void payMerchantUnpaidInterest(Integer merchantId, RedemptionRequest request) {
        List<MerchantItemEntry> entries = merchantItemEntryRepository.findByMerchantIdAndEntryStatus(merchantId, STATUS_ACTIVE);
        String notes = (request != null && request.getNotes() != null) ? request.getNotes() : "Bulk Interest Clearance";
        LocalDate tDate = (request != null && request.getTransactionDate() != null) ? request.getTransactionDate() : LocalDate.now();

        for (MerchantItemEntry e : entries) {
            List<MerchantItemTransaction> txns = transactionRepository.findByMerchantItemEntryId(e.getId());
            BigDecimal interestPaid = txns.stream()
                    .filter(t -> TX_INTEREST_PAYMENT.equals(t.getTransactionType()))
                    .map(MerchantItemTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal interestAccrued = calculateAccruedInterest(e, tDate);
            BigDecimal unpaid = interestAccrued.subtract(interestPaid);

            if (unpaid.compareTo(BigDecimal.ZERO) > 0) {
                MerchantItemTransaction txn = new MerchantItemTransaction();
                txn.setMerchantItemEntry(e);
                txn.setTransactionType(TX_INTEREST_PAYMENT);
                txn.setAmount(unpaid);
                txn.setTransactionDate(tDate);
                txn.setDescription(notes);
                txn.setCreatedDate(LocalDateTime.now());
                transactionRepository.save(txn);
            }
        }
    }

    private BigDecimal calculateAccruedInterest(MerchantItemEntry e, LocalDate referenceDate) {
        BigDecimal amount = e.getPrincipalAmount() != null ? e.getPrincipalAmount() : BigDecimal.ZERO;
        BigDecimal rate = e.getInterestRate() != null ? e.getInterestRate() : BigDecimal.ZERO;

        Period period = Period.between(e.getEntryDate(), referenceDate);
        int totalMonths = (period.getYears() * 12) + period.getMonths() + 1;

        return amount.multiply(rate)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(totalMonths));
    }

    @Transactional(readOnly = true)
    public MerchantEntryDetailsDTO getMerchantEntryDetails(Integer entryId) {
        MerchantItemEntry e = merchantItemEntryRepository.findById(java.util.Objects.requireNonNull(entryId))
                .orElseThrow(() -> new RuntimeException(MSG_ENTRY_NOT_FOUND));

        MerchantEntryDetailsDTO details = new MerchantEntryDetailsDTO();

        // Asset Value (Simplified: fetch latest price for this item only)
        ItemPriceHistory latestPrice = priceRepository
                .findTopByItem_IdOrderByEffectiveDateDesc(e.getCustomerDepositItem().getItem().getId());

        details.setSummary(mapToMerchantItemDTO(e, latestPrice));

        // 2. Map Transactions
        List<MerchantTransactionDTO> txnDtos = transactionRepository.findByMerchantItemEntryId(e.getId()).stream()
                .map(t -> {
                    MerchantTransactionDTO td = new MerchantTransactionDTO();
                    td.setId(t.getId());
                    td.setTransactionType(t.getTransactionType());
                    td.setAmount(t.getAmount());
                    td.setTransactionDate(t.getTransactionDate());
                    td.setDescription(t.getDescription());
                    return td;
                }).toList();

        details.setTransactions(txnDtos);

        return details;
    }

    private MerchantItemDTO mapToMerchantItemDTO(MerchantItemEntry e, ItemPriceHistory latestPrice) {
        MerchantItemDTO dto = new MerchantItemDTO();
        dto.setEntryId(e.getId());
        dto.setMerchantId(e.getMerchant().getId());
        dto.setMerchantName(e.getMerchant().getMerchantName());
        dto.setDepositItemId(e.getCustomerDepositItem().getId());
        dto.setTokenNo(e.getCustomerDepositItem().getDepositEntry().getTokenNo());
        dto.setCustomerName(e.getCustomerDepositItem().getDepositEntry().getCustomer().getCustomerName());
        dto.setItemName(e.getCustomerDepositItem().getItem().getItemName());
        dto.setWeight(e.getCustomerDepositItem().getWeightReceived());
        dto.setFineWeight(e.getCustomerDepositItem().getFineWeight());
        dto.setEntryDate(e.getEntryDate());
        dto.setInterestRate(e.getInterestRate());
        dto.setPrincipalAmount(e.getPrincipalAmount());
        dto.setStatus(e.getEntryStatus());
        dto.setNotes(e.getNotes());

        // Fetch Transactions to calc totals
        List<MerchantItemTransaction> txns = transactionRepository.findByMerchantItemEntryId(e.getId());
        BigDecimal principalPaid = txns.stream()
                .filter(t -> TX_PRINCIPAL_PAYMENT.equals(t.getTransactionType()))
                .map(MerchantItemTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal interestPaid = txns.stream()
                .filter(t -> TX_INTEREST_PAYMENT.equals(t.getTransactionType()))
                .map(MerchantItemTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

        dto.setTotalPrincipalPaid(principalPaid);
        dto.setTotalInterestPaid(interestPaid);

        // Calculate Financials: Interest and Total
        BigDecimal amount = e.getPrincipalAmount() != null ? e.getPrincipalAmount() : BigDecimal.ZERO;
        BigDecimal rate = e.getInterestRate() != null ? e.getInterestRate() : BigDecimal.ZERO;

        BigDecimal interestAccrued = calculateAccruedInterest(e, LocalDate.now());
        Period period = Period.between(e.getEntryDate(), LocalDate.now());
        int totalMonths = (period.getYears() * 12) + period.getMonths() + 1;

        dto.setMonthsDuration(totalMonths);
        dto.setAccruedInterest(interestAccrued);
        dto.setMonthlyInterestAmount(
                amount.multiply(rate).divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP));

        // Business Profitability (Interest Margin)
        BigDecimal custRate = e.getCustomerDepositItem().getDepositEntry().getTotalInterestRate();
        BigDecimal custMonthlyInt = amount.multiply(custRate != null ? custRate : BigDecimal.ZERO)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        dto.setCustomerInterestRate(custRate);
        dto.setCustomerMonthlyInterest(custMonthlyInt);
        dto.setNetMonthlyMargin(custMonthlyInt.subtract(dto.getMonthlyInterestAmount()));

        BigDecimal netInterest = interestAccrued.subtract(interestPaid);
        if (netInterest.compareTo(BigDecimal.ZERO) < 0)
            netInterest = BigDecimal.ZERO;

        dto.setTotalOwed(amount.add(netInterest));

        // Asset Value
        if (latestPrice != null) {
            BigDecimal unitQty = e.getCustomerDepositItem().getItem().getUnitQuantity();
            BigDecimal unitInGram = (e.getCustomerDepositItem().getItem().getUnit() != null)
                    ? e.getCustomerDepositItem().getItem().getUnit().getUnitInGram()
                    : BigDecimal.ONE;
            BigDecimal baseWeightInGrams = unitQty.multiply(unitInGram);
            if (baseWeightInGrams.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal itemValue = e.getCustomerDepositItem().getFineWeight()
                        .divide(baseWeightInGrams, 6, RoundingMode.HALF_UP)
                        .multiply(latestPrice.getPrice());
                dto.setCurrentAssetValue(itemValue.setScale(2, RoundingMode.HALF_UP));
            }
        }
        return dto;
    }
}

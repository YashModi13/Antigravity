package com.mms.backend.service;

import com.mms.backend.dto.*;
import com.mms.backend.entity.*;
import com.mms.backend.repository.*;
import static com.mms.backend.util.Constants.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Period;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class DepositQueryService {

    private final CustomerDepositEntryRepository depositRepository;
    private final CustomerDepositItemsRepository itemsRepository;
    private final CustomerDepositTransactionRepository transactionRepository;
    private final ItemPriceHistoryRepository priceRepository;
    private final ConfigPropertyRepository configRepository;
    private final MerchantItemEntryRepository merchantEntryRepository;
    private final CustomerMasterRepository customerRepository;
    private final PriceService priceService;

    public boolean hasActiveMerchantItems(Long depositId) {
        return merchantEntryRepository.countActiveByDepositId(depositId) > 0;
    }

    @Transactional(readOnly = true)
    public List<MerchantItemDTO> getActiveMerchantPledges(Long depositId) {
        return merchantEntryRepository.findActiveByDepositId(depositId).stream().map(entry -> {
            MerchantItemDTO dto = new MerchantItemDTO();
            dto.setEntryId(entry.getId());
            dto.setMerchantName(entry.getMerchant().getMerchantName());
            dto.setMerchantId(entry.getMerchant().getId());
            dto.setItemName(entry.getCustomerDepositItem().getItem().getItemName());
            dto.setFineWeight(entry.getCustomerDepositItem().getFineWeight());
            dto.setPrincipalAmount(entry.getPrincipalAmount());
            dto.setEntryDate(entry.getEntryDate());
            dto.setStatus(entry.getEntryStatus());

            BigDecimal principal = entry.getPrincipalAmount();
            BigDecimal rate = entry.getInterestRate() != null ? entry.getInterestRate() : BigDecimal.ZERO;
            BigDecimal monthlyInterest = principal.multiply(rate).divide(BigDecimal.valueOf(100), 2,
                    RoundingMode.HALF_UP);
            dto.setMonthlyInterestAmount(monthlyInterest);

            return dto;
        }).toList();
    }

    @Transactional(readOnly = true)
    public List<DepositSummaryDTO> getActiveDepositSummary() {
        log.info("[DepositQueryService] Fetching Active Deposit Summaries.");
        List<CustomerDepositEntry> activeDeposits = depositRepository.findAllActiveWithCustomer();

        Map<Integer, ItemPriceHistory> latestPricesMap = priceRepository.findLatestPricePerItem()
                .stream()
                .filter(iph -> iph != null && iph.getItem() != null && iph.getItem().getId() != null)
                .collect(Collectors.toMap(
                        iph -> iph.getItem().getId(),
                        iph -> iph,
                        (existing, replacement) -> existing));

        Map<String, String> configs = configRepository.findAll().stream()
                .collect(Collectors.toMap(ConfigProperty::getPropertyKey, ConfigProperty::getPropertyValue,
                        (a, b) -> a));

        return activeDeposits.stream()
                .map(deposit -> buildDepositSummary(deposit, latestPricesMap, configs))
                .toList();
    }

    private DepositSummaryDTO buildDepositSummary(CustomerDepositEntry deposit,
            Map<Integer, ItemPriceHistory> latestPricesMap, Map<String, String> configs) {
        DepositSummaryDTO dto = new DepositSummaryDTO();
        dto.setDepositId(deposit.getId());
        dto.setCustomerName(deposit.getCustomer() != null ? deposit.getCustomer().getCustomerName() : "Unknown");
        dto.setDepositDate(deposit.getDepositDate());

        List<CustomerDepositTransaction> transactions = transactionRepository.findByDepositEntry_Id(deposit.getId());
        FinancialSummary financial = calculateFinancials(transactions);

        TimeSummary timeSummary = calculateTimeSummary(deposit.getDepositDate(), LocalDate.now(), configs);
        dto.setDepositedMonths(timeSummary.interestMonths);
        dto.setDepositedTimeDisplay(timeSummary.displayString);

        BigDecimal projectedInterest = financial.loanAmount
                .multiply(deposit.getTotalInterestRate().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP))
                .multiply(timeSummary.interestMonths);

        BigDecimal totalInterestLiability = projectedInterest.max(financial.interestAccruedPosted);
        BigDecimal unpaidInterest = totalInterestLiability.subtract(financial.interestPaid);

        dto.setTotalLoanAmount(financial.loanAmount);
        dto.setTotalInterestAccrued(totalInterestLiability);
        dto.setTotalInterestPaid(financial.interestPaid);
        dto.setUnpaidInterest(unpaidInterest);
        dto.setMonthlyInterest(financial.loanAmount.multiply(
                deposit.getTotalInterestRate().divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP)));

        List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(deposit.getId());
        BigDecimal currentAssetValue = calculateAssetValue(items, latestPricesMap);

        dto.setCurrentAssetValue(currentAssetValue);
        BigDecimal totalOwed = financial.loanAmount.add(unpaidInterest);
        dto.setProfitLoss(currentAssetValue.subtract(totalOwed));

        BigDecimal riskThreshold = new BigDecimal(
                getConfig(configs, "system.risk.threshold.percentage", "100"));
        BigDecimal limitValue = currentAssetValue.multiply(riskThreshold).divide(BigDecimal.valueOf(100), 2,
                RoundingMode.HALF_UP);
        dto.setStatus(totalOwed.compareTo(limitValue) > 0 ? STATUS_RISK : STATUS_SAFE);

        return dto;
    }

    private FinancialSummary calculateFinancials(List<CustomerDepositTransaction> transactions) {
        BigDecimal loan = BigDecimal.ZERO;
        BigDecimal interestAccrued = BigDecimal.ZERO;
        BigDecimal interestPaid = BigDecimal.ZERO;

        for (CustomerDepositTransaction tx : transactions) {
            String type = tx.getTransactionType();
            if (TX_INITIAL_MONEY.equals(type) || TX_EXTRA_WITHDRAWAL.equals(type)) {
                loan = loan.add(tx.getAmount());
            } else if (TX_INTEREST_RECEIVED.equals(type)) {
                interestAccrued = interestAccrued.add(tx.getAmount());
            } else if (TX_INTEREST_PAYMENT.equals(type)) {
                interestPaid = interestPaid.add(tx.getAmount());
            } else if (TX_PRINCIPAL_PAYMENT.equals(type)) {
                loan = loan.subtract(tx.getAmount());
            }
        }
        return new FinancialSummary(loan, interestAccrued, interestPaid);
    }

    private record FinancialSummary(BigDecimal loanAmount, BigDecimal interestAccruedPosted, BigDecimal interestPaid) {
    }

    private TimeSummary calculateTimeSummary(LocalDate startDate, LocalDate endDate, Map<String, String> configs) {
        long daysElapsed = ChronoUnit.DAYS.between(startDate, endDate);
        Period period = Period.between(startDate, endDate);
        int totalMonths = (period.getYears() * 12) + period.getMonths();
        int displayDays = period.getDays();

        boolean roundUp = "true".equalsIgnoreCase(getConfig(configs, "system.calendar.months.round_up", "false"));
        int interestMonths = totalMonths;
        if (roundUp && (displayDays > 0 || (totalMonths == 0 && daysElapsed >= 0))) {
            interestMonths++;
        }

        StringBuilder actualBuilder = new StringBuilder();
        boolean hasTime = false;
        if (totalMonths > 0) {
            actualBuilder.append(totalMonths).append(totalMonths == 1 ? " month" : LITERAL_MONTHS);
            hasTime = true;
        }
        if (displayDays > 0) {
            if (hasTime)
                actualBuilder.append(" ");
            actualBuilder.append(displayDays).append(displayDays == 1 ? " day" : " days");
            hasTime = true;
        }
        if (!hasTime) {
            actualBuilder.append("0 days");
        }

        String displayString = interestMonths + (interestMonths == 1 ? " month" : LITERAL_MONTHS) + " ("
                + actualBuilder.toString() + ")";
        return new TimeSummary(BigDecimal.valueOf(interestMonths), displayString);
    }

    private record TimeSummary(BigDecimal interestMonths, String displayString) {
    }

    private BigDecimal calculateAssetValue(List<CustomerDepositItems> items,
            Map<Integer, ItemPriceHistory> latestPricesMap) {
        BigDecimal totalValue = BigDecimal.ZERO;
        for (CustomerDepositItems item : items) {
            ItemPriceHistory latest = latestPricesMap.get(item.getItem().getId());
            if (latest != null) {
                BigDecimal unitQty = item.getItem().getUnitQuantity();
                BigDecimal unitInGram = (item.getItem().getUnit() != null) ? item.getItem().getUnit().getUnitInGram()
                        : BigDecimal.ONE;
                BigDecimal baseWeightInGrams = unitQty.multiply(unitInGram);

                if (baseWeightInGrams.compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal itemValue = item.getFineWeight()
                            .divide(baseWeightInGrams, 6, RoundingMode.HALF_UP)
                            .multiply(latest.getPrice());
                    totalValue = totalValue.add(itemValue);
                }
            }
        }
        return totalValue;
    }

    private DepositQueryService self;

    @org.springframework.beans.factory.annotation.Autowired
    public void setSelf(@org.springframework.context.annotation.Lazy DepositQueryService self) {
        this.self = self;
    }

    @Transactional(readOnly = true)
    public Page<DepositSummaryDTO> getActiveDepositSummaryPaginated(int page, int size, String sortBy, String direction,
            DepositFilterDTO filters) {
        log.info("[DepositQueryService] Fetching Paginated Summaries. Page: {}, Size: {}, Sort: {}", page, size,
                sortBy);
        List<DepositSummaryDTO> allData = self.getActiveDepositSummary();

        if (filters != null) {
            allData = applyFilters(allData, filters);
        }

        allData = applySorting(allData, sortBy, direction);

        int start = Math.min((int) PageRequest.of(page, size).getOffset(), allData.size());
        int end = Math.min((start + size), allData.size());
        List<DepositSummaryDTO> pagedList = allData.subList(start, end);

        return new PageImpl<>(java.util.Objects.requireNonNull(pagedList), PageRequest.of(page, size), allData.size());
    }

    private List<DepositSummaryDTO> applyFilters(List<DepositSummaryDTO> data, DepositFilterDTO filters) {
        return data.stream().filter(d -> {
            boolean match = true;
            if (filters.getId() != null && !filters.getId().isEmpty())
                match = match && d.getDepositId().toString().contains(filters.getId());
            if (filters.getCustomerName() != null && !filters.getCustomerName().isEmpty())
                match = match
                        && d.getCustomerName().toLowerCase().contains(filters.getCustomerName().toLowerCase());
            return match;
        }).toList();
    }

    private List<DepositSummaryDTO> applySorting(List<DepositSummaryDTO> data, String sortBy, String direction) {
        List<DepositSummaryDTO> sortedData = new ArrayList<>(data);
        if (sortBy != null && !sortBy.isEmpty()) {
            Comparator<DepositSummaryDTO> comparator = getComparator(sortBy);
            if (comparator != null) {
                if ("desc".equalsIgnoreCase(direction)) {
                    comparator = comparator.reversed();
                }
                sortedData.sort(comparator);
                return sortedData;
            }
        }
        sortedData.sort((a, b) -> b.getDepositId().compareTo(a.getDepositId()));
        return sortedData;
    }

    private Comparator<DepositSummaryDTO> getComparator(String sortBy) {
        switch (sortBy) {
            case "depositId":
                return Comparator.comparing(DepositSummaryDTO::getDepositId);
            case "customerName":
                return Comparator.comparing(d -> d.getCustomerName().toLowerCase());
            case "depositDate":
                return Comparator.comparing(DepositSummaryDTO::getDepositDate);
            case "months":
                return Comparator.comparing(DepositSummaryDTO::getDepositedMonths,
                        Comparator.nullsFirst(BigDecimal::compareTo));
            case "totalLoanAmount":
                return Comparator.comparing(DepositSummaryDTO::getTotalLoanAmount);
            case "totalInterestAccrued":
                return Comparator.comparing(DepositSummaryDTO::getTotalInterestAccrued);
            case "unpaidInterest":
                return Comparator.comparing(DepositSummaryDTO::getUnpaidInterest);
            case "currentAssetValue":
                return Comparator.comparing(DepositSummaryDTO::getCurrentAssetValue);
            case "profitLoss":
                return Comparator.comparing(DepositSummaryDTO::getProfitLoss);
            case "status":
                return Comparator.comparing(DepositSummaryDTO::getStatus);
            case "monthsWait":
                return (a, b) -> {
                    BigDecimal plA = a.getProfitLoss() != null ? a.getProfitLoss() : BigDecimal.ZERO;
                    BigDecimal plB = b.getProfitLoss() != null ? b.getProfitLoss() : BigDecimal.ZERO;
                    BigDecimal miA = a.getMonthlyInterest();
                    BigDecimal miB = b.getMonthlyInterest();
                    double valA = (miA != null && miA.doubleValue() > 0) ? (plA.doubleValue() / miA.doubleValue())
                            : Double.MAX_VALUE;
                    double valB = (miB != null && miB.doubleValue() > 0) ? (plB.doubleValue() / miB.doubleValue())
                            : Double.MAX_VALUE;
                    return Double.compare(valA, valB);
                };
            default:
                return Comparator.comparing(DepositSummaryDTO::getDepositId);
        }
    }

    @Transactional(readOnly = true)
    public DepositDetailDTO getDepositDetails(Integer id) {
        log.info("[DepositQueryService] Fetching Deposit Details. ID: {}", id);
        CustomerDepositEntry entry = depositRepository.findById(java.util.Objects.requireNonNull(id)).orElseThrow();
        DepositDetailDTO dto = new DepositDetailDTO();
        dto.setDepositId(entry.getId());
        dto.setTokenNo(entry.getTokenNo());
        dto.setCustomerId(entry.getCustomer().getId());
        dto.setCustomerName(entry.getCustomer().getCustomerName());
        dto.setCustomerMobileNumber(entry.getCustomer().getMobileNumber());
        dto.setCustomerAddress(entry.getCustomer().getAddress());
        dto.setCustomerVillage(entry.getCustomer().getVillage());
        dto.setCustomerDistrict(entry.getCustomer().getDistrict());
        dto.setCustomerState(entry.getCustomer().getState());
        dto.setCustomerReference(entry.getCustomer().getReferralName());
        dto.setDepositDate(entry.getDepositDate());
        dto.setInterestRate(entry.getTotalInterestRate());
        dto.setNotes(entry.getNotes());

        List<CustomerDepositTransaction> transactions = transactionRepository.findByDepositEntry_Id(id);
        FinancialSummary financial = calculateFinancials(transactions);

        dto.setInitialLoanAmount(financial.loanAmount);
        dto.setTotalInterestPaid(financial.interestPaid);

        Map<String, String> configs = configRepository.findAll().stream()
                .collect(Collectors.toMap(ConfigProperty::getPropertyKey, ConfigProperty::getPropertyValue,
                        (a, b) -> a));

        TimeSummary timeSummary = calculateTimeSummary(entry.getDepositDate(), LocalDate.now(), configs);
        dto.setDepositedMonths(timeSummary.interestMonths);
        dto.setDepositedTimeDisplay(timeSummary.displayString);

        BigDecimal projectedInterest = financial.loanAmount
                .multiply(
                        entry.getTotalInterestRate().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP))
                .multiply(timeSummary.interestMonths);

        BigDecimal totalInterestLiability = projectedInterest.max(financial.interestAccruedPosted);
        dto.setTotalInterestAccrued(totalInterestLiability);
        dto.setUnpaidInterest(totalInterestLiability.subtract(financial.interestPaid));

        List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(id);
        Map<Integer, ItemPriceHistory> latestPricesMap = priceRepository.findLatestPricePerItem().stream()
                .collect(Collectors.toMap(iph -> iph.getItem().getId(), iph -> iph, (ex, rep) -> ex));

        List<DepositDetailDTO.DepositItemDTO> itemDtos = items.stream().map(item -> {
            DepositDetailDTO.DepositItemDTO iDto = new DepositDetailDTO.DepositItemDTO();
            iDto.setId(item.getId());
            iDto.setItemId(item.getItem().getId());
            iDto.setItemName(item.getItem().getItemName());
            iDto.setWeight(item.getWeightReceived());
            iDto.setUnitId(item.getWeightUnit().getId());
            iDto.setFineWeight(item.getFineWeight());
            iDto.setDescription(item.getItemDescription());
            return iDto;
        }).toList();

        dto.setItems(itemDtos);

        BigDecimal currentAssetValue = calculateAssetValue(items, latestPricesMap);
        dto.setCurrentAssetValue(currentAssetValue);

        List<DepositDetailDTO.TransactionDTO> transactionDtos = transactions.stream().map(tx -> {
            DepositDetailDTO.TransactionDTO tDto = new DepositDetailDTO.TransactionDTO();
            tDto.setType(tx.getTransactionType());
            tDto.setAmount(tx.getAmount());
            tDto.setDate(tx.getTransactionDate());
            tDto.setDescription(tx.getDescription());
            return tDto;
        }).toList();
        dto.setTransactions(transactionDtos);

        BigDecimal totalOwed = financial.loanAmount.add(dto.getUnpaidInterest());
        dto.setProfitLoss(currentAssetValue.subtract(totalOwed));
        BigDecimal riskThreshold = new BigDecimal(getConfig(configs, "system.risk.threshold.percentage", "100"));
        BigDecimal limitValue = currentAssetValue.multiply(riskThreshold).divide(BigDecimal.valueOf(100), 2,
                RoundingMode.HALF_UP);
        dto.setStatus(totalOwed.compareTo(limitValue) > 0 ? STATUS_RISK : STATUS_SAFE);

        return dto;
    }

    @Transactional(readOnly = true)
    public List<CustomerItemDTO> getCustomerItems(Integer customerId) {
        log.info("[DepositQueryService] Fetching Items for Customer ID: {}", customerId);
        List<CustomerDepositEntry> deposits = depositRepository.findAll().stream()
                .filter(d -> d.getCustomer().getId().equals(customerId))
                .toList();

        List<CustomerItemDTO> items = new ArrayList<>();

        for (CustomerDepositEntry deposit : deposits) {
            List<CustomerDepositItems> realItems = itemsRepository.findByDepositEntry_Id(deposit.getId());
            for (CustomerDepositItems item : realItems) {
                CustomerItemDTO dto = new CustomerItemDTO();
                dto.setDepositId(deposit.getId());
                dto.setDepositDate(deposit.getDepositDate());
                dto.setDepositStatus(deposit.getEntryStatus());
                dto.setItemLineId(item.getId());
                dto.setItemName(item.getItem().getItemName());
                dto.setWeight(item.getWeightReceived());
                dto.setFineWeight(item.getFineWeight());
                dto.setDescription(item.getItemDescription());

                try {
                    BigDecimal currentValue = priceService.calculateAssetValue(item.getItem().getId(),
                            item.getFineWeight());
                    dto.setCurrentAssetValue(currentValue);
                } catch (Exception e) {
                    dto.setCurrentAssetValue(BigDecimal.ZERO);
                }
                items.add(dto);
            }
        }
        items.sort((a, b) -> b.getDepositDate().compareTo(a.getDepositDate()));
        return items;
    }

    @Transactional(readOnly = true)
    public CustomerPortfolioDTO getCustomerPortfolio(Integer customerId) {
        log.info("[DepositQueryService] Fetching Portfolio for Customer ID: {}", customerId);
        CustomerMaster customer = customerRepository.findById(java.util.Objects.requireNonNull(customerId))
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        List<CustomerDepositEntry> deposits = depositRepository.findAll().stream()
                .filter(d -> d.getCustomer().getId().equals(customerId))
                .toList();

        CustomerPortfolioDTO portfolio = new CustomerPortfolioDTO();
        portfolio.setCustomerId(customer.getId());
        portfolio.setCustomerName(customer.getCustomerName());
        portfolio.setMobileNumber(customer.getMobileNumber());
        portfolio.setAddress(customer.getAddress());
        portfolio.setCity(customer.getDistrict());

        long activeCount = deposits.stream().filter(d -> STATUS_ACTIVE.equals(d.getEntryStatus())).count();
        portfolio.setActiveDeposits(activeCount);
        portfolio.setHasItems(activeCount > 0);

        List<CustomerPortfolioDTO.PortfolioDepositDTO> depositDTOs = deposits.stream()
                .map(this::mapToPortfolioDeposit)
                .sorted((a, b) -> {
                    if (a.getStatus().equals(STATUS_ACTIVE) && !b.getStatus().equals(STATUS_ACTIVE))
                        return -1;
                    if (!a.getStatus().equals(STATUS_ACTIVE) && b.getStatus().equals(STATUS_ACTIVE))
                        return 1;
                    return b.getDepositDate().compareTo(a.getDepositDate());
                })
                .toList();
        portfolio.setDeposits(new ArrayList<>(depositDTOs)); // needs to be mutable list? List<DTO> field
        return portfolio;
    }

    private CustomerPortfolioDTO.PortfolioDepositDTO mapToPortfolioDeposit(CustomerDepositEntry deposit) {
        CustomerPortfolioDTO.PortfolioDepositDTO depDto = new CustomerPortfolioDTO.PortfolioDepositDTO();
        depDto.setDepositId(deposit.getId());
        depDto.setDepositDate(deposit.getDepositDate());
        depDto.setStatus(deposit.getEntryStatus());

        List<CustomerDepositTransaction> txs = transactionRepository.findByDepositEntry_Id(deposit.getId());
        calculateFinancials(txs);
        // Special logic for Portfolio View: PrincipalPaid logic might differ slightly
        // in original code?
        // Original: "PRINCIPAL_PAYMENT" reduced -> principalPaid. "PRINCIPAL_LOAN" |
        // "INITIAL" | "EXTRA" -> originalLoan.
        // My calculateFinancials subtracts PAYMENT from loan.
        // Let's recalculate strictly as per original logic to be safe for portfolio.

        BigDecimal principalPaid = txs.stream().filter(t -> TX_PRINCIPAL_PAYMENT.equals(t.getTransactionType()))
                .map(CustomerDepositTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal originalLoan = txs.stream().filter(t -> TX_PRINCIPAL_LOAN.equals(t.getTransactionType())
                || TX_INITIAL_MONEY.equals(t.getTransactionType())
                || TX_EXTRA_WITHDRAWAL.equals(t.getTransactionType()))
                .map(CustomerDepositTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

        depDto.setInitialLoanAmount(originalLoan);
        if (STATUS_CLOSED.equals(deposit.getEntryStatus()) && principalPaid.compareTo(BigDecimal.ZERO) == 0) {
            principalPaid = originalLoan;
        }
        depDto.setLoanAmount(originalLoan.subtract(principalPaid));

        // Use financial.interestPaid
        BigDecimal interestPaid = txs.stream().filter(t -> TX_INTEREST_PAYMENT.equals(t.getTransactionType()))
                .map(CustomerDepositTransaction::getAmount).reduce(BigDecimal.ZERO, BigDecimal::add);

        depDto.setPaidPrincipal(principalPaid);
        depDto.setPaidInterest(interestPaid);
        depDto.setInterestRate(deposit.getTotalInterestRate());

        BigDecimal monthlyInterestAmount = originalLoan.multiply(deposit.getTotalInterestRate())
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        depDto.setMonthlyInterest(monthlyInterestAmount);

        LocalDate endDate = (STATUS_CLOSED.equals(deposit.getEntryStatus()) && deposit.getUpdatedDate() != null)
                ? deposit.getUpdatedDate().toLocalDate()
                : LocalDate.now();
        if (STATUS_CLOSED.equals(deposit.getEntryStatus())) {
            depDto.setEndDate(endDate);
        }

        int interestMonths = calculatePortfolioMonths(deposit.getDepositDate(), endDate);
        depDto.setDurationDisplay(interestMonths + LITERAL_MONTHS);

        BigDecimal accrued = originalLoan.multiply(deposit.getTotalInterestRate())
                .multiply(BigDecimal.valueOf(interestMonths))
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        depDto.setAccruedInterest(accrued);

        if (STATUS_CLOSED.equals(deposit.getEntryStatus()) && interestPaid.compareTo(BigDecimal.ZERO) == 0) {
            depDto.setPaidInterest(accrued);
            interestPaid = accrued;
        }
        depDto.setAccruedInterest(accrued);

        BigDecimal totalIn = principalPaid.add(interestPaid);
        BigDecimal netProfit = totalIn.subtract(originalLoan);
        depDto.setNetProfitLoss(netProfit);

        // Items
        List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(deposit.getId());
        List<CustomerPortfolioDTO.PortfolioItemDTO> itemDTOs = items.stream().map(item -> {
            CustomerPortfolioDTO.PortfolioItemDTO itemDto = new CustomerPortfolioDTO.PortfolioItemDTO();
            itemDto.setItemName(item.getItem().getItemName());
            itemDto.setWeight(item.getWeightReceived());
            itemDto.setFineWeight(item.getFineWeight());
            if (STATUS_CLOSED.equals(deposit.getEntryStatus())) {
                itemDto.setStatus(STATUS_RETURNED);
            } else {
                itemDto.setStatus(item.getItemStatus());
            }
            try {
                BigDecimal val = priceService.calculateAssetValue(item.getItem().getId(), item.getFineWeight());
                itemDto.setCurrentAssetValue(val);
            } catch (Exception e) {
                itemDto.setCurrentAssetValue(BigDecimal.ZERO);
            }
            return itemDto;
        }).toList();
        depDto.setItems(new ArrayList<>(itemDTOs)); // Mutable

        // Transactions
        List<CustomerPortfolioDTO.PortfolioTransactionDTO> transDTOs = txs.stream()
                .sorted((t1, t2) -> t2.getTransactionDate().compareTo(t1.getTransactionDate()))
                .map(t -> {
                    CustomerPortfolioDTO.PortfolioTransactionDTO tDto = new CustomerPortfolioDTO.PortfolioTransactionDTO();
                    tDto.setDate(t.getTransactionDate());
                    tDto.setType(t.getTransactionType());
                    tDto.setAmount(t.getAmount());
                    tDto.setNotes(t.getDescription());
                    return tDto;
                }).toList();
        depDto.setTransactions(new ArrayList<>(transDTOs));

        return depDto;
    }

    private int calculatePortfolioMonths(LocalDate start, LocalDate end) {
        LocalDate effectiveEndDate = end.plusDays(1);
        Period period = Period.between(start, effectiveEndDate);
        int totalFullMonths = (period.getYears() * 12) + period.getMonths();
        int remainingDays = period.getDays();
        return totalFullMonths + (remainingDays > 0 ? 1 : 0);
    }

    private String getConfig(Map<String, String> configs, String key, String defaultValue) {
        return configs.getOrDefault(key, defaultValue);
    }
}

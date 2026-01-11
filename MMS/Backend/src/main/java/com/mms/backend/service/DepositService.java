package com.mms.backend.service;

import com.mms.backend.dto.DepositSummaryDTO;
import com.mms.backend.dto.DepositDetailDTO;
import com.mms.backend.dto.UpdateDepositRequest;
import com.mms.backend.entity.*;

import com.mms.backend.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Period;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import com.mms.backend.dto.CreateDepositRequest;
import java.time.LocalDateTime;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

@Service
public class DepositService {

    private static final Logger logger = LoggerFactory.getLogger(DepositService.class);

    @Autowired
    private CustomerDepositEntryRepository depositRepository;
    @Autowired
    private CustomerDepositItemsRepository itemsRepository;
    @Autowired
    private CustomerDepositTransactionRepository transactionRepository;
    @Autowired
    private ItemPriceHistoryRepository priceRepository;
    @Autowired
    private CustomerMasterRepository customerRepository;
    @Autowired
    private ItemMasterRepository itemRepository;
    @Autowired
    private UnitMasterRepository unitRepository;
    @Autowired
    private MerchantItemEntryRepository merchantEntryRepository;
    @Autowired
    private MerchantItemTransactionRepository merchantTransactionRepository;
    @Autowired
    private ConfigPropertyRepository configRepository;

    @Autowired
    private PriceService priceService;

    public boolean hasActiveMerchantItems(Long depositId) {
        return merchantEntryRepository.countActiveByDepositId(depositId) > 0;
    }

    public boolean isTokenExists(Integer tokenNo) {
        return depositRepository.existsByTokenNo(tokenNo);
    }

    public Integer generateNextToken() {
        Integer maxToken = depositRepository.findMaxTokenNo();
        return (maxToken == null) ? 1 : maxToken + 1;
    }

    @Transactional(readOnly = true)
    public List<com.mms.backend.dto.MerchantItemDTO> getActiveMerchantPledges(Long depositId) {
        return merchantEntryRepository.findActiveByDepositId(depositId).stream().map(entry -> {
            com.mms.backend.dto.MerchantItemDTO dto = new com.mms.backend.dto.MerchantItemDTO();
            dto.setEntryId(entry.getId());
            dto.setMerchantName(entry.getMerchant().getMerchantName());
            dto.setMerchantId(entry.getMerchant().getId());
            dto.setItemName(entry.getCustomerDepositItem().getItem().getItemName());
            dto.setFineWeight(entry.getCustomerDepositItem().getFineWeight());
            dto.setPrincipalAmount(entry.getPrincipalAmount());
            dto.setEntryDate(entry.getEntryDate());
            dto.setStatus(entry.getEntryStatus());
            // Calculate Merchant Interest
            long daysElapsed = ChronoUnit.DAYS.between(entry.getEntryDate(), LocalDate.now());
            // Minimum 1 day or similar rule?
            if (daysElapsed < 0)
                daysElapsed = 0;

            // Base Financials
            BigDecimal principal = entry.getPrincipalAmount();
            BigDecimal rate = entry.getInterestRate() != null ? entry.getInterestRate() : BigDecimal.ZERO;

            // Monthly Interest Amount: (P * R) / 100
            BigDecimal monthlyInterest = principal.multiply(rate).divide(BigDecimal.valueOf(100), 2,
                    RoundingMode.HALF_UP);
            dto.setMonthlyInterestAmount(monthlyInterest);

            // Business Profitability (Interest Margin)
            BigDecimal custRate = entry.getCustomerDepositItem().getDepositEntry().getTotalInterestRate();
            BigDecimal custMonthlyInt = principal.multiply(custRate != null ? custRate : BigDecimal.ZERO)
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
            dto.setCustomerInterestRate(custRate);
            dto.setCustomerMonthlyInterest(custMonthlyInt);
            dto.setNetMonthlyMargin(custMonthlyInt.subtract(monthlyInterest));

            // Calculate Duration
            LocalDate endDate = ("RETURNED".equals(entry.getEntryStatus()) && entry.getUpdatedDate() != null)
                    ? entry.getUpdatedDate().toLocalDate()
                    : LocalDate.now();

            Period period = Period.between(entry.getEntryDate(), endDate);
            int totalMonths = (period.getYears() * 12) + period.getMonths();
            if (period.getDays() > 0 || totalMonths == 0) {
                totalMonths++;
            }
            dto.setMonthsDuration(totalMonths);

            // Total Accrued Interest
            BigDecimal interest = monthlyInterest.multiply(BigDecimal.valueOf(totalMonths));

            dto.setInterestRate(rate);
            dto.setAccruedInterest(interest);
            dto.setTotalOwed(principal.add(interest));

            // Populate Transactions for Full Log
            java.util.List<com.mms.backend.dto.MerchantTransactionDTO> txDtos = new java.util.ArrayList<>();

            // 1. Synthesize Initial Pledge Transaction
            com.mms.backend.dto.MerchantTransactionDTO opening = new com.mms.backend.dto.MerchantTransactionDTO();
            opening.setTransactionType("PLEDGE");
            opening.setAmount(entry.getPrincipalAmount());
            opening.setTransactionDate(entry.getEntryDate());
            opening.setDescription("Initial Pledge - " + entry.getCustomerDepositItem().getItem().getItemName());
            txDtos.add(opening);

            // 2. Synthesize Monthly Interest Accrued Logs (Requested breakdown)
            for (int i = 1; i <= totalMonths; i++) {
                com.mms.backend.dto.MerchantTransactionDTO intTx = new com.mms.backend.dto.MerchantTransactionDTO();
                intTx.setTransactionType("INTEREST_ACCRUED");
                intTx.setAmount(monthlyInterest);
                intTx.setTransactionDate(entry.getEntryDate().plusMonths(i - 1));
                intTx.setDescription("Monthly Interest Charge - Month " + i);
                txDtos.add(intTx);
            }

            // 3. Fetch and Map real transactions
            var txs = merchantTransactionRepository.findByMerchantItemEntryId(entry.getId());
            BigDecimal tPrincipalPaid = BigDecimal.ZERO;
            BigDecimal tInterestPaid = BigDecimal.ZERO;

            for (var t : txs) {
                com.mms.backend.dto.MerchantTransactionDTO td = new com.mms.backend.dto.MerchantTransactionDTO();
                td.setId(t.getId());
                td.setTransactionType(t.getTransactionType());
                td.setAmount(t.getAmount());
                td.setTransactionDate(t.getTransactionDate());
                td.setDescription(t.getDescription());
                txDtos.add(td);

                if ("PRINCIPAL_PAYMENT".equals(t.getTransactionType())) {
                    tPrincipalPaid = tPrincipalPaid.add(t.getAmount());
                } else if ("INTEREST_PAYMENT".equals(t.getTransactionType())) {
                    tInterestPaid = tInterestPaid.add(t.getAmount());
                } else if ("RETURN".equals(t.getTransactionType())) {
                    tPrincipalPaid = tPrincipalPaid.add(t.getAmount());
                }
            }

            // 4. Synthesize RETURN & Final Settlement for Status consistency
            boolean hasReturn = txDtos.stream()
                    .anyMatch(t -> "RETURN".equals(t.getTransactionType()));

            if ("RETURNED".equals(entry.getEntryStatus())) {
                if (!hasReturn) {
                    com.mms.backend.dto.MerchantTransactionDTO closeTx = new com.mms.backend.dto.MerchantTransactionDTO();
                    closeTx.setTransactionType("RETURN");
                    closeTx.setAmount(principal);
                    closeTx.setTransactionDate(endDate);
                    closeTx.setDescription("Item Returned to Inventory");
                    txDtos.add(closeTx);
                }

                // If it's returned, we consider the principal recovered in the balance
                if (tPrincipalPaid.compareTo(principal) < 0) {
                    tPrincipalPaid = principal;
                }

                // Also assume Interest was paid if it's returned and not in log
                boolean hasIntPayment = txDtos.stream()
                        .anyMatch(t -> "INTEREST_PAYMENT".equals(t.getTransactionType()));
                if (!hasIntPayment && interest.compareTo(BigDecimal.ZERO) > 0) {
                    com.mms.backend.dto.MerchantTransactionDTO iPay = new com.mms.backend.dto.MerchantTransactionDTO();
                    iPay.setTransactionType("INTEREST_PAYMENT");
                    iPay.setAmount(interest);
                    iPay.setTransactionDate(endDate);
                    iPay.setDescription("Interest Settled on Return");
                    txDtos.add(iPay);
                    tInterestPaid = tInterestPaid.add(interest);
                }
            }

            dto.setTotalPrincipalPaid(tPrincipalPaid);
            dto.setTotalInterestPaid(tInterestPaid);

            // Correct Owed: (Principal + Total Int) - (Principal Paid + Interest Paid)
            BigDecimal remainingOwed = principal.add(interest).subtract(tPrincipalPaid).subtract(tInterestPaid);
            if (remainingOwed.compareTo(BigDecimal.ZERO) < 0)
                remainingOwed = BigDecimal.ZERO;

            dto.setTotalOwed(remainingOwed);

            // Final Sorting by Date and logically by Type Priority
            txDtos.sort((a, b) -> {
                int dateComp = a.getTransactionDate().compareTo(b.getTransactionDate());
                if (dateComp != 0)
                    return dateComp;

                // Priority map
                java.util.Map<String, Integer> p = new java.util.HashMap<>();
                p.put("PLEDGE", 0);
                p.put("INTEREST_ACCRUED", 1);
                p.put("INTEREST_PAYMENT", 2);
                p.put("PRINCIPAL_PAYMENT", 2);
                p.put("RETURN", 3);

                int p1 = p.getOrDefault(a.getTransactionType(), 99);
                int p2 = p.getOrDefault(b.getTransactionType(), 99);
                return Integer.compare(p1, p2);
            });

            dto.setTransactions(txDtos);

            return dto;
        }).collect(Collectors.toList());
    }

    @Transactional
    public void createDeposit(CreateDepositRequest request) {
        logger.info("[SERVICE] Creating Deposit. Token: {}, CustomerID: {}", request.getTokenNo(),
                request.getCustomerId());
        // 1. Create Entry
        CustomerDepositEntry entry = new CustomerDepositEntry();
        entry.setCustomer(
                customerRepository.findById(java.util.Objects.requireNonNull(request.getCustomerId())).orElseThrow());
        entry.setDepositDate(request.getDepositDate());
        entry.setTotalInterestRate(request.getInterestRate());
        entry.setNotes(request.getNotes());
        entry.setTokenNo(request.getTokenNo());
        entry.setCreatedDate(LocalDateTime.now());
        entry = depositRepository.save(entry);

        // 2. Create Items
        if (request.getItems() != null) {
            for (var itemReq : request.getItems()) {
                CustomerDepositItems item = new CustomerDepositItems();
                item.setDepositEntry(entry);
                item.setItem(
                        itemRepository.findById(java.util.Objects.requireNonNull(itemReq.getItemId())).orElseThrow());
                item.setItemDate(request.getDepositDate());
                item.setWeightReceived(itemReq.getWeight());
                item.setWeightUnit(
                        unitRepository.findById(java.util.Objects.requireNonNull(itemReq.getUnitId())).orElseThrow());
                item.setFineWeight(itemReq.getFineWeight());
                item.setItemDescription(itemReq.getDescription());
                item.setCreatedDate(LocalDateTime.now());
                itemsRepository.save(item);
            }
        }

        // 3. Create Transaction (Initial Loan)
        if (request.getInitialLoanAmount() != null && request.getInitialLoanAmount().compareTo(BigDecimal.ZERO) > 0) {
            CustomerDepositTransaction tx = new CustomerDepositTransaction();
            tx.setDepositEntry(entry);
            tx.setTransactionType("INITIAL_MONEY");
            tx.setAmount(request.getInitialLoanAmount());
            tx.setTransactionDate(request.getDepositDate());
            tx.setCreatedDate(LocalDateTime.now());
            transactionRepository.save(tx);
        }
    }

    @Transactional(readOnly = true)
    public List<DepositSummaryDTO> getActiveDepositSummary() {
        logger.info("[SERVICE] Fetching Active Deposit Summaries.");
        List<CustomerDepositEntry> activeDeposits = depositRepository.findAllActiveWithCustomer();
        List<DepositSummaryDTO> summaries = new ArrayList<>();

        // Pre-fetch latest prices for all items to avoid N+1 problem
        Map<Integer, ItemPriceHistory> latestPricesMap = priceRepository.findLatestPricePerItem()
                .stream()
                .filter(iph -> iph != null && iph.getItem() != null && iph.getItem().getId() != null)
                .collect(Collectors.toMap(
                        iph -> iph.getItem().getId(),
                        iph -> iph,
                        (existing, replacement) -> existing));

        // Fetch Configs
        Map<String, String> configs = configRepository.findAll().stream()
                .collect(Collectors.toMap(ConfigProperty::getPropertyKey, ConfigProperty::getPropertyValue,
                        (a, b) -> a));

        boolean roundUp = "true".equalsIgnoreCase(getConfig(configs, "system.calendar.months.round_up", "false"));
        BigDecimal riskThreshold = new BigDecimal(getConfig(configs, "system.risk.threshold.percentage", "100"));

        for (CustomerDepositEntry deposit : activeDeposits) {
            DepositSummaryDTO dto = new DepositSummaryDTO();
            dto.setDepositId(deposit.getId());
            dto.setCustomerName(deposit.getCustomer() != null ? deposit.getCustomer().getCustomerName() : "Unknown");
            dto.setDepositDate(deposit.getDepositDate());

            // 1. Calculate Financials from Transactions
            List<CustomerDepositTransaction> transactions = transactionRepository
                    .findByDepositEntry_Id(deposit.getId());

            BigDecimal loanAmount = BigDecimal.ZERO;
            BigDecimal interestAccruedPosted = BigDecimal.ZERO;
            BigDecimal interestPaid = BigDecimal.ZERO;

            for (CustomerDepositTransaction tx : transactions) {
                switch (tx.getTransactionType()) {
                    case "INITIAL_MONEY":
                    case "EXTRA_WITHDRAWAL":
                        loanAmount = loanAmount.add(tx.getAmount());
                        break;
                    case "INTEREST_RECEIVED": // Interest charged to customer
                        interestAccruedPosted = interestAccruedPosted.add(tx.getAmount());
                        break;
                    case "INTEREST_PAYMENT": // Customer pays interest
                        interestPaid = interestPaid.add(tx.getAmount());
                        break;
                    case "PRINCIPAL_PAYMENT": // Customer pays back loan (Hypothetical type)
                        loanAmount = loanAmount.subtract(tx.getAmount());
                        break;
                }
            }

            // Calculate Projected Interest (Simple Interest for now)
            // Interest = Principal * (Rate/100) * (Months)
            // This is a simplified logic. In real MMS, it's complex.
            // We'll use the "Posted" interest if available, OR calculate if 0.
            // For this task, "current time" implies we should calculate it.

            long daysElapsed = ChronoUnit.DAYS.between(deposit.getDepositDate(), LocalDate.now());

            // Human readable month/day display using standard Calendar logic (Period)
            Period period = Period.between(deposit.getDepositDate(), LocalDate.now());
            int totalMonths = (period.getYears() * 12) + period.getMonths();
            int displayDays = period.getDays();

            // Business Rule: Round up or Exact Month
            int interestMonths = totalMonths;
            if (roundUp && (displayDays > 0 || (totalMonths == 0 && daysElapsed >= 0))) {
                interestMonths++;
            }
            // If NOT roundUp, we still need at least 1 day logic or fractional?
            // Simplified: if not roundUp and 0 months, but days > 0, we'll keep totalMonths
            // (0)
            // But let's stay with the roundUp flag as primary.

            BigDecimal interestMonthsBD = BigDecimal.valueOf(interestMonths);

            StringBuilder actualBuilder = new StringBuilder();
            boolean hasTime = false;
            if (totalMonths > 0) {
                actualBuilder.append(totalMonths).append(totalMonths == 1 ? " month" : " months");
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

            String timeDisplay = interestMonths + (interestMonths == 1 ? " month" : " months") + " ("
                    + actualBuilder.toString() + ")";

            BigDecimal projectedInterest = loanAmount
                    .multiply(deposit.getTotalInterestRate().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP))
                    .multiply(interestMonthsBD);

            // Use the greater of posted or projected active interest for safety logic
            BigDecimal totalInterestLiability = projectedInterest.max(interestAccruedPosted);
            BigDecimal unpaidInterest = totalInterestLiability.subtract(interestPaid);

            dto.setTotalLoanAmount(loanAmount);
            dto.setTotalInterestAccrued(totalInterestLiability);
            dto.setTotalInterestPaid(interestPaid);
            dto.setUnpaidInterest(unpaidInterest);
            dto.setDepositedMonths(interestMonthsBD);
            dto.setDepositedTimeDisplay(timeDisplay);

            BigDecimal monthlyInt = loanAmount
                    .multiply(deposit.getTotalInterestRate().divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP));
            dto.setMonthlyInterest(monthlyInt);

            List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(deposit.getId());
            BigDecimal currentAssetValue = BigDecimal.ZERO;

            for (CustomerDepositItems item : items) {
                // Get latest price from our optimized map
                ItemPriceHistory latetPrice = latestPricesMap.get(item.getItem().getId());

                if (latetPrice != null) {
                    // Value = (FineWeight_In_Grams / (UnitQuantity * UnitInGram)) * Price
                    BigDecimal unitQty = item.getItem().getUnitQuantity();
                    BigDecimal unitInGram = (item.getItem().getUnit() != null)
                            ? item.getItem().getUnit().getUnitInGram()
                            : BigDecimal.ONE;

                    BigDecimal baseWeightInGrams = unitQty.multiply(unitInGram);

                    if (baseWeightInGrams.compareTo(BigDecimal.ZERO) > 0) {
                        BigDecimal itemValue = item.getFineWeight()
                                .divide(baseWeightInGrams, 6, RoundingMode.HALF_UP)
                                .multiply(latetPrice.getPrice());
                        currentAssetValue = currentAssetValue.add(itemValue);
                    }
                }
            }

            dto.setCurrentAssetValue(currentAssetValue);

            // 3. Determine Risk
            BigDecimal totalOwed = loanAmount.add(unpaidInterest);
            dto.setProfitLoss(currentAssetValue.subtract(totalOwed));

            // Risk Threshold Logic
            // If totalOwed > (currentAssetValue * riskThreshold / 100) -> RISK
            BigDecimal limitValue = currentAssetValue.multiply(riskThreshold).divide(BigDecimal.valueOf(100), 2,
                    RoundingMode.HALF_UP);

            if (totalOwed.compareTo(limitValue) > 0) {
                dto.setStatus("RISK"); // Red Color
            } else {
                dto.setStatus("SAFE");
            }

            summaries.add(dto);
        }
        return summaries;
    }

    @Transactional(readOnly = true)
    public Page<DepositSummaryDTO> getActiveDepositSummaryPaginated(int page, int size, String sortBy, String direction,
            com.mms.backend.dto.DepositFilterDTO filters) {
        logger.info("[SERVICE] Fetching Paginated Summaries. Page: {}, Size: {}, Sort: {}", page, size, sortBy);
        // 1. Get ALL data (Calculated)
        List<DepositSummaryDTO> allData = getActiveDepositSummary();

        // 2. Filter
        if (filters != null) {
            allData = allData.stream().filter(d -> {
                boolean match = true;
                if (filters.getId() != null && !filters.getId().isEmpty())
                    match = match && d.getDepositId().toString().contains(filters.getId());
                if (filters.getCustomerName() != null && !filters.getCustomerName().isEmpty())
                    match = match
                            && d.getCustomerName().toLowerCase().contains(filters.getCustomerName().toLowerCase());
                if (filters.getDepositDate() != null && !filters.getDepositDate().isEmpty())
                    match = match && d.getDepositDate().toString().contains(filters.getDepositDate());
                if (filters.getMonths() != null)
                    match = match && (d.getDepositedMonths() != null
                            && d.getDepositedMonths().intValue() >= filters.getMonths());
                if (filters.getLoanAmount() != null)
                    match = match && (d.getTotalLoanAmount() != null
                            && d.getTotalLoanAmount().compareTo(filters.getLoanAmount()) >= 0);
                if (filters.getInterest() != null)
                    match = match && (d.getTotalInterestAccrued() != null
                            && d.getTotalInterestAccrued().compareTo(filters.getInterest()) >= 0);
                if (filters.getUnpaidInterest() != null)
                    match = match && (d.getUnpaidInterest() != null
                            && d.getUnpaidInterest().compareTo(filters.getUnpaidInterest()) >= 0);
                if (filters.getAssetValue() != null)
                    match = match && (d.getCurrentAssetValue() != null
                            && d.getCurrentAssetValue().compareTo(filters.getAssetValue()) >= 0);
                if (filters.getPl() != null)
                    match = match && (d.getProfitLoss() != null && d.getProfitLoss().compareTo(filters.getPl()) >= 0);
                if (filters.getStatus() != null && !filters.getStatus().isEmpty())
                    match = match && d.getStatus().equalsIgnoreCase(filters.getStatus());

                return match;
            }).collect(Collectors.toList());
        }

        // 3. Sort
        if (sortBy != null && !sortBy.isEmpty()) {
            java.util.Comparator<DepositSummaryDTO> comparator = getComparator(sortBy);
            if (comparator != null) {
                if ("desc".equalsIgnoreCase(direction)) {
                    comparator = comparator.reversed();
                }
                allData.sort(comparator);
            }
        } else {
            // Default sort by ID desc
            allData.sort((a, b) -> b.getDepositId().compareTo(a.getDepositId()));
        }

        // 4. Page
        int start = Math.min((int) PageRequest.of(page, size).getOffset(), allData.size());
        int end = Math.min((start + size), allData.size());
        List<DepositSummaryDTO> pagedList = allData.subList(start, end);

        return new PageImpl<>(java.util.Objects.requireNonNull(pagedList), PageRequest.of(page, size), allData.size());
    }

    private java.util.Comparator<DepositSummaryDTO> getComparator(String sortBy) {
        switch (sortBy) {
            case "depositId":
                return java.util.Comparator.comparing(DepositSummaryDTO::getDepositId);
            case "customerName":
                return java.util.Comparator.comparing(d -> d.getCustomerName().toLowerCase());
            case "depositDate":
                return java.util.Comparator.comparing(DepositSummaryDTO::getDepositDate);
            case "months":
                return java.util.Comparator.comparing(DepositSummaryDTO::getDepositedMonths,
                        java.util.Comparator.nullsFirst(java.math.BigDecimal::compareTo));
            case "totalLoanAmount":
                return java.util.Comparator.comparing(DepositSummaryDTO::getTotalLoanAmount);
            case "totalInterestAccrued":
                return java.util.Comparator.comparing(DepositSummaryDTO::getTotalInterestAccrued);
            case "unpaidInterest":
                return java.util.Comparator.comparing(DepositSummaryDTO::getUnpaidInterest);
            case "currentAssetValue":
                return java.util.Comparator.comparing(DepositSummaryDTO::getCurrentAssetValue);
            case "profitLoss":
                return java.util.Comparator.comparing(DepositSummaryDTO::getProfitLoss);
            case "status":
                return java.util.Comparator.comparing(DepositSummaryDTO::getStatus);
            case "monthsWait":
                return (a, b) -> {
                    BigDecimal plA = a.getProfitLoss() != null ? a.getProfitLoss() : BigDecimal.ZERO;
                    BigDecimal plB = b.getProfitLoss() != null ? b.getProfitLoss() : BigDecimal.ZERO;
                    BigDecimal miA = a.getMonthlyInterest();
                    BigDecimal miB = b.getMonthlyInterest();

                    double valA = (miA != null && miA.doubleValue() > 0)
                            ? (plA.doubleValue() / miA.doubleValue())
                            : Double.MAX_VALUE;
                    double valB = (miB != null && miB.doubleValue() > 0)
                            ? (plB.doubleValue() / miB.doubleValue())
                            : Double.MAX_VALUE;
                    return Double.compare(valA, valB);
                };
            default:
                return java.util.Comparator.comparing(DepositSummaryDTO::getDepositId);
        }
    }

    @Transactional(readOnly = true)
    public DepositDetailDTO getDepositDetails(Integer id) {
        logger.info("[SERVICE] Fetching Deposit Details. ID: {}", id);
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

        // 1. Calculate Financials from Transactions
        List<CustomerDepositTransaction> transactions = transactionRepository
                .findByDepositEntry_Id(id);

        BigDecimal loanAmount = BigDecimal.ZERO;
        BigDecimal interestAccruedPosted = BigDecimal.ZERO;
        BigDecimal interestPaid = BigDecimal.ZERO;

        for (CustomerDepositTransaction tx : transactions) {
            switch (tx.getTransactionType()) {
                case "INITIAL_MONEY":
                case "EXTRA_WITHDRAWAL":
                    loanAmount = loanAmount.add(tx.getAmount());
                    break;
                case "INTEREST_RECEIVED":
                    interestAccruedPosted = interestAccruedPosted.add(tx.getAmount());
                    break;
                case "INTEREST_PAYMENT":
                    interestPaid = interestPaid.add(tx.getAmount());
                    break;
                case "PRINCIPAL_PAYMENT":
                    loanAmount = loanAmount.subtract(tx.getAmount());
                    break;
            }
        }

        dto.setInitialLoanAmount(loanAmount);
        dto.setTotalInterestPaid(interestPaid);

        // Calculate Duration
        long daysElapsed = ChronoUnit.DAYS.between(entry.getDepositDate(), LocalDate.now());
        Period period = Period.between(entry.getDepositDate(), LocalDate.now());
        int totalMonths = (period.getYears() * 12) + period.getMonths();
        int displayDays = period.getDays();

        // Fetch Configs
        Map<String, String> configs = configRepository.findAll().stream()
                .collect(Collectors.toMap(ConfigProperty::getPropertyKey, ConfigProperty::getPropertyValue,
                        (a, b) -> a));
        boolean roundUp = "true".equalsIgnoreCase(getConfig(configs, "system.calendar.months.round_up", "false"));
        BigDecimal riskThreshold = new BigDecimal(getConfig(configs, "system.risk.threshold.percentage", "100"));

        // Round up logic
        int interestMonths = totalMonths;
        if (roundUp && (displayDays > 0 || (totalMonths == 0 && daysElapsed >= 0))) {
            interestMonths++;
        }
        BigDecimal interestMonthsBD = BigDecimal.valueOf(interestMonths);
        dto.setDepositedMonths(interestMonthsBD);

        StringBuilder actualBuilder = new StringBuilder();
        boolean hasTime = false;
        if (totalMonths > 0) {
            actualBuilder.append(totalMonths).append(totalMonths == 1 ? " month" : " months");
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

        String formattedTime = interestMonths + (interestMonths == 1 ? " month" : " months") + " ("
                + actualBuilder.toString() + ")";
        dto.setDepositedTimeDisplay(formattedTime);

        // Projected Interest
        BigDecimal projectedInterest = loanAmount
                .multiply(entry.getTotalInterestRate().divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP))
                .multiply(interestMonthsBD);

        BigDecimal totalInterestLiability = projectedInterest.max(interestAccruedPosted);
        dto.setTotalInterestAccrued(totalInterestLiability);
        dto.setUnpaidInterest(totalInterestLiability.subtract(interestPaid));

        // 2. Asset Value
        List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(id);
        BigDecimal currentAssetValue = BigDecimal.ZERO;
        List<DepositDetailDTO.DepositItemDTO> itemDtos = new ArrayList<>();

        // Get latest prices map
        Map<Integer, ItemPriceHistory> latestPricesMap = priceRepository.findLatestPricePerItem()
                .stream()
                .collect(Collectors.toMap(
                        iph -> iph.getItem().getId(),
                        iph -> iph,
                        (ex, rep) -> ex));

        for (CustomerDepositItems item : items) {
            DepositDetailDTO.DepositItemDTO iDto = new DepositDetailDTO.DepositItemDTO();
            iDto.setId(item.getId());
            iDto.setItemId(item.getItem().getId());
            iDto.setItemName(item.getItem().getItemName());
            iDto.setWeight(item.getWeightReceived());
            iDto.setUnitId(item.getWeightUnit().getId());
            iDto.setFineWeight(item.getFineWeight());
            iDto.setDescription(item.getItemDescription());
            itemDtos.add(iDto);

            ItemPriceHistory latetPrice = latestPricesMap.get(item.getItem().getId());
            if (latetPrice != null) {
                BigDecimal unitQty = item.getItem().getUnitQuantity();
                BigDecimal unitInGram = (item.getItem().getUnit() != null)
                        ? item.getItem().getUnit().getUnitInGram()
                        : BigDecimal.ONE;
                BigDecimal baseWeightInGrams = unitQty.multiply(unitInGram);

                if (baseWeightInGrams.compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal itemValue = item.getFineWeight()
                            .divide(baseWeightInGrams, 6, RoundingMode.HALF_UP)
                            .multiply(latetPrice.getPrice());
                    currentAssetValue = currentAssetValue.add(itemValue);
                }
            }
        }
        dto.setItems(itemDtos);

        // Populate Transactions
        List<DepositDetailDTO.TransactionDTO> transactionDtos = transactions.stream().map(tx -> {
            DepositDetailDTO.TransactionDTO tDto = new DepositDetailDTO.TransactionDTO();
            tDto.setType(tx.getTransactionType());
            tDto.setAmount(tx.getAmount());
            tDto.setDate(tx.getTransactionDate());
            tDto.setDescription(tx.getDescription());
            return tDto;
        }).collect(Collectors.toList());
        dto.setTransactions(transactionDtos);

        dto.setCurrentAssetValue(currentAssetValue);

        BigDecimal totalOwed = loanAmount.add(dto.getUnpaidInterest());
        dto.setProfitLoss(currentAssetValue.subtract(totalOwed));

        // Risk Threshold Logic
        BigDecimal limitValue = currentAssetValue.multiply(riskThreshold).divide(BigDecimal.valueOf(100), 2,
                RoundingMode.HALF_UP);
        dto.setStatus(totalOwed.compareTo(limitValue) > 0 ? "RISK" : "SAFE");

        return dto;
    }

    @Transactional
    public void updateDeposit(Integer id, UpdateDepositRequest request) {
        logger.info("[SERVICE] Updating Deposit. ID: {}", id);
        try {
            CustomerDepositEntry entry = depositRepository.findById(java.util.Objects.requireNonNull(id)).orElseThrow();

            if (request.getDepositDate() != null) {
                entry.setDepositDate(request.getDepositDate());
                // Cascade update to Items
                List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(id);
                for (CustomerDepositItems item : items) {
                    item.setItemDate(request.getDepositDate());
                    itemsRepository.save(item);
                }
                // Cascade update to Initial Transaction
                List<CustomerDepositTransaction> txs = transactionRepository.findByDepositEntry_Id(id);
                for (CustomerDepositTransaction tx : txs) {
                    if ("INITIAL_MONEY".equals(tx.getTransactionType())) {
                        tx.setTransactionDate(request.getDepositDate());
                        transactionRepository.save(tx);
                    }
                }
            }

            if (request.getInterestRate() != null)
                entry.setTotalInterestRate(request.getInterestRate());
            if (request.getTokenNo() != null)
                entry.setTokenNo(request.getTokenNo());
            if (request.getNotes() != null)
                entry.setNotes(request.getNotes());

            if (request.getNotes() != null)
                entry.setNotes(request.getNotes());

            depositRepository.save(java.util.Objects.requireNonNull(entry));

            // Update Initial Loan Amount
            if (request.getInitialLoanAmount() != null) {
                CustomerDepositTransaction initialTx = transactionRepository.findByDepositEntry_Id(id).stream()
                        .filter(t -> "INITIAL_MONEY".equals(t.getTransactionType()))
                        .findFirst().orElse(null);
                if (initialTx != null) {
                    initialTx.setAmount(request.getInitialLoanAmount());
                    transactionRepository.save(initialTx);
                }
            }

            // Update Items (Smart Update Strategy to preserve Pledged Items)
            if (request.getItems() != null) {
                List<CustomerDepositItems> existingItems = itemsRepository.findByDepositEntry_Id(id);
                List<CustomerDepositItems> itemsToKeep = new ArrayList<>();
                List<com.mms.backend.dto.DepositItemRequest> itemsToCreate = new ArrayList<>(request.getItems()); // Mutable
                                                                                                                  // copy

                // Identify Pledged Items to prevent their deletion
                // We cast ID to Long for the repository method if needed, or assume Integer
                // compatibility?
                // The repo method `findActiveByDepositId` likely takes Long or Integer.
                // Based on `getActiveMerchantPledges` signature taking Long, we cast.
                List<MerchantItemEntry> activePledges = merchantEntryRepository.findActiveByDepositId(Long.valueOf(id));
                java.util.Set<Integer> pledgedItemIds = activePledges.stream()
                        .map(p -> p.getCustomerDepositItem().getId())
                        .collect(java.util.stream.Collectors.toSet());

                for (CustomerDepositItems existing : existingItems) {
                    boolean isPledged = pledgedItemIds.contains(existing.getId());

                    // Try to find a match in the Request (Exact Match Logic)
                    int matchIndex = -1;
                    for (int i = 0; i < itemsToCreate.size(); i++) {
                        var req = itemsToCreate.get(i);
                        // Helper comparison for BigDecimals
                        boolean sameItem = req.getItemId().equals(existing.getItem().getId());
                        // Robust Unit handling: null safe
                        int reqUnitId = req.getUnitId() != null ? req.getUnitId() : 1;
                        boolean sameUnit = (existing.getWeightUnit() != null)
                                && (existing.getWeightUnit().getId() == reqUnitId);

                        boolean sameWeight = req.getWeight().compareTo(existing.getWeightReceived()) == 0;
                        boolean sameFine = req.getFineWeight().compareTo(existing.getFineWeight()) == 0;

                        if (sameItem && sameUnit && sameWeight && sameFine) {
                            matchIndex = i;
                            break;
                        }
                    }

                    if (matchIndex != -1) {
                        // Match Found -> Keep Existing
                        // Update mutable fields if any? (Description only, since weights matched)
                        var req = itemsToCreate.get(matchIndex);
                        existing.setItemDescription(req.getDescription());
                        itemsRepository.save(existing);

                        itemsToKeep.add(existing);
                        itemsToCreate.remove(matchIndex); // Consumed
                    } else {
                        // No Match -> Candidate for Deletion
                        if (isPledged) {
                            // Critical Guard: Cannot delete matched pledged item even if changed
                            // But wait, if it didn't match, maybe the user *edited* the weight?
                            // If user edited weight of a pledged item, we must BLOCK it or Update inplace?
                            // For now, BLOCKING is safest.
                            throw new RuntimeException("Cannot modify or remove Item '" + existing.getItemDescription()
                                    + "' because it is currently pledged to a Merchant. Please return the pledge first.");
                        }
                        // Else: Safe to delete (will be deleted below)
                    }
                }

                // Delete items that are NOT in itemsToKeep
                existingItems.removeAll(itemsToKeep);
                if (!existingItems.isEmpty()) {
                    itemsRepository.deleteAll(existingItems);
                }

                // Create New Items matches
                for (var itemReq : itemsToCreate) {
                    CustomerDepositItems item = new CustomerDepositItems();
                    item.setDepositEntry(entry);
                    item.setItem(itemRepository.findById(java.util.Objects.requireNonNull(itemReq.getItemId()))
                            .orElseThrow());
                    item.setItemDate(entry.getDepositDate());
                    item.setWeightReceived(itemReq.getWeight());

                    Integer uId = itemReq.getUnitId();
                    if (uId == null)
                        uId = 1;
                    item.setWeightUnit(unitRepository.findById(uId)
                            .orElseThrow(() -> new RuntimeException("Unit not found: " + itemReq.getUnitId())));

                    item.setFineWeight(itemReq.getFineWeight());
                    item.setItemDescription(itemReq.getDescription());
                    item.setCreatedDate(LocalDateTime.now());
                    itemsRepository.save(item);
                }
            }
        } catch (Exception e) {
            logger.error("Error updating deposit", e);
            throw new RuntimeException("Error updating deposit: " + e.getMessage());
        }
    }

    @Transactional
    public void addPaymentTransaction(Integer depositId, com.mms.backend.dto.RedemptionRequest request) {
        logger.info("[SERVICE] Adding Payment Transaction. Deposit ID: {}", depositId);
        CustomerDepositEntry entry = depositRepository.findById(java.util.Objects.requireNonNull(depositId))
                .orElseThrow(() -> new RuntimeException("Deposit not found"));

        // 1. Principal Payment (Customer pays back loan) - reduces loan
        if (request.getPrincipalPaid() != null && request.getPrincipalPaid().compareTo(BigDecimal.ZERO) > 0) {
            CustomerDepositTransaction tx = new CustomerDepositTransaction();
            tx.setDepositEntry(entry);
            tx.setTransactionType("PRINCIPAL_PAYMENT");
            tx.setAmount(request.getPrincipalPaid());
            tx.setTransactionDate(LocalDate.now());
            tx.setDescription(request.getNotes());
            tx.setCreatedDate(LocalDateTime.now());
            transactionRepository.save(tx);
        }

        // 2. Interest Payment (Customer pays interest) - income
        if (request.getInterestPaid() != null && request.getInterestPaid().compareTo(BigDecimal.ZERO) > 0) {
            CustomerDepositTransaction tx = new CustomerDepositTransaction();
            tx.setDepositEntry(entry);
            tx.setTransactionType("INTEREST_PAYMENT");
            tx.setAmount(request.getInterestPaid());
            tx.setTransactionDate(LocalDate.now());
            tx.setDescription(request.getNotes());
            tx.setCreatedDate(LocalDateTime.now());
            transactionRepository.save(tx);
        }

        entry.setUpdatedDate(LocalDateTime.now());
        depositRepository.save(entry);
    }

    @Transactional
    public void closeDeposit(Integer id) {
        logger.info("[SERVICE] Closing Deposit. ID: {}", id);
        CustomerDepositEntry entry = depositRepository.findById(java.util.Objects.requireNonNull(id))
                .orElseThrow(() -> new RuntimeException("Deposit not found"));
        // entry.setIsActive(false); // User requested NOT to update isActive
        entry.setEntryStatus("CLOSED");
        entry.setUpdatedDate(LocalDateTime.now());
        depositRepository.save(entry);

        // Update items status explicitly in DB
        List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(id);
        for (CustomerDepositItems item : items) {
            item.setItemStatus("RETURNED");
            item.setUpdatedDate(LocalDateTime.now());
            itemsRepository.save(item);
        }
    }

    @Transactional(readOnly = true)
    public List<com.mms.backend.dto.CustomerItemDTO> getCustomerItems(Integer customerId) {
        logger.info("[SERVICE] Fetching Items for Customer ID: {}", customerId);
        List<CustomerDepositEntry> deposits = depositRepository.findAll().stream()
                .filter(d -> d.getCustomer().getId().equals(customerId))
                .collect(Collectors.toList());

        List<com.mms.backend.dto.CustomerItemDTO> items = new ArrayList<>();

        for (CustomerDepositEntry deposit : deposits) {
            List<com.mms.backend.entity.CustomerDepositItems> realItems = itemsRepository
                    .findByDepositEntry_Id(deposit.getId());

            for (com.mms.backend.entity.CustomerDepositItems item : realItems) {
                com.mms.backend.dto.CustomerItemDTO dto = new com.mms.backend.dto.CustomerItemDTO();
                dto.setDepositId(deposit.getId());
                dto.setDepositDate(deposit.getDepositDate());
                dto.setDepositStatus(deposit.getEntryStatus());

                dto.setItemLineId(item.getId());
                dto.setItemName(item.getItem().getItemName());
                dto.setWeight(item.getWeightReceived());
                dto.setFineWeight(item.getFineWeight());
                dto.setDescription(item.getItemDescription());

                // Calculate current value
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

        // Sort by Date DESC
        items.sort((a, b) -> b.getDepositDate().compareTo(a.getDepositDate()));

        return items;
    }

    @Transactional(readOnly = true)
    public com.mms.backend.dto.CustomerPortfolioDTO getCustomerPortfolio(Integer customerId) {
        logger.info("[SERVICE] Fetching Portfolio for Customer ID: {}", customerId);
        CustomerMaster customer = customerRepository.findById(java.util.Objects.requireNonNull(customerId))
                .orElseThrow(() -> new RuntimeException("Customer not found"));

        List<CustomerDepositEntry> deposits = depositRepository.findAll().stream()
                .filter(d -> d.getCustomer().getId().equals(customerId))
                .collect(Collectors.toList());

        com.mms.backend.dto.CustomerPortfolioDTO portfolio = new com.mms.backend.dto.CustomerPortfolioDTO();
        portfolio.setCustomerId(customer.getId());
        portfolio.setCustomerName(customer.getCustomerName());
        portfolio.setMobileNumber(customer.getMobileNumber());
        portfolio.setAddress(customer.getAddress());
        portfolio.setCity(customer.getDistrict()); // Assuming district ~ city

        long activeCount = deposits.stream().filter(d -> "ACTIVE".equals(d.getEntryStatus())).count();
        portfolio.setActiveDeposits(activeCount);
        portfolio.setHasItems(activeCount > 0);

        List<com.mms.backend.dto.CustomerPortfolioDTO.PortfolioDepositDTO> depositDTOs = new ArrayList<>();

        for (CustomerDepositEntry deposit : deposits) {
            com.mms.backend.dto.CustomerPortfolioDTO.PortfolioDepositDTO depDto = new com.mms.backend.dto.CustomerPortfolioDTO.PortfolioDepositDTO();
            depDto.setDepositId(deposit.getId());
            depDto.setDepositDate(deposit.getDepositDate());
            depDto.setStatus(deposit.getEntryStatus());

            // 1. Transaction Stats & Loan Calculation
            List<CustomerDepositTransaction> txs = transactionRepository.findByDepositEntry_Id(deposit.getId());

            BigDecimal principalPaid = txs.stream()
                    .filter(t -> "PRINCIPAL_PAYMENT".equals(t.getTransactionType()))
                    .map(CustomerDepositTransaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BigDecimal originalLoan = txs.stream()
                    .filter(t -> "PRINCIPAL_LOAN".equals(t.getTransactionType()) ||
                            "INITIAL_MONEY".equals(t.getTransactionType()) ||
                            "EXTRA_WITHDRAWAL".equals(t.getTransactionType()))
                    .map(CustomerDepositTransaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            depDto.setInitialLoanAmount(originalLoan);

            // Handle Implied Payment for manually CLOSED deposits
            if ("CLOSED".equals(deposit.getEntryStatus()) && principalPaid.compareTo(BigDecimal.ZERO) == 0) {
                principalPaid = originalLoan;
            }
            depDto.setLoanAmount(originalLoan.subtract(principalPaid));

            // NEW LOGIC START
            BigDecimal interestPaid = txs.stream()
                    .filter(t -> "INTEREST_PAYMENT".equals(t.getTransactionType()))
                    .map(CustomerDepositTransaction::getAmount)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            depDto.setPaidPrincipal(principalPaid);
            depDto.setPaidInterest(interestPaid);
            depDto.setInterestRate(deposit.getTotalInterestRate());

            // 2. Monthly Interest (Base for reference)
            BigDecimal monthlyInterestAmount = originalLoan
                    .multiply(deposit.getTotalInterestRate())
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
            depDto.setMonthlyInterest(monthlyInterestAmount);

            // 3. Duration & Accrued Interest Calculation (Calendar Month Ceiling Logic)
            // User Rule: End Date is INCLUSIVE.
            // Logic: 1-Oct to 1-Jan = 3 Months + 1 Day (Jan 1st counts) -> Charged as 4
            // Months.

            LocalDate endDate = ("CLOSED".equals(deposit.getEntryStatus()) && deposit.getUpdatedDate() != null)
                    ? deposit.getUpdatedDate().toLocalDate()
                    : LocalDate.now();

            if ("CLOSED".equals(deposit.getEntryStatus())) {
                depDto.setEndDate(endDate);
            }

            // Inclusive End Date -> Add 1 Day to effective end for calculations
            LocalDate effectiveEndDate = endDate.plusDays(1);
            Period period = Period.between(deposit.getDepositDate(), effectiveEndDate);

            int totalFullMonths = (period.getYears() * 12) + period.getMonths();
            int remainingDays = period.getDays();

            // Interest Steps: Full Months + (Any partial days count as a 1 full month)
            int interestMonths = totalFullMonths + (remainingDays > 0 ? 1 : 0);

            // Format: "4 months (3 months 1 days)"
            String duration = interestMonths + " months";
            if (totalFullMonths > 0 || remainingDays > 0) {
                duration += " (";
                if (totalFullMonths > 0)
                    duration += totalFullMonths + " months ";
                if (remainingDays > 0)
                    duration += remainingDays + " days";
                duration = duration.trim() + ")";
            }

            // Adjust for 0 case
            if (totalFullMonths == 0 && remainingDays == 0)
                duration = "0 days";

            depDto.setDurationDisplay(duration);

            // Accrued Calculation: Based on CEILING months
            // Formula: (P * R * CeilingMonths) / 100
            BigDecimal accrued = originalLoan
                    .multiply(deposit.getTotalInterestRate())
                    .multiply(BigDecimal.valueOf(interestMonths))
                    .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);

            depDto.setAccruedInterest(accrued);

            // Handle Implied Interest Payment for manually CLOSED deposits
            if ("CLOSED".equals(deposit.getEntryStatus()) && interestPaid.compareTo(BigDecimal.ZERO) == 0) {
                depDto.setPaidInterest(accrued);
                interestPaid = accrued; // Update local var for profit calc
            }
            depDto.setAccruedInterest(accrued);

            // 4. Net Profit / Loss Calculation (Only for CLOSED deposits usually, but calc
            // for all can be informative)
            // Profit = Total In (Principal + Interest) - Total Out (Initial Loan)
            BigDecimal totalIn = principalPaid.add(interestPaid);
            BigDecimal netProfit = totalIn.subtract(originalLoan);
            depDto.setNetProfitLoss(netProfit);

            // NEW LOGIC END

            List<com.mms.backend.dto.CustomerPortfolioDTO.PortfolioItemDTO> itemDTOs = new ArrayList<>();
            List<CustomerDepositItems> items = itemsRepository.findByDepositEntry_Id(deposit.getId());

            for (CustomerDepositItems item : items) {
                com.mms.backend.dto.CustomerPortfolioDTO.PortfolioItemDTO itemDto = new com.mms.backend.dto.CustomerPortfolioDTO.PortfolioItemDTO();
                itemDto.setItemName(item.getItem().getItemName());
                itemDto.setWeight(item.getWeightReceived());
                itemDto.setFineWeight(item.getFineWeight());

                if ("CLOSED".equals(deposit.getEntryStatus())) {
                    itemDto.setStatus("RETURNED");
                } else {
                    itemDto.setStatus(item.getItemStatus());
                }

                try {
                    BigDecimal val = priceService.calculateAssetValue(item.getItem().getId(), item.getFineWeight());
                    itemDto.setCurrentAssetValue(val);
                } catch (Exception e) {
                    itemDto.setCurrentAssetValue(BigDecimal.ZERO);
                }
                itemDTOs.add(itemDto);
            }
            depDto.setItems(itemDTOs);

            // Populate Transactions
            List<com.mms.backend.dto.CustomerPortfolioDTO.PortfolioTransactionDTO> transDTOs = txs.stream()
                    .sorted((t1, t2) -> t2.getTransactionDate().compareTo(t1.getTransactionDate()))
                    .map(t -> {
                        com.mms.backend.dto.CustomerPortfolioDTO.PortfolioTransactionDTO tDto = new com.mms.backend.dto.CustomerPortfolioDTO.PortfolioTransactionDTO();
                        tDto.setDate(t.getTransactionDate());
                        tDto.setType(t.getTransactionType());
                        tDto.setAmount(t.getAmount());
                        tDto.setNotes(t.getDescription());
                        return tDto;
                    })
                    .collect(java.util.stream.Collectors.toList());
            depDto.setTransactions(transDTOs);

            depositDTOs.add(depDto);
        }

        // Sort deposits: Active first, then by Date Desc
        depositDTOs.sort((a, b) -> {
            if (a.getStatus().equals("ACTIVE") && !b.getStatus().equals("ACTIVE"))
                return -1;
            if (!a.getStatus().equals("ACTIVE") && b.getStatus().equals("ACTIVE"))
                return 1;
            return b.getDepositDate().compareTo(a.getDepositDate());
        });

        portfolio.setDeposits(depositDTOs);
        return portfolio;
    }

    private String getConfig(Map<String, String> configs, String key, String defaultValue) {
        String val = configs.get(key);
        if (val == null || val.trim().isEmpty()) {
            return defaultValue;
        }
        return val;
    }
}

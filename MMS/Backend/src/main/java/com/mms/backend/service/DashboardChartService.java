package com.mms.backend.service;

import com.mms.backend.dto.ChartDataDTO;
import com.mms.backend.dto.DashboardStatsDTO;
import com.mms.backend.dto.DepositSummaryDTO;
import com.mms.backend.repository.CustomerDepositEntryRepository;
import com.mms.backend.repository.CustomerDepositTransactionRepository;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DashboardChartService {

    private final CustomerDepositTransactionRepository depositTxRepository;
    private final CustomerDepositEntryRepository depositRepository;
    private final DepositQueryService depositQueryService;

    public DashboardStatsDTO getDashboardStats() {
        List<DepositSummaryDTO> summaries = depositQueryService.getActiveDepositSummary();

        BigDecimal totalLoan = BigDecimal.ZERO;
        BigDecimal totalInterest = BigDecimal.ZERO;

        for (DepositSummaryDTO s : summaries) {
            totalLoan = totalLoan.add(s.getTotalLoanAmount());
            totalInterest = totalInterest.add(s.getTotalInterestAccrued());
        }

        LocalDate today = LocalDate.now();

        // Today's Active (New Deposits Created Today)
        long todayActiveCount = depositRepository.countByDepositDate(today);
        BigDecimal todayActiveBD = BigDecimal.valueOf(todayActiveCount);

        // Today's Closed (Deposits Closed Today)
        java.time.LocalDateTime startOfDay = today.atStartOfDay();
        java.time.LocalDateTime endOfDay = today.atTime(java.time.LocalTime.MAX);
        long todayClosedCount = depositRepository.countByEntryStatusAndUpdatedDateBetween(
                com.mms.backend.util.Constants.STATUS_CLOSED, startOfDay,
                endOfDay);
        BigDecimal todayClosedBD = BigDecimal.valueOf(todayClosedCount);

        long closedCount = depositRepository.countByEntryStatus(com.mms.backend.util.Constants.STATUS_CLOSED);

        LocalDate minDate = depositRepository
                .findMinDepositDateByEntryStatus(com.mms.backend.util.Constants.STATUS_ACTIVE);
        LocalDate maxDate = depositRepository
                .findMaxDepositDateByEntryStatus(com.mms.backend.util.Constants.STATUS_ACTIVE);

        return DashboardStatsDTO.builder()
                .totalActiveDeposits((long) summaries.size())
                .totalClosedDeposits(closedCount)
                .totalLoanAmount(totalLoan)
                .totalInterestAccrued(totalInterest)
                .todayPurchase(todayActiveBD) // Hijacking for Count
                .todaySell(todayClosedBD) // Hijacking for Count
                .oldestActiveEntryDate(minDate)
                .latestActiveEntryDate(maxDate)
                .build();
    }

    public List<ChartDataDTO> getChartData(String period, Integer duration) {
        LocalDate endDate = LocalDate.now();
        LocalDate startDate;
        String format;

        if (com.mms.backend.util.Constants.PERIOD_MONTH.equals(period)) {
            int months = duration != null ? duration : 12;
            startDate = endDate.minusMonths(months - 1).withDayOfMonth(1);
            format = com.mms.backend.util.Constants.DATE_FORMAT_CHART_MONTH;
        } else if (com.mms.backend.util.Constants.PERIOD_YEAR.equals(period)) {
            int years = duration != null ? duration : 5;
            startDate = endDate.minusYears(years - 1).withDayOfYear(1);
            format = com.mms.backend.util.Constants.DATE_FORMAT_CHART_YEAR;
        } else if (com.mms.backend.util.Constants.PERIOD_TILL_DATE.equals(period)) {
            startDate = depositRepository.findMinDepositDateByEntryStatus(com.mms.backend.util.Constants.STATUS_ACTIVE);
            if (startDate == null)
                startDate = endDate.minusMonths(11).withDayOfMonth(1);
            format = com.mms.backend.util.Constants.DATE_FORMAT_CHART_MONTH;
        } else {
            int days = duration != null ? duration : 7;
            startDate = endDate.minusDays(days - 1);
            format = com.mms.backend.util.Constants.DATE_FORMAT_CHART_LABEL;
        }

        Map<String, ChartDataDTO> map = initializeBuckets(startDate, endDate, period, format);
        populateChartData(map, startDate, endDate, format);

        return new ArrayList<>(map.values());
    }

    private Map<String, ChartDataDTO> initializeBuckets(LocalDate startDate, LocalDate endDate, String period,
            String format) {
        Map<String, ChartDataDTO> map = new LinkedHashMap<>();
        LocalDate current = startDate;
        while (!current.isAfter(endDate)) {
            String label = current.format(DateTimeFormatter.ofPattern(format));
            map.computeIfAbsent(label, k -> {
                ChartDataDTO dto = new ChartDataDTO();
                dto.setLabel(k);
                dto.setPurchaseAmount(BigDecimal.ZERO);
                dto.setSellAmount(BigDecimal.ZERO);
                return dto;
            });

            if (com.mms.backend.util.Constants.PERIOD_MONTH.equals(period) ||
                    com.mms.backend.util.Constants.PERIOD_TILL_DATE.equals(period)) {
                current = current.plusMonths(1).withDayOfMonth(1);
            } else if (com.mms.backend.util.Constants.PERIOD_YEAR.equals(period)) {
                current = current.plusYears(1).withDayOfYear(1);
            } else {
                current = current.plusDays(1);
            }
        }
        return map;
    }

    private void populateChartData(Map<String, ChartDataDTO> map, LocalDate startDate, LocalDate endDate,
            String format) {
        List<com.mms.backend.entity.CustomerDepositTransaction> depositTxs = depositTxRepository
                .findByTransactionDateBetween(startDate, endDate);

        for (var tx : depositTxs) {
            String label = tx.getTransactionDate().format(DateTimeFormatter.ofPattern(format));
            if (map.containsKey(label)) {
                ChartDataDTO dto = map.get(label);

                if (com.mms.backend.util.Constants.TX_INITIAL_MONEY.equals(tx.getTransactionType())) {
                    dto.setPurchaseAmount(dto.getPurchaseAmount().add(tx.getAmount()));
                } else if (com.mms.backend.util.Constants.TX_PRINCIPAL_PAYMENT.equals(tx.getTransactionType()) ||
                        com.mms.backend.util.Constants.TX_INTEREST_PAYMENT.equals(tx.getTransactionType())) {
                    dto.setSellAmount(dto.getSellAmount().add(tx.getAmount()));
                }
            }
        }
    }

}

package com.mms.backend.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStatsDTO {
    private Long totalActiveDeposits;
    private Long totalClosedDeposits;
    private BigDecimal totalLoanAmount;
    private BigDecimal totalInterestAccrued;
    private BigDecimal todayPurchase;
    private BigDecimal todaySell;
}

package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class DepositSummaryDTO {
    private Integer depositId;
    private String customerName;
    private LocalDate depositDate;
    private BigDecimal totalLoanAmount;
    private BigDecimal totalInterestAccrued;
    private BigDecimal totalInterestPaid;
    private BigDecimal unpaidInterest;
    private BigDecimal currentAssetValue;
    private String status; // SAFE, RISK
    private BigDecimal profitLoss; // Asset Value - (Loan + Unpaid Interest)
    private BigDecimal depositedMonths;
    private String depositedTimeDisplay;
    private BigDecimal monthlyInterest;
}

package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class MerchantItemDTO {
    private Integer entryId;
    private Integer merchantId;
    private String merchantName;
    private Integer depositItemId;
    private String customerName;
    private String itemName;
    private BigDecimal weight;
    private BigDecimal fineWeight;
    private LocalDate entryDate;
    private BigDecimal interestRate;
    private BigDecimal principalAmount;
    private BigDecimal accruedInterest;
    private BigDecimal totalOwed;
    private BigDecimal currentAssetValue;
    private Integer monthsDuration;
    private String status;
    private BigDecimal totalPrincipalPaid;
    private BigDecimal totalInterestPaid;
    private String notes;
    private BigDecimal monthlyInterestAmount;
    private java.util.List<MerchantTransactionDTO> transactions;

    // Business Profitability Metrics
    private BigDecimal customerInterestRate;
    private BigDecimal customerMonthlyInterest;
    private BigDecimal netMonthlyMargin;
}

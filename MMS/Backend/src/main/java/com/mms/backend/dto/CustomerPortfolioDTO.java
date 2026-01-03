package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.util.List;
import java.time.LocalDate;

@Data
public class CustomerPortfolioDTO {
    // List View Data
    private Integer customerId;
    private String customerName;
    private String mobileNumber;
    private String address;
    private String city;

    // Stats
    private Long activeDeposits; // "If customer has item or not"
    private Boolean hasItems;

    // Detailed View Data (Bill Wise)
    private List<PortfolioDepositDTO> deposits;

    @Data
    public static class PortfolioDepositDTO {
        private Integer depositId;
        private LocalDate depositDate;
        private LocalDate endDate;
        private String status;

        private BigDecimal loanAmount;
        private BigDecimal initialLoanAmount;
        private BigDecimal interestRate;

        // Financials
        private BigDecimal accruedInterest;
        private BigDecimal paidPrincipal;
        private BigDecimal paidInterest;
        private BigDecimal monthlyInterest;
        private BigDecimal netProfitLoss;

        // Time
        private String durationDisplay;

        // Items in this "Bill"
        private List<PortfolioItemDTO> items;

        // Transaction History
        private List<PortfolioTransactionDTO> transactions;
    }

    @Data
    public static class PortfolioItemDTO {
        private String itemName;
        private BigDecimal weight;
        private BigDecimal fineWeight;
        private BigDecimal currentAssetValue;
        private String status;
    }

    @Data
    public static class PortfolioTransactionDTO {
        private LocalDate date;
        private String type;
        private BigDecimal amount;
        private String notes;
    }
}

package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
public class DepositDetailDTO {
    private Integer depositId;
    private Integer tokenNo;
    private Integer customerId;
    private String customerName;
    private String customerMobileNumber;
    private String customerAddress;
    private String customerCity; // Mapping 'village' or 'city'
    private String customerCaste; // Not in entity, maybe 'referralName'? Or new field?
    // Let's stick to entity fields:
    private String customerVillage;
    private String customerDistrict;
    private String customerState;
    private String customerReference;

    private LocalDate depositDate;
    private BigDecimal interestRate;
    private String notes;
    private BigDecimal initialLoanAmount; // Derived from transaction
    private BigDecimal totalInterestAccrued;
    private BigDecimal totalInterestPaid;
    private BigDecimal unpaidInterest;
    private BigDecimal currentAssetValue;
    private BigDecimal profitLoss;
    private String status;
    private BigDecimal depositedMonths;
    private String depositedTimeDisplay;
    private List<DepositItemDTO> items;
    private List<TransactionDTO> transactions;

    @Data
    static public class TransactionDTO {
        private String type;
        private BigDecimal amount;
        private LocalDate date;
        private String description;
    }

    @Data
    static public class DepositItemDTO {
        private Integer id;
        private Integer itemId;
        private String itemName;
        private BigDecimal weight;
        private Integer unitId;
        private BigDecimal fineWeight;
        private String description;
    }
}

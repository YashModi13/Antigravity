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
    private String customerCaste;
    private String customerVillage;
    private String customerDistrict;
    private String customerState;
    private String customerPincode;
    private String customerEmail;
    private Boolean customerKycVerified;
    private Integer customerReferenceId;
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
    private Boolean isVerified;
    private List<DepositItemDTO> items;
    private List<TransactionDTO> transactions;

    @Data
    public static class TransactionDTO {
        private String type;
        private BigDecimal amount;
        private LocalDate date;
        private String description;
    }

    @Data
    public static class DepositItemDTO {
        private Integer id;
        private Integer itemId;
        private String itemName;
        private BigDecimal weight;
        private Integer unitId;
        private BigDecimal fineWeight;
        private String description;
    }
}

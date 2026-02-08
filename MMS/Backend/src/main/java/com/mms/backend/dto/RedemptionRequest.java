package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class RedemptionRequest {
    private BigDecimal principalPaid;
    private BigDecimal interestPaid;
    private BigDecimal totalPaid;
    private String notes;

    // Support for adding extra principal (withdrawal)
    private BigDecimal extraPrincipal;
    private BigDecimal discountAmount; // For waivers/kasar
    private java.time.LocalDate transactionDate;
}

package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
public class UpdateDepositRequest {
    private LocalDate depositDate;
    private BigDecimal interestRate;
    private String notes;
    // Full Edit Support
    private BigDecimal initialLoanAmount;
    private List<DepositItemRequest> items;
}

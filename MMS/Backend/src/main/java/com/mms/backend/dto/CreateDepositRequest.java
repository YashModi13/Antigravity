package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
public class CreateDepositRequest {
    private Integer customerId;
    private LocalDate depositDate;
    private BigDecimal interestRate;
    private String notes;
    private List<DepositItemRequest> items;
    private BigDecimal initialLoanAmount;
    private Integer tokenNo;
}

package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class B2BTransferRequest {
    private Integer depositItemId;
    private Integer merchantId;
    private BigDecimal interestRate;
    private BigDecimal principalAmount;
    private LocalDate entryDate;
    private String notes;
}

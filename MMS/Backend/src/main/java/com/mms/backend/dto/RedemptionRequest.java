package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class RedemptionRequest {
    private BigDecimal principalPaid;
    private BigDecimal interestPaid;
    private BigDecimal totalPaid;
    private String notes;
}

package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DepositItemRequest {
    private Integer itemId;
    private BigDecimal weight;
    private Integer unitId;
    private BigDecimal fineWeight;
    private String description;
}

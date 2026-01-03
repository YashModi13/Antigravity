package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class ChartDataDTO {
    private String label; // e.g., "Mon", "Jan", "2023"
    private BigDecimal purchaseAmount;
    private BigDecimal sellAmount;
}

package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class CustomerItemDTO {
    private Integer depositId;
    private LocalDate depositDate;
    private String depositStatus;

    private Integer itemLineId;
    private String itemName;
    private BigDecimal weight;
    private BigDecimal fineWeight;
    private BigDecimal currentAssetValue;
    private String description;
}

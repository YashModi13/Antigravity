package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class AvailableItemDTO {
    private Integer id;
    private Integer depositEntryId;
    private String customerName;
    private String itemName;
    private BigDecimal weight;
    private BigDecimal fineWeight;
    private BigDecimal currentAssetValue;
    private String itemStatus;
}

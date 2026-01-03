package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DepositFilterDTO {
    private String id;
    private String customerName;
    private String depositDate;
    private Integer months;
    private BigDecimal loanAmount;
    private BigDecimal interest;
    private BigDecimal unpaidInterest;
    private BigDecimal assetValue;
    private BigDecimal pl;
    private String status;
}

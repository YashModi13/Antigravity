package com.mms.backend.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DepositFilterDTO {
    private String id;
    private String tokenNo;
    private String customerName;
    private String depositDate;
    private Integer months;
    private BigDecimal loanAmount;
    private BigDecimal interest;
    private BigDecimal unpaidInterest;
    private BigDecimal assetValue;
    private BigDecimal pl;
    private String status;
    @JsonProperty("isVerified")
    private Boolean isVerified;
}

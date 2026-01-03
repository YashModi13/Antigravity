package com.mms.backend.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class MerchantTransactionDTO {
    private Integer id;
    private String transactionType;
    private BigDecimal amount;
    private LocalDate transactionDate;
    private String description;
}

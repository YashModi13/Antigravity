package com.mms.backend.dto;

import lombok.Data;
import java.util.List;

@Data
public class MerchantEntryDetailsDTO {
    private MerchantItemDTO summary;
    private List<MerchantTransactionDTO> transactions;
}

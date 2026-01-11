package com.mms.backend.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CustomerDTO {
    private Integer id;
    private String customerName;
    private String mobileNumber;
    private String email;
    private String address;
    private String village;
    private String district;
    private String state;
    private String pincode;
    private String referralName;
    private CustomerDTO referralCustomer;
    private Boolean kycVerified;
    private Boolean isActive;
    private LocalDateTime createdDate;
    private LocalDateTime updatedDate;
}

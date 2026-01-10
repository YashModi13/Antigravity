package com.mms.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "customer_master", schema = "mms")
public class CustomerMaster {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "customer_name", nullable = false, length = 100)
    private String customerName;

    @Column(name = "mobile_number", nullable = false, unique = true, length = 15)
    private String mobileNumber;

    @Column(length = 100)
    private String email;

    @Column(columnDefinition = "TEXT")
    private String address;

    @Column(length = 50)
    private String village;

    @Column(length = 50)
    private String district;

    @Column(length = 50)
    private String state;

    @Column(length = 10)
    private String pincode;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "referral_customer_id")
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties({ "hibernateLazyInitializer", "handler",
            "referralCustomer" })
    private CustomerMaster referralCustomer;

    // Virtual getter to maintain frontend compatibility and ease of access
    @com.fasterxml.jackson.annotation.JsonProperty("referralName")
    public String getReferralName() {
        return referralCustomer != null ? referralCustomer.getCustomerName() : null;
    }

    @Column(name = "kyc_verified")
    private Boolean kycVerified = false;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;
}

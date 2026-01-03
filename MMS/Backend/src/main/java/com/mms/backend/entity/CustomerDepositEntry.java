package com.mms.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "customer_deposit_entry", schema = "mms")
public class CustomerDepositEntry {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private CustomerMaster customer;

    @Column(name = "deposit_date", nullable = false)
    private LocalDate depositDate;

    @Column(name = "total_interest_rate", nullable = false, precision = 5, scale = 2)
    private BigDecimal totalInterestRate;

    @Column(name = "entry_status", nullable = false, length = 30)
    private String entryStatus = "ACTIVE";

    @Column(columnDefinition = "TEXT")
    private String notes;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;
}

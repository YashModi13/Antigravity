package com.mms.backend.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "customer_deposit_items", schema = "mms")
public class CustomerDepositItems {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "deposit_entry_id", nullable = false)
    private CustomerDepositEntry depositEntry;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id", nullable = false)
    private ItemMaster item;

    @Column(name = "item_date", nullable = false)
    private LocalDate itemDate;

    @Column(name = "weight_received", nullable = false, precision = 10, scale = 3)
    private BigDecimal weightReceived;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "weight_unit_id", nullable = false)
    private UnitMaster weightUnit;

    @Column(name = "fine_weight", nullable = false, precision = 10, scale = 3)
    private BigDecimal fineWeight;

    @Column(name = "item_status", nullable = false, length = 30)
    private String itemStatus = "DEPOSITED";

    @Column(name = "item_description", columnDefinition = "TEXT")
    private String itemDescription;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @Column(name = "created_date")
    private LocalDateTime createdDate;

    @Column(name = "updated_date")
    private LocalDateTime updatedDate;
}

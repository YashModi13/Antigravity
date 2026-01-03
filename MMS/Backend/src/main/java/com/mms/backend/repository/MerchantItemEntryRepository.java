package com.mms.backend.repository;

import com.mms.backend.entity.MerchantItemEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MerchantItemEntryRepository extends JpaRepository<MerchantItemEntry, Integer> {
    List<MerchantItemEntry> findByEntryStatus(String entryStatus);

    @org.springframework.data.jpa.repository.Query("SELECT COUNT(m) FROM MerchantItemEntry m WHERE m.customerDepositItem.depositEntry.id = :depositId AND m.isActive = true")
    long countActiveByDepositId(@org.springframework.data.repository.query.Param("depositId") Long depositId);

    @org.springframework.data.jpa.repository.Query("SELECT m FROM MerchantItemEntry m JOIN FETCH m.merchant WHERE m.customerDepositItem.depositEntry.id = :depositId AND m.isActive = true")
    List<MerchantItemEntry> findActiveByDepositId(
            @org.springframework.data.repository.query.Param("depositId") Long depositId);
}

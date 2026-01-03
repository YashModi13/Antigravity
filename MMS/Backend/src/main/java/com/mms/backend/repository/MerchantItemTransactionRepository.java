package com.mms.backend.repository;

import com.mms.backend.entity.MerchantItemTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MerchantItemTransactionRepository extends JpaRepository<MerchantItemTransaction, Integer> {
    List<MerchantItemTransaction> findByTransactionDateBetween(java.time.LocalDate startDate,
            java.time.LocalDate endDate);

    List<MerchantItemTransaction> findByMerchantItemEntryId(Integer entryId);
}

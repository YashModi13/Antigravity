package com.mms.backend.repository;

import com.mms.backend.entity.CustomerDepositTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CustomerDepositTransactionRepository extends JpaRepository<CustomerDepositTransaction, Integer> {
    List<CustomerDepositTransaction> findByDepositEntry_Id(Integer depositEntryId);

    List<CustomerDepositTransaction> findByTransactionDateBetween(java.time.LocalDate startDate,
            java.time.LocalDate endDate);
}

package com.mms.backend.repository;

import com.mms.backend.entity.CustomerDepositEntry;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CustomerDepositEntryRepository extends JpaRepository<CustomerDepositEntry, Integer> {
    List<CustomerDepositEntry> findByEntryStatusAndIsActiveTrue(String entryStatus);

    long countByEntryStatusAndIsActiveTrue(String entryStatus);

    long countByEntryStatus(String entryStatus);

    long countByDepositDate(java.time.LocalDate date);

    long countByEntryStatusAndUpdatedDateBetween(String status, java.time.LocalDateTime start,
            java.time.LocalDateTime end);

    @Query("SELECT c FROM CustomerDepositEntry c LEFT JOIN FETCH c.customer WHERE c.entryStatus = 'ACTIVE'")
    List<CustomerDepositEntry> findAllActiveWithCustomer();

    @Query(value = "SELECT c FROM CustomerDepositEntry c LEFT JOIN FETCH c.customer WHERE c.entryStatus = 'ACTIVE'", countQuery = "SELECT count(c) FROM CustomerDepositEntry c WHERE c.entryStatus = 'ACTIVE'")
    org.springframework.data.domain.Page<CustomerDepositEntry> findAllActiveWithCustomerPaginated(
            org.springframework.data.domain.Pageable pageable);
}

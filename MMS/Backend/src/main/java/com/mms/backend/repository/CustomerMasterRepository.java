package com.mms.backend.repository;

import com.mms.backend.entity.CustomerMaster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CustomerMasterRepository extends JpaRepository<CustomerMaster, Integer> {
    @org.springframework.data.jpa.repository.Query("SELECT c FROM CustomerMaster c " +
            "WHERE LOWER(c.customerName) LIKE LOWER(CONCAT('%', :query, '%')) " +
            "OR c.mobileNumber LIKE CONCAT('%', :query, '%') " +
            "OR STR(c.id) LIKE CONCAT('%', :query, '%')")
    List<CustomerMaster> searchCustomers(@org.springframework.data.repository.query.Param("query") String query,
            org.springframework.data.domain.Pageable pageable);
}

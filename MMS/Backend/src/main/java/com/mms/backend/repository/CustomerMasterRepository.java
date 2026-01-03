package com.mms.backend.repository;

import com.mms.backend.entity.CustomerMaster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CustomerMasterRepository extends JpaRepository<CustomerMaster, Integer> {
    @org.springframework.data.jpa.repository.Query(value = "SELECT * FROM mms.customer_master " +
            "WHERE LOWER(customer_name) LIKE LOWER(CONCAT('%', :query, '%')) " +
            "OR mobile_number LIKE CONCAT('%', :query, '%') " +
            "OR CAST(id AS CHAR) LIKE CONCAT('%', :query, '%')", nativeQuery = true)
    List<CustomerMaster> searchCustomers(@org.springframework.data.repository.query.Param("query") String query);
}

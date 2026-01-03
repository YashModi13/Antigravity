package com.mms.backend.repository;

import com.mms.backend.entity.CustomerDepositItems;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CustomerDepositItemsRepository extends JpaRepository<CustomerDepositItems, Integer> {
    List<CustomerDepositItems> findByDepositEntry_Id(Integer depositEntryId);

    List<CustomerDepositItems> findByItemStatus(String itemStatus);
}

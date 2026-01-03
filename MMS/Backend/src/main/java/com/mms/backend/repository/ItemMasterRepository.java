package com.mms.backend.repository;

import com.mms.backend.entity.ItemMaster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ItemMasterRepository extends JpaRepository<ItemMaster, Integer> {
    ItemMaster findByItemCode(String itemCode);
}

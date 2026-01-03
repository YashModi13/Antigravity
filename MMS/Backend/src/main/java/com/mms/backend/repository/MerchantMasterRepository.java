package com.mms.backend.repository;

import com.mms.backend.entity.MerchantMaster;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MerchantMasterRepository extends JpaRepository<MerchantMaster, Integer> {
}

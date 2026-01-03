package com.mms.backend.repository;

import com.mms.backend.entity.ConfigProperty;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface ConfigPropertyRepository extends JpaRepository<ConfigProperty, Integer> {
    Optional<ConfigProperty> findByPropertyKey(String propertyKey);
}

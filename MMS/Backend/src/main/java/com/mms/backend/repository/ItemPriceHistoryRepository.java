package com.mms.backend.repository;

import com.mms.backend.entity.ItemPriceHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ItemPriceHistoryRepository extends JpaRepository<ItemPriceHistory, Integer> {

    @Query(value = "SELECT * FROM mms.item_price_history WHERE item_id = :itemId ORDER BY created_date DESC, id DESC LIMIT 1", nativeQuery = true)
    Optional<ItemPriceHistory> findLatestByItemId(@Param("itemId") Integer itemId);

    ItemPriceHistory findTopByItem_IdOrderByEffectiveDateDesc(Integer itemId);

    @Query(value = "SELECT * FROM (SELECT iph.*, ROW_NUMBER() OVER (PARTITION BY iph.item_id ORDER BY iph.created_date DESC) rn FROM mms.item_price_history iph) t WHERE rn = 1", nativeQuery = true)
    List<ItemPriceHistory> findLatestPricePerItem();
}

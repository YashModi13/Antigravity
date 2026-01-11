package com.mms.backend.service;

import com.mms.backend.entity.ItemMaster;
import com.mms.backend.entity.ItemPriceHistory;
import com.mms.backend.repository.ItemMasterRepository;
import com.mms.backend.repository.ItemPriceHistoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

@Service
public class PriceService {
    private static final Logger logger = LoggerFactory.getLogger(PriceService.class);

    @Autowired
    private ItemPriceHistoryRepository priceRepository;

    @Autowired
    private ItemMasterRepository itemRepository;

    @Transactional
    public void updatePrice(Integer itemId, BigDecimal newPrice) {
        ItemMaster item = itemRepository.findById(java.util.Objects.requireNonNull(itemId))
                .orElseThrow(() -> new RuntimeException("Item not found"));

        ItemPriceHistory history = new ItemPriceHistory();
        history.setItem(item);
        history.setPrice(newPrice);
        history.setEffectiveDate(LocalDate.now());
        history.setIsActive(true);
        history.setCreatedDate(java.time.LocalDateTime.now());

        priceRepository.save(history);
        logger.info("Updated price for item {}: {}", item.getItemName(), newPrice);
    }

    @Transactional
    public List<Map<String, Object>> getLatestPrices() {
        List<Map<String, Object>> result = new ArrayList<>();
        List<ItemMaster> items = itemRepository.findAll();
        logger.info("Fetching latest prices for {} items from database", items.size());

        for (ItemMaster item : items) {
            Map<String, Object> map = new HashMap<>();
            map.put("itemName", item.getItemName());
            map.put("unitName", (item.getUnit() != null) ? item.getUnit().getUnitName() : "Unit");
            map.put("unitQuantity", item.getUnitQuantity());

            Optional<ItemPriceHistory> priceOpt = priceRepository
                    .findLatestByItemId(item.getId());

            if (priceOpt.isPresent()) {
                BigDecimal currentPrice = priceOpt.get().getPrice();
                map.put("price", currentPrice);
                logger.debug("Item: {}, Price from DB: {}", item.getItemName(), currentPrice);
            } else {
                // If no price is found in the database, we set it to 0.00
                // This ensures we don't use "fake" hardcoded data
                map.put("price", BigDecimal.ZERO);
                logger.warn("No price found in database for item: {}", item.getItemName());
            }
            result.add(map);
        }

        logger.info("Returning {} database prices to frontend", result.size());
        return result;
    }

    public BigDecimal calculateAssetValue(Integer itemId, BigDecimal fineWeight) {
        ItemMaster item = itemRepository.findById(java.util.Objects.requireNonNull(itemId))
                .orElseThrow(() -> new RuntimeException("Item not found"));

        Optional<ItemPriceHistory> priceOpt = priceRepository.findLatestByItemId(itemId);

        if (priceOpt.isPresent()) {
            BigDecimal price = priceOpt.get().getPrice();
            BigDecimal unitQty = item.getUnitQuantity();
            BigDecimal unitInGram = (item.getUnit() != null) ? item.getUnit().getUnitInGram() : BigDecimal.ONE;

            BigDecimal baseWeightInGrams = unitQty.multiply(unitInGram);

            if (baseWeightInGrams.compareTo(BigDecimal.ZERO) > 0) {
                // Value = (FineWeight / BaseWeight) * Price
                return fineWeight.divide(baseWeightInGrams, 6, java.math.RoundingMode.HALF_UP)
                        .multiply(price)
                        .setScale(0, java.math.RoundingMode.HALF_UP); // Round to nearest integer per UI request
            }
        }
        return BigDecimal.ZERO;
    }
}

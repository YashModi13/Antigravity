package com.mms.backend.controller;

import com.mms.backend.entity.ItemMaster;
import com.mms.backend.entity.UnitMaster;
import com.mms.backend.repository.ItemMasterRepository;
import com.mms.backend.repository.UnitMasterRepository;
import com.mms.backend.service.PriceService;
import static com.mms.backend.util.Constants.KEY_ITEM_ID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:4200")
@Slf4j
@RequiredArgsConstructor
public class MasterDataController {

    private final UnitMasterRepository unitRepository;
    private final ItemMasterRepository itemRepository;
    private final PriceService priceService;

    @PostMapping("/units/list")
    public ResponseEntity<List<UnitMaster>> getAllUnits() {
        log.info("[MasterDataController] Request: Get All Units");
        return ResponseEntity.ok(unitRepository.findAll());
    }

    @PostMapping("/items/list")
    public ResponseEntity<List<ItemMaster>> getAllItems() {
        log.info("[MasterDataController] Request: Get All Items");
        return ResponseEntity.ok(itemRepository.findAll());
    }

    @PostMapping("/items/calculate-value")
    public ResponseEntity<Object> calculateAssetValue(@RequestBody Map<String, Object> payload) {
        try {
            if (!payload.containsKey(KEY_ITEM_ID) || !payload.containsKey("fineWeight")) {
                log.error("[MasterDataController] [CALCULATE] Missing parameters. Received keys: {}", payload.keySet());
                if (payload.containsKey("data")) {
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                            .body("Encryption Error: Payload remained encrypted. Check system.encryption.secret-key.");
                }
                return ResponseEntity.badRequest().body("itemId and fineWeight are required");
            }

            Object itemObj = payload.get(KEY_ITEM_ID);
            Integer itemId;
            if (itemObj instanceof Number number) {
                itemId = number.intValue();
            } else {
                itemId = Integer.parseInt(itemObj.toString());
            }

            Object weightObj = payload.get("fineWeight");
            BigDecimal fineWeight = new BigDecimal(weightObj.toString());

            BigDecimal value = priceService.calculateAssetValue(itemId, fineWeight);
            return ResponseEntity.ok(value);
        } catch (Exception e) {
            log.error("[MasterDataController] [CALCULATE] Calculation failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Calculation Error: " + e.getMessage());
        }
    }

    @PostMapping("/prices")
    public ResponseEntity<Object> updatePrice(@RequestBody Map<String, Object> payload) {
        log.info("[MasterDataController] Request: Update Price. Payload: {}", payload);
        try {
            if (!payload.containsKey(KEY_ITEM_ID) || !payload.containsKey("price")) {
                return ResponseEntity.badRequest().body("itemId and price are required");
            }
            Object itemObj = payload.get(KEY_ITEM_ID);
            Integer itemId;
            if (itemObj instanceof Number number) {
                itemId = number.intValue();
            } else {
                itemId = Integer.parseInt(itemObj.toString());
            }

            BigDecimal price = new BigDecimal(payload.get("price").toString());

            priceService.updatePrice(itemId, price);
            log.info("[MasterDataController] Price updated successfully for Item ID: {}", itemId);
            return ResponseEntity.ok(priceService.getLatestPrices());
        } catch (NumberFormatException e) {
            log.error("[MasterDataController] Invalid price format", e);
            return ResponseEntity.badRequest().body("Invalid price format");
        } catch (Exception e) {
            log.error("[MasterDataController] Error updating price", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating price");
        }
    }

    @PostMapping("/prices/latest")
    public ResponseEntity<List<Map<String, Object>>> getLatestPrices() {
        return ResponseEntity.ok(priceService.getLatestPrices());
    }
}

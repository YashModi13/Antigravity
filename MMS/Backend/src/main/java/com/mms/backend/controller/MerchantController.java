package com.mms.backend.controller;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.mms.backend.dto.AvailableItemDTO;
import com.mms.backend.dto.B2BTransferRequest;
import com.mms.backend.dto.MerchantEntryDetailsDTO;
import com.mms.backend.dto.MerchantItemDTO;
import com.mms.backend.dto.RedemptionRequest;
import com.mms.backend.dto.request.IdRequest;
import com.mms.backend.entity.MerchantMaster;
import com.mms.backend.service.MerchantService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:4200")
@Slf4j
@RequiredArgsConstructor
public class MerchantController {

    private final MerchantService merchantService;

    @PostMapping("/merchants/list")
    public ResponseEntity<List<MerchantMaster>> getAllMerchants() {
        List<MerchantMaster> active = merchantService.getAllMerchants().stream()
                .filter(m -> Boolean.TRUE.equals(m.getIsActive()))
                .toList();
        return ResponseEntity.ok(active);
    }

    @PostMapping("/merchants/create")
    public ResponseEntity<MerchantMaster> createMerchant(@RequestBody MerchantMaster merchant) {
        log.info("[MerchantController] Request: Create Merchant. Name: {}", merchant.getMerchantName());
        return ResponseEntity.ok(merchantService.saveMerchant(merchant));
    }

    @PostMapping("/merchants/update")
    public ResponseEntity<MerchantMaster> updateMerchant(@RequestBody MerchantMaster merchant) {
        return ResponseEntity.ok(merchantService.updateMerchant(merchant.getId(), merchant));
    }

    @PostMapping("/merchants/delete")
    public ResponseEntity<String> deleteMerchant(@RequestBody IdRequest request) {
        try {
            merchantService.deleteMerchant(request.getId());
            return ResponseEntity.ok("Merchant deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error deleting merchant");
        }
    }

    @PostMapping("/items/available")
    public ResponseEntity<List<AvailableItemDTO>> getAvailableItems() {
        return ResponseEntity.ok(merchantService.getAvailableItems());
    }

    @PostMapping("/merchant-entries/transfer")
    public ResponseEntity<String> transferToMerchant(@RequestBody B2BTransferRequest request) {
        log.info("[MerchantController] Request: Transfer to Merchant. MerchantID: {}", request.getMerchantId());
        try {
            merchantService.transferToMerchant(request);
            log.info("[MerchantController] Transfer successful.");
            return ResponseEntity.ok("Item transferred to merchant successfully");
        } catch (Exception e) {
            log.error("[MerchantController] Transfer failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Transfer failed: " + e.getMessage());
        }
    }

    @PostMapping("/merchant-entries/update")
    public ResponseEntity<String> updateMerchantEntry(@RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id");
            if (idObj == null)
                return ResponseEntity.badRequest().body("ID required");

            Integer id;
            if (idObj instanceof Number number) {
                id = number.intValue();
            } else {
                id = Integer.parseInt(idObj.toString());
            }

            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            B2BTransferRequest req = mapper.convertValue(payload, B2BTransferRequest.class);

            merchantService.updateMerchantEntry(id, req);
            return ResponseEntity.ok("Merchant entry updated successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Update failed: " + e.getMessage());
        }
    }

    @PostMapping("/merchant-entries/transaction")
    public ResponseEntity<String> addMerchantTransaction(@RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id"); // Entry ID
            if (idObj == null)
                return ResponseEntity.badRequest().body("Entry ID required");

            Integer id;
            if (idObj instanceof Number number) {
                id = number.intValue();
            } else {
                id = Integer.parseInt(idObj.toString());
            }

            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            RedemptionRequest req = mapper.convertValue(payload, RedemptionRequest.class);

            merchantService.addTransaction(id, req);
            return ResponseEntity.ok("Transaction recorded successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Transaction failed: " + e.getMessage());
        }
    }

    @PostMapping("/merchant-entries/active")
    public ResponseEntity<List<MerchantItemDTO>> getActiveMerchantItems() {
        return ResponseEntity.ok(merchantService.getActiveMerchantEntries());
    }

    @PostMapping("/merchant-entries/details")
    public ResponseEntity<MerchantEntryDetailsDTO> getMerchantEntryDetails(@RequestBody IdRequest request) {
        return ResponseEntity.ok(merchantService.getMerchantEntryDetails(request.getId()));
    }

    @PostMapping("/merchant-entries/return")
    public ResponseEntity<String> returnFromMerchant(@RequestBody Map<String, Object> payload) {
        log.info("[MerchantController] Request: Return from Merchant. Payload: {}", payload);
        try {
            Object idObj = payload.get("id");
            if (idObj == null)
                return ResponseEntity.badRequest().body("Entry ID required");

            Integer id;
            if (idObj instanceof Number number) {
                id = number.intValue();
            } else {
                id = Integer.parseInt(idObj.toString());
            }

            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            RedemptionRequest req = mapper.convertValue(payload, RedemptionRequest.class);

            merchantService.returnFromMerchant(id, req);
            log.info("[MerchantController] Item returned from merchant successfully. Entry ID: {}", id);
            return ResponseEntity.ok("Item returned from merchant successfully");
        } catch (Exception e) {
            log.error("[MerchantController] Return from merchant failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Return failed: " + e.getMessage());
        }
    }
}

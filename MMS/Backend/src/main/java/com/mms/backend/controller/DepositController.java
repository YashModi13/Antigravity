package com.mms.backend.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.mms.backend.dto.CreateDepositRequest;
import com.mms.backend.dto.DepositDetailDTO;
import com.mms.backend.dto.MerchantItemDTO;
import com.mms.backend.dto.RedemptionRequest;
import com.mms.backend.dto.UpdateDepositRequest;
import com.mms.backend.dto.request.IdRequest;
import com.mms.backend.service.DepositService;
import com.mms.backend.service.DepositQueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/deposits")
@CrossOrigin(origins = "http://localhost:4200")
@Slf4j
@RequiredArgsConstructor
public class DepositController {

    private final DepositService depositService;
    private final DepositQueryService depositQueryService;

    @PostMapping("/create")
    public ResponseEntity<String> createDeposit(@RequestBody CreateDepositRequest request) {
        log.info("[DepositController] Request: Create Deposit. Token: {}, CustomerID: {}",
                request.getTokenNo(), request.getCustomerId());
        try {
            depositService.createDeposit(request);
            log.info("[DepositController] Deposit created successfully. Token: {}", request.getTokenNo());
            return ResponseEntity.status(HttpStatus.CREATED).body("Deposit created successfully");
        } catch (IllegalArgumentException e) {
            log.warn("[DepositController] Bad Request in createDeposit: {}", e.getMessage());
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            log.error("[DepositController] Error creating deposit", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error creating deposit: " + e.getMessage());
        }
    }

    @PostMapping("/details")
    public ResponseEntity<Object> getDeposit(@RequestBody IdRequest request) {
        log.info("[DepositController] Request: Get Deposit Details. ID: {}", request.getId());
        try {
            DepositDetailDTO detail = depositQueryService.getDepositDetails(request.getId());
            if (detail == null) {
                log.warn("[DepositController] Deposit not found. ID: {}", request.getId());
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Deposit not found with ID: " + request.getId());
            }
            return ResponseEntity.ok(detail);
        } catch (Exception e) {
            log.error("[DepositController] Error fetching deposit details", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching deposit details");
        }
    }

    @PostMapping("/close")
    public ResponseEntity<String> closeDeposit(@RequestBody Map<String, Object> payload) {
        log.info("[DepositController] Request: Close Deposit. Payload: {}", payload);
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

            String dateStr = (String) payload.get("date");
            java.time.LocalDate closeDate = null;
            if (dateStr != null && !dateStr.isEmpty()) {
                closeDate = java.time.LocalDate.parse(dateStr);
            }

            depositService.closeDeposit(id, closeDate);
            log.info("[DepositController] Deposit closed successfully. ID: {}", id);
            return ResponseEntity.ok("Deposit closed successfully");
        } catch (Exception e) {
            log.error("[DepositController] Error closing deposit", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error closing deposit: " + e.getMessage());
        }
    }

    @PostMapping("/check-active-items")
    public ResponseEntity<Boolean> hasActiveMerchantItems(@RequestBody IdRequest request) {
        return ResponseEntity.ok(depositQueryService.hasActiveMerchantItems(Long.valueOf(request.getId())));
    }

    @PostMapping("/active-merchant-entries")
    public ResponseEntity<List<MerchantItemDTO>> getActiveMerchantEntries(@RequestBody IdRequest request) {
        log.info("[DepositController] Request: Get Active Merchant Entries for Deposit ID: {}", request.getId());
        return ResponseEntity.ok(depositQueryService.getActiveMerchantPledges(Long.valueOf(request.getId())));
    }

    @PostMapping("/update")
    public ResponseEntity<String> updateDeposit(@RequestBody Map<String, Object> payload) {
        log.info("[DepositController] Request: Update Deposit. Payload: {}", payload);
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

            UpdateDepositRequest req = mapper.convertValue(payload, UpdateDepositRequest.class);

            depositService.updateDeposit(id, req);
            log.info("[DepositController] Deposit updated successfully. ID: {}", id);
            return ResponseEntity.ok("Deposit updated successfully");
        } catch (NoSuchElementException e) {
            log.warn("[DepositController] Deposit not found for update.");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Deposit not found");
        } catch (Exception e) {
            log.error("[DepositController] Error updating deposit", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error updating deposit: " + e.getMessage());
        }
    }

    @PostMapping("/transactions/add")
    public ResponseEntity<String> addPaymentTransaction(@RequestBody Map<String, Object> payload) {
        log.info("[DepositController] Request: Add Payment Transaction. Payload: {}", payload);
        try {
            Object idObj = payload.get("depositId");
            if (idObj == null)
                return ResponseEntity.badRequest().body("Deposit ID required");

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

            depositService.addPaymentTransaction(id, req);
            log.info("[DepositController] Payment Transaction added successfully to Deposit ID: {}", id);
            return ResponseEntity.ok("Transaction added successfully");
        } catch (Exception e) {
            log.error("[DepositController] Error adding payment transaction", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error adding transaction: " + e.getMessage());
        }
    }

    @PostMapping("/check-token")
    public ResponseEntity<Boolean> checkTokenAvailability(@RequestBody Map<String, Object> payload) {
        log.info("[DepositController] Request: Check Token. Payload: {}", payload);
        try {
            Object tokenObj = payload.get("tokenNo");
            if (tokenObj == null)
                tokenObj = payload.get("token");

            if (tokenObj == null)
                return ResponseEntity.badRequest().body(false);

            Integer tokenNo = parseInteger(tokenObj);
            if (tokenNo == null)
                return ResponseEntity.badRequest().body(false);

            Integer excludeId = parseInteger(payload.get("id"));

            boolean exists = depositService.isTokenExists(tokenNo, excludeId);
            log.info("[DepositController] Token Check Details: TokenNo={}, ExcludeId={}, Exists={}",
                    tokenNo, excludeId, exists);

            return ResponseEntity.ok(!exists);
        } catch (Exception e) {
            log.error("[DepositController] Error checking token", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(false);
        }
    }

    private Integer parseInteger(Object obj) {
        if (obj == null || obj.toString().trim().isEmpty() || obj.toString().equals("null")) {
            return null;
        }
        if (obj instanceof Number number) {
            return number.intValue();
        }
        try {
            return Integer.parseInt(obj.toString());
        } catch (NumberFormatException e) {
            log.warn("[DepositController] Failed to parse integer value: {}", obj);
            return null;
        }
    }

    @PostMapping("/generate-token")
    public ResponseEntity<Integer> generateToken() {
        return ResponseEntity.ok(depositService.generateNextToken());
    }
}

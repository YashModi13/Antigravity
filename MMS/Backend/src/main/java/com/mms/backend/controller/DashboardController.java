package com.mms.backend.controller;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.mms.backend.dto.DepositFilterDTO;
import com.mms.backend.dto.DepositSummaryDTO;
import com.mms.backend.dto.request.CommonRequest;
import com.mms.backend.service.DashboardChartService;
import com.mms.backend.service.DepositQueryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/dashboard")
@CrossOrigin(origins = "http://localhost:4200")
@Slf4j
@RequiredArgsConstructor
public class DashboardController {

    private final DepositQueryService depositQueryService;
    private final DashboardChartService chartService;

    @PostMapping("")
    public ResponseEntity<List<DepositSummaryDTO>> getDashboardData() {
        log.info("[DashboardController] Request: Get Dashboard Data (Summary)");
        try {
            return ResponseEntity.ok(depositQueryService.getActiveDepositSummary());
        } catch (Exception e) {
            log.error("[DashboardController] Error fetching dashboard data: {}", e.getMessage(), e);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error fetching dashboard data", e);
        }
    }

    @PostMapping("/paginated")
    public ResponseEntity<Page<DepositSummaryDTO>> getDashboardDataPaginated(
            @RequestBody DepositFilterDTO filters) {
        try {
            throw new UnsupportedOperationException("Please use paginated-v2");
        } catch (Exception e) {
            // Re-throw with status
            throw new ResponseStatusException(HttpStatus.NOT_IMPLEMENTED, "Not Implemented properly yet", e);
        }
    }

    @PostMapping("/paginated-v2")
    public ResponseEntity<Object> getDashboardDataPaginatedV2(
            @RequestBody Map<String, Object> payload) {
        log.info("[DashboardController] Request: Get Dashboard Data V2 (Paginated). Payload: {}", payload);
        try {
            Object pageObj = payload.get("page");
            int page;
            if (pageObj instanceof Number number) {
                page = number.intValue();
            } else if (pageObj != null) {
                page = Integer.parseInt(pageObj.toString());
            } else {
                page = 0;
            }

            Object sizeObj = payload.get("size");
            int size;
            if (sizeObj instanceof Number number) {
                size = number.intValue();
            } else if (sizeObj != null) {
                size = Integer.parseInt(sizeObj.toString());
            } else {
                size = 10;
            }

            String sort = payload.get("sort") != null ? payload.get("sort").toString() : "id";
            String dir = payload.get("dir") != null ? payload.get("dir").toString() : "asc";

            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
            mapper.configure(DeserializationFeature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT, true);

            // Convert empty strings to null for numeric mapping safety
            Map<String, Object> cleanedPayload = new HashMap<>(payload);
            cleanedPayload.entrySet().forEach(entry -> {
                if ("".equals(entry.getValue())) {
                    entry.setValue(null);
                }
            });

            DepositFilterDTO filters = mapper.convertValue(cleanedPayload, DepositFilterDTO.class);

            return ResponseEntity
                    .ok(depositQueryService.getActiveDepositSummaryPaginated(page, size, sort, dir, filters));
        } catch (Exception e) {
            log.error("[DashboardController] ERROR in paginated-v2: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error fetching paginated data: " + e.getMessage());
        }
    }

    @PostMapping("/stats")
    public ResponseEntity<Object> getDashboardStats() {
        try {
            return ResponseEntity.ok(chartService.getDashboardStats());
        } catch (Exception e) {
            log.error("Error fetching stats", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching stats");
        }
    }

    @PostMapping("/chart")
    public ResponseEntity<Object> getChartData(@RequestBody CommonRequest request) {
        try {
            String period = request.getPeriod() != null ? request.getPeriod() : "DAY";
            return ResponseEntity.ok(chartService.getChartData(period));
        } catch (Exception e) {
            log.error("Error fetching chart data", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching chart data");
        }
    }
}

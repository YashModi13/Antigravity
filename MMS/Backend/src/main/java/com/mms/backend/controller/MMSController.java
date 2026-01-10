package com.mms.backend.controller;

import com.mms.backend.dto.*;
import com.mms.backend.entity.ConfigProperty;
import com.mms.backend.repository.ConfigPropertyRepository;
import com.mms.backend.entity.UnitMaster;
import com.mms.backend.repository.UnitMasterRepository;
import com.mms.backend.entity.ItemMaster;
import com.mms.backend.repository.ItemMasterRepository;
import com.mms.backend.service.DepositService;
import com.mms.backend.service.PriceService;
import com.mms.backend.service.MerchantService;
import com.mms.backend.entity.MerchantMaster;
import com.mms.backend.dto.B2BTransferRequest;
import com.mms.backend.dto.AvailableItemDTO;
import com.mms.backend.dto.MerchantItemDTO;
import com.mms.backend.service.DashboardChartService;
import com.mms.backend.service.ReportService;
import com.mms.backend.service.DatabaseBackupService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import java.io.IOException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:4200") // Angular default
@Slf4j
public class MMSController {

    @Autowired
    private DepositService depositService;

    @Autowired
    private PriceService priceService;

    @Autowired
    private MerchantService merchantService;

    @Autowired
    private DashboardChartService chartService;

    @Autowired
    private com.mms.backend.service.DemoDataService demoService;

    @Autowired
    private ItemMasterRepository itemRepository;

    @Autowired
    private UnitMasterRepository unitRepository;

    @Autowired
    private ConfigPropertyRepository configRepository;

    @Autowired
    private com.mms.backend.repository.CustomerMasterRepository customerRepository;

    @Autowired
    private ReportService reportService;

    @Autowired
    private DatabaseBackupService backupService;

    @PostMapping("/configs/list")
    public ResponseEntity<List<ConfigProperty>> getAllConfigs() {
        return ResponseEntity.ok(configRepository.findAll());
    }

    @PostMapping("/configs/details")
    public ResponseEntity<ConfigProperty> getConfigByKey(@RequestBody Map<String, String> payload) {
        String key = payload.get("key");
        if (key == null)
            return ResponseEntity.badRequest().build();
        return configRepository.findByPropertyKey(key)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/configs/save")
    public ResponseEntity<ConfigProperty> saveConfig(@RequestBody ConfigProperty config) {
        return ResponseEntity.ok(configRepository.save(config));
    }

    @PostMapping("/configs/update")
    public ResponseEntity<ConfigProperty> updateConfig(@RequestBody ConfigProperty config) {
        if (config.getId() == null)
            return ResponseEntity.badRequest().build();
        return configRepository.findById(config.getId()).map(existing -> {
            existing.setPropertyKey(config.getPropertyKey());
            existing.setPropertyValue(config.getPropertyValue());
            existing.setDescription(config.getDescription());
            existing.setIsActive(config.getIsActive());
            return ResponseEntity.ok(configRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/configs/delete")
    public ResponseEntity<Void> deleteConfig(@RequestBody com.mms.backend.dto.request.IdRequest request) {
        configRepository.deleteById(request.getId());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/units/list")
    public ResponseEntity<List<UnitMaster>> getAllUnits() {
        return ResponseEntity.ok(unitRepository.findAll());
    }

    @PostMapping("/dashboard")
    public ResponseEntity<List<DepositSummaryDTO>> getDashboardData() {
        try {
            return ResponseEntity.ok(depositService.getActiveDepositSummary());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error fetching dashboard data", e);
        }
    }

    @PostMapping("/dashboard/paginated")
    public ResponseEntity<org.springframework.data.domain.Page<DepositSummaryDTO>> getDashboardDataPaginated(
            @RequestBody com.mms.backend.dto.DepositFilterDTO filters) {
        try {
            throw new UnsupportedOperationException("Please use paginated-v2");
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Not Implemented properly yet");
        }
    }

    @PostMapping("/dashboard/paginated-v2")
    public ResponseEntity<?> getDashboardDataPaginatedV2(
            @RequestBody Map<String, Object> payload) {
        try {
            Object pageObj = payload.get("page");
            int page = (pageObj instanceof Number) ? ((Number) pageObj).intValue()
                    : (pageObj != null ? Integer.parseInt(pageObj.toString()) : 0);

            Object sizeObj = payload.get("size");
            int size = (sizeObj instanceof Number) ? ((Number) sizeObj).intValue()
                    : (sizeObj != null ? Integer.parseInt(sizeObj.toString()) : 10);

            String sort = payload.get("sort") != null ? payload.get("sort").toString() : "id";
            String dir = payload.get("dir") != null ? payload.get("dir").toString() : "asc";

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT,
                    true);

            // Convert empty strings to null for numeric mapping safety
            Map<String, Object> cleanedPayload = new java.util.HashMap<>(payload);
            cleanedPayload.entrySet().forEach(entry -> {
                if ("".equals(entry.getValue())) {
                    entry.setValue(null);
                }
            });

            com.mms.backend.dto.DepositFilterDTO filters = mapper.convertValue(cleanedPayload,
                    com.mms.backend.dto.DepositFilterDTO.class);

            return ResponseEntity.ok(depositService.getActiveDepositSummaryPaginated(page, size, sort, dir, filters));
        } catch (Exception e) {
            log.error("#### [SERVER] ERROR in paginated-v2: {}", e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error fetching paginated data: " + e.getMessage());
        }
    }

    @PostMapping("/items/list")
    public ResponseEntity<List<ItemMaster>> getAllItems() {
        return ResponseEntity.ok(itemRepository.findAll());
    }

    @PostMapping("/items/calculate-value")
    public ResponseEntity<?> calculateAssetValue(@RequestBody Map<String, Object> payload) {
        try {
            if (!payload.containsKey("itemId") || !payload.containsKey("fineWeight")) {
                log.error("#### [CALCULATE] Missing parameters. Received keys: {}", payload.keySet());
                if (payload.containsKey("data")) {
                    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                            .body("Encryption Error: Payload remained encrypted. Check system.encryption.secret-key.");
                }
                return ResponseEntity.badRequest().body("itemId and fineWeight are required");
            }

            Object itemObj = payload.get("itemId");
            Integer itemId = (itemObj instanceof Number) ? ((Number) itemObj).intValue()
                    : Integer.parseInt(itemObj.toString());

            Object weightObj = payload.get("fineWeight");
            BigDecimal fineWeight = new BigDecimal(weightObj.toString());

            BigDecimal value = priceService.calculateAssetValue(itemId, fineWeight);
            return ResponseEntity.ok(value);
        } catch (Exception e) {
            log.error("#### [CALCULATE] Calculation failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Calculation Error: " + e.getMessage());
        }
    }

    @PostMapping("/customers/search")
    public ResponseEntity<List<com.mms.backend.entity.CustomerMaster>> searchCustomers(
            @RequestBody Map<String, String> payload) {
        String query = payload.get("q");
        return ResponseEntity.ok(customerRepository.searchCustomers(query != null ? query : ""));
    }

    @PostMapping("/customers/list")
    public ResponseEntity<org.springframework.data.domain.Page<com.mms.backend.entity.CustomerMaster>> getAllCustomers(
            @RequestBody com.mms.backend.dto.request.SearchRequest request) {

        int page = request.getPage() != null ? request.getPage() : 0;
        int size = request.getSize() != null ? request.getSize() : 10;
        String sortBy = request.getSortBy() != null ? request.getSortBy() : "id";
        String sortDir = request.getSortDir() != null ? request.getSortDir() : "asc";

        int pageSize;
        if (request.getSize() != null) {
            pageSize = size;
        } else {
            pageSize = configRepository.findByPropertyKey("system.pagination.default.size")
                    .map(config -> {
                        try {
                            return Integer.parseInt(config.getPropertyValue());
                        } catch (NumberFormatException e) {
                            return 10;
                        }
                    })
                    .orElse(10);
        }

        org.springframework.data.domain.Sort sortOrder = org.springframework.data.domain.Sort.by(
                org.springframework.data.domain.Sort.Direction.fromString(sortDir), sortBy);
        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(page,
                pageSize, sortOrder);

        return ResponseEntity.ok(customerRepository.findAll(pageable));
    }

    @PostMapping("/customers/items")
    public ResponseEntity<List<com.mms.backend.dto.CustomerItemDTO>> getCustomerItems(
            @RequestBody com.mms.backend.dto.request.IdRequest request) {
        return ResponseEntity.ok(depositService.getCustomerItems(request.getId()));
    }

    @PostMapping("/customers/portfolio")
    public ResponseEntity<com.mms.backend.dto.CustomerPortfolioDTO> getCustomerPortfolio(
            @RequestBody com.mms.backend.dto.request.IdRequest request) {
        return ResponseEntity.ok(depositService.getCustomerPortfolio(request.getId()));
    }

    @PostMapping("/customers/create")
    public ResponseEntity<?> createCustomer(@RequestBody com.mms.backend.entity.CustomerMaster customer) {
        try {
            customer.setCreatedDate(java.time.LocalDateTime.now());
            customer.setUpdatedDate(java.time.LocalDateTime.now());
            com.mms.backend.entity.CustomerMaster saved = customerRepository.save(customer);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error creating customer");
        }
    }

    @PostMapping("/customers/update")
    public ResponseEntity<?> updateCustomer(@RequestBody com.mms.backend.entity.CustomerMaster customer) {
        if (customer.getId() == null)
            return ResponseEntity.badRequest().body("ID Required");
        return customerRepository.findById(customer.getId()).map(existing -> {
            existing.setCustomerName(customer.getCustomerName());
            existing.setMobileNumber(customer.getMobileNumber());
            existing.setEmail(customer.getEmail());
            existing.setAddress(customer.getAddress());
            existing.setVillage(customer.getVillage());
            existing.setDistrict(customer.getDistrict());
            existing.setState(customer.getState());
            existing.setPincode(customer.getPincode());
            existing.setReferralCustomer(customer.getReferralCustomer());
            existing.setKycVerified(customer.getKycVerified());
            existing.setUpdatedDate(java.time.LocalDateTime.now());

            return ResponseEntity.ok(customerRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/prices")
    public ResponseEntity<?> updatePrice(@RequestBody Map<String, Object> payload) {
        try {
            if (!payload.containsKey("itemId") || !payload.containsKey("price")) {
                return ResponseEntity.badRequest().body("itemId and price are required");
            }
            Object itemObj = payload.get("itemId");
            Integer itemId = (itemObj instanceof Number) ? ((Number) itemObj).intValue()
                    : Integer.parseInt(itemObj.toString());
            BigDecimal price = new BigDecimal(payload.get("price").toString());

            priceService.updatePrice(itemId, price);
            return ResponseEntity.ok(priceService.getLatestPrices());
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest().body("Invalid price format");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating price");
        }
    }

    @PostMapping("/prices/latest")
    public ResponseEntity<List<Map<String, Object>>> getLatestPrices() {
        return ResponseEntity.ok(priceService.getLatestPrices());
    }

    @PostMapping("/deposits/create")
    public ResponseEntity<String> createDeposit(@RequestBody com.mms.backend.dto.CreateDepositRequest request) {
        try {
            depositService.createDeposit(request);
            return ResponseEntity.status(HttpStatus.CREATED).body("Deposit created successfully");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error creating deposit: " + e.getMessage());
        }
    }

    @PostMapping("/deposits/details")
    public ResponseEntity<?> getDeposit(@RequestBody com.mms.backend.dto.request.IdRequest request) {
        try {
            DepositDetailDTO detail = depositService.getDepositDetails(request.getId());
            if (detail == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body("Deposit not found with ID: " + request.getId());
            }
            return ResponseEntity.ok(detail);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching deposit details");
        }
    }

    @PostMapping("/deposits/close")
    public ResponseEntity<String> closeDeposit(@RequestBody com.mms.backend.dto.request.IdRequest request) {
        try {
            depositService.closeDeposit(request.getId());
            return ResponseEntity.ok("Deposit closed successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error closing deposit: " + e.getMessage());
        }
    }

    @PostMapping("/deposits/check-active-items")
    public ResponseEntity<Boolean> hasActiveMerchantItems(@RequestBody com.mms.backend.dto.request.IdRequest request) {
        return ResponseEntity.ok(depositService.hasActiveMerchantItems(Long.valueOf(request.getId())));
    }

    @PostMapping("/deposits/active-merchant-entries")
    public ResponseEntity<List<com.mms.backend.dto.MerchantItemDTO>> getActiveMerchantEntries(
            @RequestBody com.mms.backend.dto.request.IdRequest request) {
        return ResponseEntity.ok(depositService.getActiveMerchantPledges(Long.valueOf(request.getId())));
    }

    @PostMapping("/deposits/update")
    public ResponseEntity<String> updateDeposit(@RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id");
            if (idObj == null)
                return ResponseEntity.badRequest().body("ID required");

            Integer id = (idObj instanceof Number) ? ((Number) idObj).intValue()
                    : Integer.parseInt(idObj.toString());

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            // Ensure UpdateDepositRequest is imported or fully qualified
            com.mms.backend.dto.UpdateDepositRequest req = mapper.convertValue(payload,
                    com.mms.backend.dto.UpdateDepositRequest.class);

            depositService.updateDeposit(id, req);
            return ResponseEntity.ok("Deposit updated successfully");
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Deposit not found");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error updating deposit: " + e.getMessage());
        }
    }

    @PostMapping("/deposits/transactions/add")
    public ResponseEntity<String> addPaymentTransaction(@RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("depositId");
            if (idObj == null)
                return ResponseEntity.badRequest().body("Deposit ID required");

            Integer id = (idObj instanceof Number) ? ((Number) idObj).intValue()
                    : Integer.parseInt(idObj.toString());

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            // Ensure RedemptionRequest is imported or fully qualified
            com.mms.backend.dto.RedemptionRequest req = mapper.convertValue(payload,
                    com.mms.backend.dto.RedemptionRequest.class);

            depositService.addPaymentTransaction(id, req);
            return ResponseEntity.ok("Transaction added successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error adding transaction: " + e.getMessage());
        }
    }

    @PostMapping("/deposits/check-token")
    public ResponseEntity<Boolean> checkTokenAvailability(
            @RequestBody com.mms.backend.dto.request.CommonRequest request) {
        return ResponseEntity.ok(!depositService.isTokenExists(request.getTokenNo()));
    }

    @PostMapping("/deposits/generate-token")
    public ResponseEntity<Integer> generateToken() {
        return ResponseEntity.ok(depositService.generateNextToken());
    }

    @PostMapping("/merchants/list")
    public ResponseEntity<List<MerchantMaster>> getAllMerchants() {
        List<MerchantMaster> active = merchantService.getAllMerchants().stream()
                .filter(m -> Boolean.TRUE.equals(m.getIsActive()))
                .collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(active);
    }

    @PostMapping("/merchants/create")
    public ResponseEntity<MerchantMaster> createMerchant(@RequestBody MerchantMaster merchant) {
        return ResponseEntity.ok(merchantService.saveMerchant(merchant));
    }

    @PostMapping("/merchants/update")
    public ResponseEntity<MerchantMaster> updateMerchant(@RequestBody MerchantMaster merchant) {
        return ResponseEntity.ok(merchantService.updateMerchant(merchant.getId(), merchant));
    }

    @PostMapping("/merchants/delete")
    public ResponseEntity<String> deleteMerchant(@RequestBody com.mms.backend.dto.request.IdRequest request) {
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
        try {
            merchantService.transferToMerchant(request);
            return ResponseEntity.ok("Item transferred to merchant successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Transfer failed: " + e.getMessage());
        }
    }

    @PostMapping("/merchant-entries/update")
    public ResponseEntity<String> updateMerchantEntry(@RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id");
            if (idObj == null)
                return ResponseEntity.badRequest().body("ID required");

            Integer id = (idObj instanceof Number) ? ((Number) idObj).intValue()
                    : Integer.parseInt(idObj.toString());

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            B2BTransferRequest req = mapper.convertValue(payload, B2BTransferRequest.class);

            merchantService.updateMerchantEntry(id, req);
            return ResponseEntity.ok("Merchant entry updated successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Update failed: " + e.getMessage());
        }
    }

    @PostMapping("/merchant-entries/transaction")
    public ResponseEntity<String> addMerchantTransaction(
            @RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id"); // Entry ID
            if (idObj == null)
                return ResponseEntity.badRequest().body("Entry ID required");

            Integer id = (idObj instanceof Number) ? ((Number) idObj).intValue()
                    : Integer.parseInt(idObj.toString());

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            com.mms.backend.dto.RedemptionRequest req = mapper.convertValue(payload,
                    com.mms.backend.dto.RedemptionRequest.class);

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
    public ResponseEntity<com.mms.backend.dto.MerchantEntryDetailsDTO> getMerchantEntryDetails(
            @RequestBody com.mms.backend.dto.request.IdRequest request) {
        return ResponseEntity.ok(merchantService.getMerchantEntryDetails(request.getId()));
    }

    @PostMapping("/merchant-entries/return")
    public ResponseEntity<String> returnFromMerchant(
            @RequestBody Map<String, Object> payload) {
        try {
            Object idObj = payload.get("id");
            if (idObj == null)
                return ResponseEntity.badRequest().body("Entry ID required");

            Integer id = (idObj instanceof Number) ? ((Number) idObj).intValue()
                    : Integer.parseInt(idObj.toString());

            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            mapper.registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());
            mapper.configure(com.fasterxml.jackson.databind.DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

            com.mms.backend.dto.RedemptionRequest req = mapper.convertValue(payload,
                    com.mms.backend.dto.RedemptionRequest.class);

            merchantService.returnFromMerchant(id, req);
            return ResponseEntity.ok("Item returned from merchant successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Return failed: " + e.getMessage());
        }
    }

    @PostMapping("/dashboard/stats")
    public ResponseEntity<?> getDashboardStats() {
        try {
            return ResponseEntity.ok(chartService.getDashboardStats());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching stats");
        }
    }

    @PostMapping("/dashboard/chart")
    public ResponseEntity<?> getChartData(
            @RequestBody com.mms.backend.dto.request.CommonRequest request) {
        try {
            String period = request.getPeriod() != null ? request.getPeriod() : "DAY";
            return ResponseEntity.ok(chartService.getChartData(period));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching chart data");
        }
    }

    @PostMapping("/test/seed")
    public ResponseEntity<String> seedData(@RequestBody com.mms.backend.dto.request.CommonRequest request) {
        try {
            int count = request.getCount() != null ? request.getCount() : 10;
            demoService.generateDemoData(count);
            return ResponseEntity.ok("Generated " + count + " demo entries");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Seeding failed: " + e.getMessage());
        }
    }

    @PostMapping("/security/echo")
    public ResponseEntity<Map<String, Object>> securityEcho(@RequestBody Map<String, Object> payload) {
        log.info("#### [SERVER] Received ECHO Request. Original Data: {}", payload);
        log.info("#### [SERVER] Echoing back. Request body will be returned inside 'echoed' wrapper.");

        Map<String, Object> response = new java.util.HashMap<>();
        response.put("echoed", payload);
        response.put("serverStatus", "SECURE");
        response.put("processedAt", java.time.LocalDateTime.now().toString());

        return ResponseEntity.ok(response);
    }

    @PostMapping("/reports/generate")
    public ResponseEntity<byte[]> generateReport(@RequestBody Map<String, String> payload) {
        String type = payload.get("type");
        byte[] report;
        String fileName;
        try {
            switch (type) {
                case "deposits":
                    report = reportService.generateDepositsReport();
                    fileName = "Deposits_Report.xlsx";
                    break;
                case "customers":
                    report = reportService.generateCustomersReport();
                    fileName = "Customers_Report.xlsx";
                    break;
                case "merchants":
                    report = reportService.generateMerchantsReport();
                    fileName = "Merchants_Report.xlsx";
                    break;
                default:
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid report type");
            }

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .contentType(MediaType
                            .parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                    .body(report);
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error generating report");
        }
    }

    @PostMapping("/database/backup")
    public ResponseEntity<byte[]> backupDatabase() {
        try {
            byte[] backupData = backupService.generateBackup();
            String timestamp = java.time.LocalDateTime.now()
                    .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd_HH-mm-ss"));
            String fileName = "mms_schema_backup_" + timestamp + ".sql";

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .contentType(MediaType.APPLICATION_OCTET_STREAM)
                    .body(backupData);
        } catch (Exception e) {
            log.error("Database backup failed", e);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Database backup failed: " + e.getMessage());
        }
    }

    @PostMapping("/database/restore")
    public ResponseEntity<String> restoreDatabase(
            @RequestParam("file") org.springframework.web.multipart.MultipartFile file,
            @RequestParam("host") String host,
            @RequestParam("port") String port,
            @RequestParam("user") String user,
            @RequestParam("pass") String pass,
            @RequestParam("db") String db,
            @RequestParam("schema") String schema,
            @RequestParam("psqlPath") String psqlPath) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body("File is empty");
            }
            backupService.restoreBackup(file.getBytes(), host, port, user, pass, db, schema, psqlPath);
            return ResponseEntity.ok("Database schema restored successfully. System reloaded.");
        } catch (Exception e) {
            log.error("Database restore failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Restore failed: " + e.getMessage());
        }
    }

    // Global error handler for this controller
    // Global error handler for this controller
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGeneralException(Exception e) {
        log.error("Unhandled Exception in MMSController", e);
        // Return JSON so frontend encryption service can parse it if it decrypts the
        // error response
        String jsonError = String.format("{\"error\": \"Internal Server Error\", \"message\": \"%s\"}",
                e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown Error");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(jsonError);
    }
}

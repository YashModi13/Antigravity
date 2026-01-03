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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:4200") // Angular default
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

    @GetMapping("/configs")
    public ResponseEntity<List<ConfigProperty>> getAllConfigs() {
        return ResponseEntity.ok(configRepository.findAll());
    }

    @GetMapping("/configs/{key}")
    public ResponseEntity<ConfigProperty> getConfigByKey(@PathVariable String key) {
        return configRepository.findByPropertyKey(key)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/configs")
    public ResponseEntity<ConfigProperty> saveConfig(@RequestBody ConfigProperty config) {
        return ResponseEntity.ok(configRepository.save(config));
    }

    @PutMapping("/configs/{id}")
    public ResponseEntity<ConfigProperty> updateConfig(@PathVariable Integer id, @RequestBody ConfigProperty config) {
        return configRepository.findById(id).map(existing -> {
            existing.setPropertyKey(config.getPropertyKey());
            existing.setPropertyValue(config.getPropertyValue());
            existing.setDescription(config.getDescription());
            existing.setIsActive(config.getIsActive());
            return ResponseEntity.ok(configRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/configs/{id}")
    public ResponseEntity<Void> deleteConfig(@PathVariable Integer id) {
        configRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/units")
    public ResponseEntity<List<UnitMaster>> getAllUnits() {
        return ResponseEntity.ok(unitRepository.findAll());
    }

    @GetMapping("/dashboard")
    public ResponseEntity<List<DepositSummaryDTO>> getDashboardData() {
        try {
            return ResponseEntity.ok(depositService.getActiveDepositSummary());
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error fetching dashboard data", e);
        }
    }

    @GetMapping("/dashboard/paginated")
    public ResponseEntity<org.springframework.data.domain.Page<DepositSummaryDTO>> getDashboardDataPaginated(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "id") String sort,
            @RequestParam(defaultValue = "asc") String dir,
            @ModelAttribute com.mms.backend.dto.DepositFilterDTO filters) {
        try {
            return ResponseEntity.ok(depositService.getActiveDepositSummaryPaginated(page, size, sort, dir, filters));
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error fetching paginated data", e);
        }
    }

    @GetMapping("/items")
    public ResponseEntity<List<ItemMaster>> getAllItems() {
        return ResponseEntity.ok(itemRepository.findAll());
    }

    @GetMapping("/items/calculate-value")
    public ResponseEntity<BigDecimal> calculateAssetValue(@RequestParam Integer itemId,
            @RequestParam BigDecimal fineWeight) {
        try {
            return ResponseEntity.ok(priceService.calculateAssetValue(itemId, fineWeight));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    @GetMapping("/customers/search")
    public ResponseEntity<List<com.mms.backend.entity.CustomerMaster>> searchCustomers(@RequestParam String q) {
        return ResponseEntity.ok(customerRepository.searchCustomers(q));
    }

    @GetMapping("/customers/{id}/items")
    public ResponseEntity<List<com.mms.backend.dto.CustomerItemDTO>> getCustomerItems(@PathVariable Integer id) {
        return ResponseEntity.ok(depositService.getCustomerItems(id));
    }

    @GetMapping("/customers/{id}/portfolio")
    public ResponseEntity<com.mms.backend.dto.CustomerPortfolioDTO> getCustomerPortfolio(@PathVariable Integer id) {
        return ResponseEntity.ok(depositService.getCustomerPortfolio(id));
    }

    @PostMapping("/customers")
    public ResponseEntity<?> createCustomer(@RequestBody com.mms.backend.entity.CustomerMaster customer) {
        try {
            com.mms.backend.entity.CustomerMaster saved = customerRepository.save(customer);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error creating customer");
        }
    }

    @PostMapping("/prices")
    public ResponseEntity<?> updatePrice(@RequestBody Map<String, Object> payload) {
        try {
            if (!payload.containsKey("itemId") || !payload.containsKey("price")) {
                return ResponseEntity.badRequest().body("itemId and price are required");
            }
            Integer itemId = (Integer) payload.get("itemId");
            BigDecimal price = new BigDecimal(payload.get("price").toString());

            priceService.updatePrice(itemId, price);
            return ResponseEntity.ok(priceService.getLatestPrices());
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest().body("Invalid price format");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error updating price");
        }
    }

    @GetMapping("/prices/latest")
    public ResponseEntity<List<Map<String, Object>>> getLatestPrices() {
        return ResponseEntity.ok(priceService.getLatestPrices());
    }

    @PostMapping("/deposits")
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

    @GetMapping("/deposits/{id}")
    public ResponseEntity<?> getDeposit(@PathVariable Integer id) {
        try {
            DepositDetailDTO detail = depositService.getDepositDetails(id);
            if (detail == null) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Deposit not found with ID: " + id);
            }
            return ResponseEntity.ok(detail);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching deposit details");
        }
    }

    @DeleteMapping("/deposits/{id}")
    public ResponseEntity<String> closeDeposit(@PathVariable Integer id) {
        try {
            depositService.closeDeposit(id);
            return ResponseEntity.ok("Deposit closed successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error closing deposit: " + e.getMessage());
        }
    }

    @GetMapping("/deposits/{id}/has-active-merchant-items")
    public ResponseEntity<Boolean> hasActiveMerchantItems(@PathVariable Long id) {
        return ResponseEntity.ok(depositService.hasActiveMerchantItems(id));
    }

    @GetMapping("/deposits/{id}/active-merchant-entries")
    public ResponseEntity<List<com.mms.backend.dto.MerchantItemDTO>> getActiveMerchantEntries(@PathVariable Long id) {
        return ResponseEntity.ok(depositService.getActiveMerchantPledges(id));
    }

    @PutMapping("/deposits/{id}")
    public ResponseEntity<String> updateDeposit(@PathVariable Integer id, @RequestBody UpdateDepositRequest request) {
        try {
            depositService.updateDeposit(id, request);
            return ResponseEntity.ok("Deposit updated successfully");
        } catch (java.util.NoSuchElementException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Deposit not found");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error updating deposit: " + e.getMessage());
        }
    }

    @PostMapping("/deposits/{id}/transactions")
    public ResponseEntity<String> addPaymentTransaction(@PathVariable Integer id,
            @RequestBody RedemptionRequest request) {
        try {
            depositService.addPaymentTransaction(id, request);
            return ResponseEntity.ok("Transaction added successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error adding transaction: " + e.getMessage());
        }
    }

    @GetMapping("/merchants")
    public ResponseEntity<List<MerchantMaster>> getAllMerchants() {
        // Filter only active merchants
        List<MerchantMaster> active = merchantService.getAllMerchants().stream()
                .filter(m -> Boolean.TRUE.equals(m.getIsActive()))
                .collect(java.util.stream.Collectors.toList());
        return ResponseEntity.ok(active);
    }

    @PostMapping("/merchants")
    public ResponseEntity<MerchantMaster> createMerchant(@RequestBody MerchantMaster merchant) {
        return ResponseEntity.ok(merchantService.saveMerchant(merchant));
    }

    @PutMapping("/merchants/{id}")
    public ResponseEntity<MerchantMaster> updateMerchant(@PathVariable Integer id,
            @RequestBody MerchantMaster merchant) {
        return ResponseEntity.ok(merchantService.updateMerchant(id, merchant));
    }

    @DeleteMapping("/merchants/{id}")
    public ResponseEntity<String> deleteMerchant(@PathVariable Integer id) {
        try {
            merchantService.deleteMerchant(id);
            return ResponseEntity.ok("Merchant deleted successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error deleting merchant");
        }
    }

    @GetMapping("/items/available")
    public ResponseEntity<List<AvailableItemDTO>> getAvailableItems() {
        return ResponseEntity.ok(merchantService.getAvailableItems());
    }

    @PostMapping("/merchant-entries")
    public ResponseEntity<String> transferToMerchant(@RequestBody B2BTransferRequest request) {
        try {
            merchantService.transferToMerchant(request);
            return ResponseEntity.ok("Item transferred to merchant successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Transfer failed: " + e.getMessage());
        }
    }

    @PutMapping("/merchant-entries/{id}")
    public ResponseEntity<String> updateMerchantEntry(@PathVariable Integer id,
            @RequestBody B2BTransferRequest request) {
        try {
            merchantService.updateMerchantEntry(id, request);
            return ResponseEntity.ok("Merchant entry updated successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Update failed: " + e.getMessage());
        }
    }

    @PostMapping("/merchant-entries/{id}/transaction")
    public ResponseEntity<String> addMerchantTransaction(
            @PathVariable Integer id,
            @RequestBody com.mms.backend.dto.RedemptionRequest request) {
        try {
            merchantService.addTransaction(id, request);
            return ResponseEntity.ok("Transaction recorded successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Transaction failed: " + e.getMessage());
        }
    }

    @GetMapping("/merchant-entries/active")
    public ResponseEntity<List<MerchantItemDTO>> getActiveMerchantItems() {
        return ResponseEntity.ok(merchantService.getActiveMerchantEntries());
    }

    @GetMapping("/merchant-entries/{id}/details")
    public ResponseEntity<com.mms.backend.dto.MerchantEntryDetailsDTO> getMerchantEntryDetails(
            @PathVariable Integer id) {
        return ResponseEntity.ok(merchantService.getMerchantEntryDetails(id));
    }

    @PostMapping("/merchant-entries/{id}/return")
    public ResponseEntity<String> returnFromMerchant(
            @PathVariable Integer id,
            @RequestBody RedemptionRequest request) {
        try {
            merchantService.returnFromMerchant(id, request);
            return ResponseEntity.ok("Item returned from merchant successfully");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Return failed: " + e.getMessage());
        }
    }

    @GetMapping("/dashboard/stats")
    public ResponseEntity<?> getDashboardStats() {
        try {
            return ResponseEntity.ok(chartService.getDashboardStats());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching stats");
        }
    }

    @GetMapping("/dashboard/chart")
    public ResponseEntity<?> getChartData(
            @RequestParam(defaultValue = "DAY") String period) {
        try {
            return ResponseEntity.ok(chartService.getChartData(period));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error fetching chart data");
        }
    }

    @PostMapping("/test/seed")
    public ResponseEntity<String> seedData(@RequestParam(defaultValue = "10") int count) {
        try {
            demoService.generateDemoData(count);
            return ResponseEntity.ok("Generated " + count + " demo entries");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Seeding failed: " + e.getMessage());
        }
    }

    // Global error handler for this controller
    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGeneralException(Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Internal Server Error: " + e.getMessage());
    }
}

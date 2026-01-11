package com.mms.backend.controller;

import com.mms.backend.dto.CustomerDTO;
import com.mms.backend.dto.CustomerItemDTO;
import com.mms.backend.dto.CustomerPortfolioDTO;
import com.mms.backend.dto.request.IdRequest;
import com.mms.backend.dto.request.SearchRequest;
import com.mms.backend.entity.CustomerMaster;
import com.mms.backend.repository.ConfigPropertyRepository;
import com.mms.backend.repository.CustomerMasterRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/customers")
@CrossOrigin(origins = "http://localhost:4200")
@Slf4j
@RequiredArgsConstructor
public class CustomerController {

    private final CustomerMasterRepository customerRepository;
    private final com.mms.backend.service.DepositQueryService depositQueryService;
    private final ConfigPropertyRepository configRepository;

    @PostMapping("/search")
    @Transactional(readOnly = true)
    public ResponseEntity<List<CustomerDTO>> searchCustomers(@RequestBody Map<String, String> payload) {
        log.info("[CustomerController] Request: Search Customers. Payload: {}", payload);
        String query = payload.get("q");
        List<CustomerMaster> results = customerRepository.searchCustomers(query != null ? query : "");
        return ResponseEntity.ok(results.stream()
                .map(this::mapToCustomerDTO)
                .toList());
    }

    @PostMapping("/list")
    @Transactional(readOnly = true)
    public ResponseEntity<Page<CustomerDTO>> getAllCustomers(@RequestBody SearchRequest request) {
        log.info("[CustomerController] Request: List Customers. Page: {}, Size: {}, Sort: {}",
                request.getPage(), request.getSize(), request.getSortBy());

        int page = request.getPage() != null ? request.getPage() : 0;
        int size = request.getSize() != null ? request.getSize() : 10;
        String sortBy = request.getSortBy() != null ? request.getSortBy() : com.mms.backend.util.Constants.STR_ID;
        String sortDir = request.getSortDir() != null ? request.getSortDir() : com.mms.backend.util.Constants.STR_ASC;

        int pageSize;
        if (request.getSize() != null) {
            pageSize = size;
        } else {
            pageSize = configRepository.findByPropertyKey(com.mms.backend.util.Constants.CONFIG_PAGINATION_DEFAULT_SIZE)
                    .map(config -> {
                        try {
                            return Integer.parseInt(config.getPropertyValue());
                        } catch (NumberFormatException e) {
                            return 10;
                        }
                    })
                    .orElse(10);
        }

        Sort sortOrder = Sort.by(Sort.Direction.fromString(Objects.requireNonNull(sortDir)), sortBy);
        Pageable pageable = PageRequest.of(page, pageSize, sortOrder);

        return ResponseEntity.ok(customerRepository.findAll(pageable).map(this::mapToCustomerDTO));
    }

    @PostMapping("/items")
    public ResponseEntity<List<CustomerItemDTO>> getCustomerItems(@RequestBody IdRequest request) {
        return ResponseEntity.ok(depositQueryService.getCustomerItems(request.getId()));
    }

    @PostMapping("/portfolio")
    public ResponseEntity<CustomerPortfolioDTO> getCustomerPortfolio(@RequestBody IdRequest request) {
        return ResponseEntity.ok(depositQueryService.getCustomerPortfolio(request.getId()));
    }

    @PostMapping("/create")
    public ResponseEntity<Object> createCustomer(@RequestBody CustomerMaster customer) {
        log.info("[CustomerController] Request: Create Customer. Name: {}, Mobile: {}",
                customer.getCustomerName(), customer.getMobileNumber());
        try {
            customer.setCreatedDate(LocalDateTime.now());
            customer.setUpdatedDate(LocalDateTime.now());
            CustomerMaster saved = customerRepository.save(customer);
            log.info("[CustomerController] Customer created successfully. ID: {}", saved.getId());
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            log.error("[CustomerController] Error creating customer", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error creating customer");
        }
    }

    @PostMapping("/update")
    public ResponseEntity<Object> updateCustomer(@RequestBody CustomerMaster customer) {
        log.info("[CustomerController] Request: Update Customer. ID: {}", customer.getId());
        if (customer.getId() == null) {
            return ResponseEntity.badRequest().body("ID Required");
        }
        return customerRepository.findById(Objects.requireNonNull(customer.getId())).map(existing -> {
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
            existing.setUpdatedDate(LocalDateTime.now());

            log.info("[CustomerController] Customer updated successfully. ID: {}", existing.getId());
            return ResponseEntity.ok((Object) customerRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    private CustomerDTO mapToCustomerDTO(CustomerMaster entity) {
        if (entity == null)
            return null;
        CustomerDTO dto = new CustomerDTO();
        dto.setId(entity.getId());
        dto.setCustomerName(entity.getCustomerName());
        dto.setMobileNumber(entity.getMobileNumber());
        dto.setEmail(entity.getEmail());
        dto.setAddress(entity.getAddress());
        dto.setVillage(entity.getVillage());
        dto.setDistrict(entity.getDistrict());
        dto.setState(entity.getState());
        dto.setPincode(entity.getPincode());
        dto.setKycVerified(entity.getKycVerified());
        dto.setIsActive(entity.getIsActive());
        dto.setCreatedDate(entity.getCreatedDate());
        dto.setUpdatedDate(entity.getUpdatedDate());

        // Handle referralName (computed in entity)
        dto.setReferralName(entity.getReferralName());

        // Handle referralCustomer (Lazy)
        if (entity.getReferralCustomer() != null) {
            CustomerMaster ref = entity.getReferralCustomer();
            CustomerDTO refDto = new CustomerDTO();
            refDto.setId(ref.getId());
            refDto.setCustomerName(ref.getCustomerName());
            refDto.setMobileNumber(ref.getMobileNumber());
            refDto.setEmail(ref.getEmail());
            refDto.setAddress(ref.getAddress());
            refDto.setVillage(ref.getVillage());
            refDto.setDistrict(ref.getDistrict());
            refDto.setState(ref.getState());
            refDto.setPincode(ref.getPincode());
            refDto.setKycVerified(ref.getKycVerified());
            refDto.setIsActive(ref.getIsActive());
            refDto.setCreatedDate(ref.getCreatedDate());
            refDto.setUpdatedDate(ref.getUpdatedDate());
            // Do not set nested referral to avoid recursion
            dto.setReferralCustomer(refDto);
        }

        return dto;
    }
}

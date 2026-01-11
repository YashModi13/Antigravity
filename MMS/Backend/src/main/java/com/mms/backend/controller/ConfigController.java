package com.mms.backend.controller;

import com.mms.backend.dto.request.IdRequest;
import com.mms.backend.entity.ConfigProperty;
import com.mms.backend.repository.ConfigPropertyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/configs")
@CrossOrigin(origins = "http://localhost:4200")
@Slf4j
@RequiredArgsConstructor
public class ConfigController {

    private final ConfigPropertyRepository configRepository;

    @PostMapping("/list")
    public ResponseEntity<List<ConfigProperty>> getAllConfigs() {
        return ResponseEntity.ok(configRepository.findAll());
    }

    @PostMapping("/details")
    public ResponseEntity<ConfigProperty> getConfigByKey(@RequestBody Map<String, String> payload) {
        String key = payload.get("key");
        if (key == null)
            return ResponseEntity.badRequest().build();
        return configRepository.findByPropertyKey(key)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/save")
    public ResponseEntity<ConfigProperty> saveConfig(@RequestBody ConfigProperty config) {
        return ResponseEntity.ok(configRepository.save(Objects.requireNonNull(config)));
    }

    @PostMapping("/update")
    public ResponseEntity<ConfigProperty> updateConfig(@RequestBody ConfigProperty config) {
        log.info("[ConfigController] Request: Update Config. ID: {}", config.getId());
        if (config.getId() == null)
            return ResponseEntity.badRequest().build();
        return configRepository.findById(Objects.requireNonNull(config.getId())).map(existing -> {
            existing.setPropertyKey(config.getPropertyKey());
            existing.setPropertyValue(config.getPropertyValue());
            existing.setDescription(config.getDescription());
            existing.setIsActive(config.getIsActive());
            log.info("[ConfigController] Config updated successfully. Key: {}", existing.getPropertyKey());
            return ResponseEntity.ok(configRepository.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/delete")
    public ResponseEntity<Void> deleteConfig(@RequestBody IdRequest request) {
        configRepository.deleteById(Objects.requireNonNull(request.getId()));
        return ResponseEntity.ok().build();
    }
}

package com.mms.backend.controller;

import com.mms.backend.dto.request.CommonRequest;
import com.mms.backend.service.DatabaseBackupService;
import com.mms.backend.service.DemoDataService;
import com.mms.backend.service.ReportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "http://localhost:4200")
@Slf4j
@RequiredArgsConstructor
public class SystemController {

    private final DemoDataService demoService;
    private final ReportService reportService;
    private final DatabaseBackupService backupService;

    @PostMapping("/test/seed")
    public ResponseEntity<String> seedData(@RequestBody CommonRequest request) {
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
        log.info("[SystemController] Received ECHO Request. Original Data: {}", payload);
        log.info("[SystemController] Echoing back. Request body will be returned inside 'echoed' wrapper.");

        Map<String, Object> response = new HashMap<>();
        response.put("echoed", payload);
        response.put("serverStatus", com.mms.backend.util.Constants.STR_SECURE);
        response.put("processedAt", LocalDateTime.now().toString());

        return ResponseEntity.ok(response);
    }

    @PostMapping("/reports/generate")
    public ResponseEntity<byte[]> generateReport(@RequestBody Map<String, String> payload) {
        String type = payload.get("type");
        byte[] report;
        String fileName;
        try {
            switch (type) {
                case com.mms.backend.util.Constants.REPORT_TYPE_DEPOSITS:
                    report = reportService.generateDepositsReport();
                    fileName = com.mms.backend.util.Constants.FILE_NAME_DEPOSITS_REPORT;
                    break;
                case com.mms.backend.util.Constants.REPORT_TYPE_CUSTOMERS:
                    report = reportService.generateCustomersReport();
                    fileName = com.mms.backend.util.Constants.FILE_NAME_CUSTOMERS_REPORT;
                    break;
                case com.mms.backend.util.Constants.REPORT_TYPE_MERCHANTS:
                    report = reportService.generateMerchantsReport();
                    fileName = com.mms.backend.util.Constants.FILE_NAME_MERCHANTS_REPORT;
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
            String timestamp = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern(com.mms.backend.util.Constants.DATE_FORMAT_FILE_NAME));
            String fileName = "mms_schema_backup_" + timestamp + ".sql";

            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                    .contentType(Objects.requireNonNull(MediaType.APPLICATION_OCTET_STREAM))
                    .body(backupData);
        } catch (InterruptedException e) {
            log.error("Database backup interrupted", e);
            Thread.currentThread().interrupt();
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Database backup interrupted");
        } catch (Exception e) {
            log.error("Database backup failed", e);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Database backup failed: " + e.getMessage());
        }
    }

    @PostMapping("/database/restore")
    public ResponseEntity<String> restoreDatabase(
            @RequestParam("file") MultipartFile file,
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
        } catch (InterruptedException e) {
            log.error("Database restore interrupted", e);
            Thread.currentThread().interrupt();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Restore interrupted");
        } catch (Exception e) {
            log.error("Database restore failed", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Restore failed: " + e.getMessage());
        }
    }
}

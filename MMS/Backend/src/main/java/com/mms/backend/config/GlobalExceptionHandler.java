package com.mms.backend.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGeneralException(Exception e) {
        log.error("Unhandled Exception in Application", e);
        // Return JSON so frontend encryption service can parse it if it decrypts the
        // error response
        String jsonError = String.format("{\"error\": \"Internal Server Error\", \"message\": \"%s\"}",
                e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Unknown Error");
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(jsonError);
    }
}

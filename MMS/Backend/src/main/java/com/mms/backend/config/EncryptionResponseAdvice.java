package com.mms.backend.config;

import com.mms.backend.dto.EncryptedPayload;
import com.mms.backend.service.EncryptionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;

@RestControllerAdvice
@Slf4j
@lombok.RequiredArgsConstructor
public class EncryptionResponseAdvice implements ResponseBodyAdvice<Object> {

    private final EncryptionService encryptionService;
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @Override
    public boolean supports(@org.springframework.lang.NonNull MethodParameter returnType,
            @org.springframework.lang.NonNull Class<? extends org.springframework.http.converter.HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    public Object beforeBodyWrite(@org.springframework.lang.Nullable Object body,
            @org.springframework.lang.NonNull MethodParameter returnType,
            @org.springframework.lang.NonNull MediaType selectedContentType,
            @org.springframework.lang.NonNull Class<? extends org.springframework.http.converter.HttpMessageConverter<?>> selectedConverterType,
            @org.springframework.lang.NonNull ServerHttpRequest request,
            @org.springframework.lang.NonNull ServerHttpResponse response) {

        if (body == null) {
            return null;
        }

        // Skip encryption for specific types if needed, e.g. byte arrays (files) or
        // already encrypted
        if (body instanceof byte[] || body instanceof EncryptedPayload) {
            return body;
        }

        // Also skip for Swagger/OpenAPI endpoints if applicable
        String path = request.getURI().getPath();
        if (path.contains("/v3/api-docs") || path.contains("/swagger-ui")) {
            return body;
        }

        try {
            log.info(">>> [SECURITY] Outgoing Response: Encrypting Payload...");
            String json = objectMapper.writeValueAsString(body);
            String encryptedData = encryptionService.encrypt(json);
            log.info(">>> [SECURITY] Encryption Success.");
            return new EncryptedPayload(encryptedData);
        } catch (Exception e) {
            log.error(">>> [SECURITY] Encryption Failed", e);
            throw new org.springframework.web.server.ResponseStatusException(
                    org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR, "Failed to encrypt response", e);
        }
    }
}

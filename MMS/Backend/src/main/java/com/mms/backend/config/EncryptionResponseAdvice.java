package com.mms.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mms.backend.dto.EncryptedPayload;
import com.mms.backend.service.EncryptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.MethodParameter;
import org.springframework.http.MediaType;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.ResponseBodyAdvice;
import lombok.extern.slf4j.Slf4j;

@RestControllerAdvice
@Slf4j
public class EncryptionResponseAdvice implements ResponseBodyAdvice<Object> {

    @Autowired
    private EncryptionService encryptionService;

    @Autowired
    private ObjectMapper objectMapper;

    @Override
    public boolean supports(MethodParameter returnType, Class<? extends HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    public Object beforeBodyWrite(Object body, MethodParameter returnType, MediaType selectedContentType,
            Class<? extends HttpMessageConverter<?>> selectedConverterType, ServerHttpRequest request,
            ServerHttpResponse response) {

        // Skip if body is null or already encrypted
        if (body == null || body instanceof EncryptedPayload) {
            return body;
        }

        // Only encrypt JSON responses
        if (!MediaType.APPLICATION_JSON.isCompatibleWith(selectedContentType)) {
            return body;
        }

        // Skip Swagger/OpenAPI endpoints if any (optional check)
        String path = request.getURI().getPath();
        if (path.contains("/v3/api-docs") || path.contains("/swagger-ui")) {
            return body;
        }

        try {
            // Convert body to JSON string
            String jsonString = (body instanceof String) ? (String) body : objectMapper.writeValueAsString(body);

            log.info("<<< [SECURITY] Outgoing Response. Status: UNLOCKED (Raw Data)");
            log.info("<<< [SECURITY] Action: BLOCKING (Encryption) -> In Progress...");

            // Encrypt
            String encryptedData = encryptionService.encrypt(jsonString);

            log.info("<<< [SECURITY] Action: BLOCKED (Encryption Success). Response Secured.");

            // Return wrapper
            EncryptedPayload payload = new EncryptedPayload(encryptedData);

            // SPECIAL CASE: If the selected converter is StringHttpMessageConverter,
            // we must return a String, otherwise ClassCastException occurs.
            if (org.springframework.http.converter.StringHttpMessageConverter.class
                    .isAssignableFrom(selectedConverterType)) {
                return objectMapper.writeValueAsString(payload);
            }

            return payload;
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to encrypt response", e);
        }
    }
}

package com.mms.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mms.backend.dto.EncryptedPayload;
import com.mms.backend.service.EncryptionService;
import org.springframework.core.MethodParameter;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpInputMessage;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.servlet.mvc.method.annotation.RequestBodyAdviceAdapter;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Type;
import java.nio.charset.StandardCharsets;

@RestControllerAdvice
@lombok.extern.slf4j.Slf4j
@lombok.RequiredArgsConstructor
public class EncryptionRequestAdvice extends RequestBodyAdviceAdapter {

    private final EncryptionService encryptionService;
    private final ObjectMapper objectMapper;

    @Override
    public boolean supports(@org.springframework.lang.NonNull MethodParameter methodParameter,
            @org.springframework.lang.NonNull Type targetType,
            @org.springframework.lang.NonNull Class<? extends HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    @org.springframework.lang.NonNull
    public HttpInputMessage beforeBodyRead(@org.springframework.lang.NonNull HttpInputMessage inputMessage,
            @org.springframework.lang.NonNull MethodParameter parameter,
            @org.springframework.lang.NonNull Type targetType,
            @org.springframework.lang.NonNull Class<? extends HttpMessageConverter<?>> converterType)
            throws IOException {
        InputStream body = inputMessage.getBody();
        byte[] bytes = body.readAllBytes();

        if (bytes.length == 0) {
            return new ByteArrayInputMessage(bytes, inputMessage.getHeaders());
        }

        try {
            EncryptedPayload payload = objectMapper.readValue(bytes, EncryptedPayload.class);
            if (payload != null && payload.getData() != null) {
                return handleEncryptedPayload(payload, inputMessage);
            }
        } catch (IOException e) {
            if (e.getMessage() != null && e.getMessage().contains("Security Error"))
                throw e;
            log.info(">>> [SECURITY] Incoming Request: Raw/Plain Payload. Status: UNLOCKED");
        }

        return new ByteArrayInputMessage(bytes, inputMessage.getHeaders());
    }

    @org.springframework.lang.NonNull
    private HttpInputMessage handleEncryptedPayload(EncryptedPayload payload, HttpInputMessage inputMessage)
            throws IOException {
        log.info(">>> [SECURITY] Incoming Request: Encrypted Payload Detected. Status: LOCKED");
        try {
            String decrypted = encryptionService.decrypt(payload.getData());
            log.info(">>> [SECURITY] Action: UNBLOCKING (Decryption) -> Success. Processing Request.");
            return new ByteArrayInputMessage(
                    java.util.Objects.requireNonNull(decrypted.getBytes(StandardCharsets.UTF_8)),
                    java.util.Objects.requireNonNull(inputMessage.getHeaders()));
        } catch (Exception decryptEx) {
            log.error(">>> [SECURITY] FATAL ERROR: Decryption Failed. Check Secret Key.", decryptEx);
            throw new IOException("Security Error: Decryption Failed. Check system.encryption.secret-key.");
        }
    }

    // Helper class
    private static class ByteArrayInputMessage implements HttpInputMessage {
        @org.springframework.lang.NonNull
        private final byte[] bytes;
        @org.springframework.lang.NonNull
        private final HttpHeaders headers;

        public ByteArrayInputMessage(@org.springframework.lang.NonNull byte[] bytes,
                @org.springframework.lang.NonNull HttpHeaders headers) {
            this.bytes = bytes;
            this.headers = headers;
        }

        @Override
        @org.springframework.lang.NonNull
        public InputStream getBody() {
            return new ByteArrayInputStream(bytes);
        }

        @Override
        @org.springframework.lang.NonNull
        public HttpHeaders getHeaders() {
            return headers;
        }
    }
}

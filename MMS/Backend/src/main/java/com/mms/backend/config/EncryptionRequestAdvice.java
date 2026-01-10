package com.mms.backend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mms.backend.dto.EncryptedPayload;
import com.mms.backend.service.EncryptionService;
import org.springframework.beans.factory.annotation.Autowired;
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
public class EncryptionRequestAdvice extends RequestBodyAdviceAdapter {

    @Autowired
    private EncryptionService encryptionService;

    @Autowired
    private ObjectMapper objectMapper;

    @Override
    public boolean supports(MethodParameter methodParameter, Type targetType,
            Class<? extends HttpMessageConverter<?>> converterType) {
        return true;
    }

    @Override
    public HttpInputMessage beforeBodyRead(HttpInputMessage inputMessage, MethodParameter parameter, Type targetType,
            Class<? extends HttpMessageConverter<?>> converterType) throws IOException {
        InputStream body = inputMessage.getBody();
        byte[] bytes = body.readAllBytes();

        if (bytes.length == 0) {
            return new ByteArrayInputMessage(bytes, inputMessage.getHeaders());
        }

        try {
            // Try to parse as EncryptedPayload
            EncryptedPayload payload = objectMapper.readValue(bytes, EncryptedPayload.class);

            if (payload != null && payload.getData() != null) {
                log.info(">>> [SECURITY] Incoming Request: Encrypted Payload Detected. Status: LOCKED");
                try {
                    // Decrypt
                    String decrypted = encryptionService.decrypt(payload.getData());
                    log.info(">>> [SECURITY] Action: UNBLOCKING (Decryption) -> Success. Processing Request.");
                    return new ByteArrayInputMessage(decrypted.getBytes(StandardCharsets.UTF_8),
                            inputMessage.getHeaders());
                } catch (Exception decryptEx) {
                    log.error(">>> [SECURITY] FATAL ERROR: Decryption Failed. Check Secret Key.", decryptEx);
                    throw new IOException("Security Error: Decryption Failed. Check system.encryption.secret-key.");
                }
            }
        } catch (IOException e) {
            if (e.getMessage() != null && e.getMessage().contains("Security Error"))
                throw e;
            log.info(">>> [SECURITY] Incoming Request: Raw/Plain Payload. Status: UNLOCKED");
        }

        return new ByteArrayInputMessage(bytes, inputMessage.getHeaders());
    }

    // Helper class
    private static class ByteArrayInputMessage implements HttpInputMessage {
        private final byte[] bytes;
        private final HttpHeaders headers;

        public ByteArrayInputMessage(byte[] bytes, HttpHeaders headers) {
            this.bytes = bytes;
            this.headers = headers;
        }

        @Override
        public InputStream getBody() {
            return new ByteArrayInputStream(bytes);
        }

        @Override
        public HttpHeaders getHeaders() {
            return headers;
        }
    }
}

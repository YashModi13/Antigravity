package com.mms.backend.config;

import com.mms.backend.service.EncryptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.format.FormatterRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

@Configuration
public class EncryptionConfig implements WebMvcConfigurer {

    @Autowired
    private EncryptionService encryptionService;

    @Override
    public void addFormatters(FormatterRegistry registry) {
        System.out.println(">>> [CONFIG] Registering StringToIntegerConverter for Encryption");
        registry.addConverter(new StringToIntegerConverter(encryptionService));
    }

    @lombok.extern.slf4j.Slf4j
    private static class StringToIntegerConverter implements Converter<String, Integer> {

        private final EncryptionService encryptionService;

        public StringToIntegerConverter(EncryptionService encryptionService) {
            this.encryptionService = encryptionService;
        }

        @Override
        public Integer convert(String source) {
            String originalSource = source;
            if (source == null || source.isEmpty()) {
                return null;
            }
            try {
                // 1. Try to parse as normal integer first
                return Integer.parseInt(source);
            } catch (NumberFormatException e) {
                // 2. Not a number, assume it's encrypted
                try {
                    // Log before decrypting for debug
                    log.info(">>> [CONVERTER] Attempting to decrypt ID (Raw): {}", source);

                    // URL Decode if it looks like it might still be encoded (though Spring usually
                    // decodes)
                    // Encrypted strings ending with == often have + replaced by space by web
                    // servers if not careful,
                    // or if double encoded.
                    // If source contains spaces, it might be a malformed base64 (space instead of
                    // +).
                    if (source.contains(" ")) {
                        log.warn(
                                ">>> [CONVERTER] Source contains spaces! Replacing with '+' (likely URL decoding artifact).");
                        source = source.replace(" ", "+");
                    }

                    String decrypted = encryptionService.decrypt(source);
                    log.info(">>> [CONVERTER] Decrypted ID: {}", decrypted);

                    // Double check if decrypted is actually a number
                    if (decrypted == null || decrypted.isEmpty())
                        return null;
                    // Sometimes decrypted string might have extra quotes or whitespace
                    decrypted = decrypted.trim().replace("\"", "");

                    return Integer.parseInt(decrypted);
                } catch (Exception ex) {
                    log.error(">>> [CONVERTER] Failed to decrypt/parse ID. Raw: {}, Modified: {}, Error: {}",
                            originalSource, source, ex.getMessage());
                    throw new IllegalArgumentException("Invalid integer or encrypted ID: " + originalSource);
                }
            }
        }
    }
}

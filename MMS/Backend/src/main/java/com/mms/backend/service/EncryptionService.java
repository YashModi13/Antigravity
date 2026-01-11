package com.mms.backend.service;

import com.mms.backend.repository.ConfigPropertyRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Service
@lombok.extern.slf4j.Slf4j
public class EncryptionService {

    @Autowired
    private ConfigPropertyRepository configRepository;

    private static final String ALGORITHM = "AES";
    private String SECRET_KEY = "DefaultInsecureKey!!"; // Fallback, should be overwritten by DB

    @PostConstruct
    public void init() {
        configRepository.findByPropertyKey("system.encryption.secret-key")
                .ifPresent(config -> {
                    this.SECRET_KEY = config.getPropertyValue();
                    log.info("Encryption Key Loaded from Database.");
                });
    }

    public String encrypt(String data) {
        try {
            if (data == null)
                return null;
            SecretKeySpec secretKey = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.ENCRYPT_MODE, secretKey);
            byte[] encryptedBytes = cipher.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(encryptedBytes);
        } catch (Exception e) {
            log.error("Error while encrypting: {}", e.toString());
            throw new RuntimeException("Encryption Error", e);
        }
    }

    public String decrypt(String encryptedData) {
        try {
            if (encryptedData == null)
                return null;
            SecretKeySpec secretKey = new SecretKeySpec(SECRET_KEY.getBytes(StandardCharsets.UTF_8), ALGORITHM);
            Cipher cipher = Cipher.getInstance(ALGORITHM);
            cipher.init(Cipher.DECRYPT_MODE, secretKey);
            byte[] decryptedBytes = cipher.doFinal(Base64.getDecoder().decode(encryptedData));
            return new String(decryptedBytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            log.error("Error while decrypting: {}", e.toString());
            throw new RuntimeException("Decryption Error", e);
        }
    }
}

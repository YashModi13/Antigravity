package com.mms.backend.dto;

import lombok.Data;

@Data
public class SignupRequest {
    private String fullName;
    private String username; // Email as username as per screenshot
    private String password;
}

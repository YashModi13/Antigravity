package com.mms.backend.dto;

import lombok.Data;
import java.util.List;

@Data
public class LoginResponse {
    private String token;
    private Long id;
    private String username;
    private String fullName;
    private Long roleId;
    private String roleName;
    private List<PermissionDto> permissions;
}

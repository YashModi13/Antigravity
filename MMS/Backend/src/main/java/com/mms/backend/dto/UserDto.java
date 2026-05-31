package com.mms.backend.dto;

import lombok.Data;

@Data
public class UserDto {
    private Long id;
    private String username;
    private String password; // used for creation/update
    private String fullName;
    private boolean active;
    private Long roleId;
    private String roleName;
}

package com.mms.backend.dto;

import lombok.Data;
import java.util.List;

@Data
public class RoleDto {
    private Long id;
    private String roleName;
    private String description;
    private List<PermissionDto> permissions;
}

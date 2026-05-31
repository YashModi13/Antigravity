package com.mms.backend.dto;

import lombok.Data;

@Data
public class PermissionDto {
    private String menuName;
    private boolean canView;
    private boolean canAdd;
    private boolean canEdit;
    private boolean canDelete;
}

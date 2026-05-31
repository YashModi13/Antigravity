package com.mms.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "role_permissions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class RolePermission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "role_id")
    private Role role;

    private String menuName;
    private boolean canView;
    private boolean canAdd;
    private boolean canEdit;
    private boolean canDelete;

    public RolePermission(Role role, String menuName, boolean canView, boolean canAdd, boolean canEdit, boolean canDelete) {
        this.role = role;
        this.menuName = menuName;
        this.canView = canView;
        this.canAdd = canAdd;
        this.canEdit = canEdit;
        this.canDelete = canDelete;
    }
}

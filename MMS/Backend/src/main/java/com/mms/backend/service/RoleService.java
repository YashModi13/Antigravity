package com.mms.backend.service;

import com.mms.backend.dto.PermissionDto;
import com.mms.backend.dto.RoleDto;
import com.mms.backend.entity.Role;
import com.mms.backend.entity.RolePermission;
import com.mms.backend.repository.RolePermissionRepository;
import com.mms.backend.repository.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoleService {

    private final RoleRepository roleRepository;
    private final RolePermissionRepository rolePermissionRepository;

    @Transactional
    public RoleDto createRole(RoleDto roleDto) {
        Role role = new Role();
        role.setRoleName(roleDto.getRoleName());
        role.setDescription(roleDto.getDescription());
        role = roleRepository.save(role);
        
        savePermissions(role, roleDto.getPermissions());
        return getRoleById(role.getId());
    }

    @Transactional
    public RoleDto updateRole(Long id, RoleDto roleDto) {
        Role role = roleRepository.findById(id).orElseThrow(() -> new RuntimeException("Role not found"));
        role.setRoleName(roleDto.getRoleName());
        role.setDescription(roleDto.getDescription());
        roleRepository.save(role);
        
        rolePermissionRepository.deleteByRoleId(id);
        savePermissions(role, roleDto.getPermissions());
        
        return getRoleById(id);
    }

    public List<RoleDto> getAllRoles() {
        return roleRepository.findAll().stream().map(role -> getRoleById(role.getId())).collect(Collectors.toList());
    }

    public RoleDto getRoleById(Long id) {
        Role role = roleRepository.findById(id).orElseThrow(() -> new RuntimeException("Role not found"));
        List<RolePermission> permissions = rolePermissionRepository.findByRoleId(id);
        
        RoleDto dto = new RoleDto();
        dto.setId(role.getId());
        dto.setRoleName(role.getRoleName());
        dto.setDescription(role.getDescription());
        
        List<PermissionDto> permissionDtos = permissions.stream().map(p -> {
            PermissionDto pDto = new PermissionDto();
            pDto.setMenuName(p.getMenuName());
            pDto.setCanView(p.isCanView());
            pDto.setCanAdd(p.isCanAdd());
            pDto.setCanEdit(p.isCanEdit());
            pDto.setCanDelete(p.isCanDelete());
            return pDto;
        }).collect(Collectors.toList());
        
        dto.setPermissions(permissionDtos);
        return dto;
    }

    private void savePermissions(Role role, List<PermissionDto> permissions) {
        if (permissions == null) return;
        List<RolePermission> toSave = permissions.stream().map(p -> {
            RolePermission rp = new RolePermission();
            rp.setRole(role);
            rp.setMenuName(p.getMenuName());
            rp.setCanView(p.isCanView());
            rp.setCanAdd(p.isCanAdd());
            rp.setCanEdit(p.isCanEdit());
            rp.setCanDelete(p.isCanDelete());
            return rp;
        }).collect(Collectors.toList());
        rolePermissionRepository.saveAll(toSave);
    }

    @Transactional
    public void deleteRole(Long id) {
        rolePermissionRepository.deleteByRoleId(id);
        roleRepository.deleteById(id);
    }
}

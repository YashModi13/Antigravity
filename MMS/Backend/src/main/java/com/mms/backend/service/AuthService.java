package com.mms.backend.service;

import com.mms.backend.dto.LoginRequest;
import com.mms.backend.dto.LoginResponse;
import com.mms.backend.entity.User;
import com.mms.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import com.mms.backend.dto.SignupRequest;

@Service
@RequiredArgsConstructor
public class AuthService {
    
    private final UserRepository userRepository;
    private final RoleService roleService;

    public User signup(SignupRequest request) {
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new RuntimeException("Account with this email already exists");
        }

        User newUser = new User();
        newUser.setFullName(request.getFullName());
        newUser.setUsername(request.getUsername());
        newUser.setPassword(request.getPassword());
        newUser.setActive(false); // Inactive until admin enables

        return userRepository.save(newUser);
    }

    public LoginResponse authenticate(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("Invalid username or password"));
                
        if (!user.getPassword().equals(request.getPassword())) {
            throw new RuntimeException("Invalid username or password");
        }
        
        if (!user.isActive()) {
            throw new RuntimeException("User is deactivated");
        }
        
        LoginResponse response = new LoginResponse();
        response.setToken("mock-jwt-token-for-" + user.getId()); 
        response.setId(user.getId());
        response.setUsername(user.getUsername());
        response.setFullName(user.getFullName());
        
        if (user.getRole() != null) {
            response.setRoleId(user.getRole().getId());
            response.setRoleName(user.getRole().getRoleName());
            response.setPermissions(roleService.getRoleById(user.getRole().getId()).getPermissions());
        }
        
        return response;
    }
}

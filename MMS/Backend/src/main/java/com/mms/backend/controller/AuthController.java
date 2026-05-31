package com.mms.backend.controller;

import com.mms.backend.dto.LoginRequest;
import com.mms.backend.dto.LoginResponse;
import com.mms.backend.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.mms.backend.dto.SignupRequest;
import com.mms.backend.entity.User;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:4200", allowCredentials = "true")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public ResponseEntity<?> signup(@RequestBody SignupRequest signupReq) {
        User user = authService.signup(signupReq);
        return ResponseEntity.ok("Activation request sent successfully. Please contact administrator to enable access.");
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest loginReq, 
                                               HttpServletRequest request, 
                                               HttpServletResponse response) {
                                               
        LoginResponse authResponse = authService.authenticate(loginReq);
        
        // 1. Session configuration and Timeout (1 hour = 3600 seconds)
        HttpSession session = request.getSession(true);
        session.setAttribute("userId", authResponse.getId());
        session.setAttribute("username", authResponse.getUsername());
        session.setMaxInactiveInterval(3600); 
        
        // 2. Cookie Management
        Cookie userCookie = new Cookie("MMS_USER", authResponse.getUsername());
        userCookie.setMaxAge(3600); 
        userCookie.setPath("/");
        userCookie.setHttpOnly(false); // Accessible by frontend if needed
        response.addCookie(userCookie);

        Cookie tokenCookie = new Cookie("MMS_TOKEN", authResponse.getToken());
        tokenCookie.setMaxAge(3600); 
        tokenCookie.setPath("/");
        tokenCookie.setHttpOnly(true); // HttpOnly for secured mock-token
        response.addCookie(tokenCookie);
        
        return ResponseEntity.ok(authResponse);
    }
    
    @PostMapping("/logout")
    public ResponseEntity<String> logout(HttpServletRequest request, HttpServletResponse response) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate(); // Clear server session
        }
        
        // Expire Cookies
        Cookie userCookie = new Cookie("MMS_USER", null);
        userCookie.setMaxAge(0);
        userCookie.setPath("/");
        response.addCookie(userCookie);
        
        Cookie tokenCookie = new Cookie("MMS_TOKEN", null);
        tokenCookie.setMaxAge(0);
        tokenCookie.setPath("/");
        response.addCookie(tokenCookie);
        
        return ResponseEntity.ok("Logged out successfully");
    }
}

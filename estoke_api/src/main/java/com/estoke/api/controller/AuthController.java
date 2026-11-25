
package com.estoke.api.controller;

import com.estoke.api.dto.LoginRequest;
import com.estoke.api.dto.LoginResponse;
import com.estoke.api.service.AuthService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
            @RequestBody LoginRequest request) {

        LoginResponse resposta = authService.login(request);

        return ResponseEntity.ok(resposta);
    }
}

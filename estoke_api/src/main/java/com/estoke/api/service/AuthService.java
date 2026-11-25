
package com.estoke.api.service;

import com.estoke.api.dto.LoginRequest;
import com.estoke.api.dto.LoginResponse;
import com.estoke.api.entity.Usuario;
import com.estoke.api.repository.UsuarioRepository;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final JwtService jwtService;
    private final BCryptPasswordEncoder passwordEncoder;

    public AuthService(
            UsuarioRepository usuarioRepository,
            JwtService jwtService) {

        this.usuarioRepository = usuarioRepository;
        this.jwtService = jwtService;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    @Transactional(readOnly = true)
    public LoginResponse login(LoginRequest request) {

        Usuario usuario = usuarioRepository
                .findByEmail(request.email())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "E-mail ou senha inválidos."
                        ));

        if (!Boolean.TRUE.equals(usuario.getAtivo())) {
            throw new IllegalArgumentException(
                    "Usuário inativo."
            );
        }

        if (!passwordEncoder.matches(
                request.senha(),
                usuario.getSenhaHash())) {

            throw new IllegalArgumentException(
                    "E-mail ou senha inválidos."
            );
        }

        String nomePerfil = usuario.getPerfil().getNome();

        String token = jwtService.gerarToken(
                usuario.getEmail(),
                nomePerfil
        );

        return new LoginResponse(
                token,
                "Bearer",
                usuario.getId(),
                usuario.getNome(),
                usuario.getEmail(),
                nomePerfil
        );
    }
}

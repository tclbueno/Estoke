
package com.estoke.api.dto;

public record LoginResponse(
    String token,
    String tipo,
    Long usuarioId,
    String nome,
    String email,
    String perfil
) {
}

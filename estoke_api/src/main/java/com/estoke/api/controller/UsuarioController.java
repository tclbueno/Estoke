
package com.estoke.api.controller;

import com.estoke.api.entity.Usuario;
import com.estoke.api.service.UsuarioService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    // LISTAR TODOS OS USUÁRIOS
    @GetMapping
    public ResponseEntity<List<Usuario>> listarTodos() {
        return ResponseEntity.ok(usuarioService.listarTodos());
    }

    // BUSCAR USUÁRIO POR ID
    @GetMapping("/{id}")
    public ResponseEntity<Usuario> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(usuarioService.buscarPorId(id));
    }

    // CADASTRAR USUÁRIO
    @PostMapping
    public ResponseEntity<Usuario> cadastrar(
            @RequestBody Usuario usuario,
            @RequestParam Long perfilId) {

        Usuario novoUsuario =
                usuarioService.cadastrar(usuario, perfilId);

        return ResponseEntity.status(HttpStatus.CREATED).body(novoUsuario);
    }

    // ATUALIZAR USUÁRIO
    @PutMapping("/{id}")
    public ResponseEntity<Usuario> atualizar(
            @PathVariable Long id,
            @RequestBody Usuario usuario,
            @RequestParam Long perfilId) {

        Usuario usuarioAtualizado =
                usuarioService.atualizar(id, usuario, perfilId);

        return ResponseEntity.ok(usuarioAtualizado);
    }

    // EXCLUIR USUÁRIO
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {

        usuarioService.excluir(id);

        return ResponseEntity.noContent().build();
    }
}

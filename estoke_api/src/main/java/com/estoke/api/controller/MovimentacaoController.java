
package com.estoke.api.controller;

import com.estoke.api.entity.Movimentacao;
import com.estoke.api.service.MovimentacaoService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/movimentacoes")
@CrossOrigin(origins = "*")
public class MovimentacaoController {

    private final MovimentacaoService movimentacaoService;

    public MovimentacaoController(
            MovimentacaoService movimentacaoService) {
        this.movimentacaoService = movimentacaoService;
    }

    // LISTAR TODAS AS MOVIMENTAÇÕES
    @GetMapping
    public ResponseEntity<List<Movimentacao>> listarTodas() {
        return ResponseEntity.ok(
                movimentacaoService.listarTodas());
    }

    // BUSCAR MOVIMENTAÇÃO POR ID
    @GetMapping("/{id}")
    public ResponseEntity<Movimentacao> buscarPorId(
            @PathVariable Long id) {
        return ResponseEntity.ok(
                movimentacaoService.buscarPorId(id));
    }

    // LISTAR MOVIMENTAÇÕES DE UM MATERIAL
    @GetMapping("/material/{materialId}")
    public ResponseEntity<List<Movimentacao>> listarPorMaterial(
            @PathVariable Long materialId) {
        return ResponseEntity.ok(
                movimentacaoService.listarPorMaterial(materialId));
    }

    // LISTAR MOVIMENTAÇÕES DE UM USUÁRIO
    @GetMapping("/usuario/{usuarioId}")
    public ResponseEntity<List<Movimentacao>> listarPorUsuario(
            @PathVariable Long usuarioId) {
        return ResponseEntity.ok(
                movimentacaoService.listarPorUsuario(usuarioId));
    }

    // CADASTRAR MOVIMENTAÇÃO
    @PostMapping
    public ResponseEntity<Movimentacao> cadastrar(
            @RequestBody Movimentacao movimentacao,
            @RequestParam Long materialId,
            @RequestParam Long usuarioId,
            @RequestParam(required = false) Long variacaoId) {

        Movimentacao novaMovimentacao =
                movimentacaoService.cadastrar(
                        movimentacao,
                        materialId,
                        usuarioId,
                        variacaoId);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(novaMovimentacao);
    }

    // ATUALIZAR MOVIMENTAÇÃO
    @PutMapping("/{id}")
    public ResponseEntity<Movimentacao> atualizar(
            @PathVariable Long id,
            @RequestBody Movimentacao movimentacao,
            @RequestParam Long materialId,
            @RequestParam Long usuarioId,
            @RequestParam(required = false) Long variacaoId) {

        Movimentacao atualizada =
                movimentacaoService.atualizar(
                        id,
                        movimentacao,
                        materialId,
                        usuarioId,
                        variacaoId);

        return ResponseEntity.ok(atualizada);
    }

    // EXCLUIR MOVIMENTAÇÃO
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {

        movimentacaoService.excluir(id);

        return ResponseEntity.noContent().build();
    }
}

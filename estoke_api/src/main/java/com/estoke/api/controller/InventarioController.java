
package com.estoke.api.controller;

import com.estoke.api.entity.Inventario;
import com.estoke.api.service.InventarioService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/inventarios")
@CrossOrigin(origins = "*")
public class InventarioController {

    private final InventarioService inventarioService;

    public InventarioController(InventarioService inventarioService) {
        this.inventarioService = inventarioService;
    }

    // LISTAR TODOS OS INVENTÁRIOS
    @GetMapping
    public ResponseEntity<List<Inventario>> listarTodos() {
        return ResponseEntity.ok(
                inventarioService.listarTodos());
    }

    // BUSCAR INVENTÁRIO POR ID
    @GetMapping("/{id}")
    public ResponseEntity<Inventario> buscarPorId(
            @PathVariable Long id) {

        return ResponseEntity.ok(
                inventarioService.buscarPorId(id));
    }

    // CADASTRAR INVENTÁRIO
    @PostMapping
    public ResponseEntity<Inventario> cadastrar(
            @RequestBody Inventario inventario,
            @RequestParam Long usuarioId) {

        Inventario novoInventario =
                inventarioService.cadastrar(inventario, usuarioId);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(novoInventario);
    }

    // ATUALIZAR INVENTÁRIO
    @PutMapping("/{id}")
    public ResponseEntity<Inventario> atualizar(
            @PathVariable Long id,
            @RequestBody Inventario inventario,
            @RequestParam Long usuarioId) {

        Inventario inventarioAtualizado =
                inventarioService.atualizar(id, inventario, usuarioId);

        return ResponseEntity.ok(inventarioAtualizado);
    }

    // EXCLUIR INVENTÁRIO
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(
            @PathVariable Long id) {

        inventarioService.excluir(id);

        return ResponseEntity.noContent().build();
    }
}

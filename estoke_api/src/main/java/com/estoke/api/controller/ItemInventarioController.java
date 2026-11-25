
package com.estoke.api.controller;

import com.estoke.api.entity.ItemInventario;
import com.estoke.api.service.ItemInventarioService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/itens-inventario")
@CrossOrigin(origins = "*")
public class ItemInventarioController {

    private final ItemInventarioService itemService;

    public ItemInventarioController(
            ItemInventarioService itemService) {
        this.itemService = itemService;
    }

    // LISTAR TODOS OS ITENS
    @GetMapping
    public ResponseEntity<List<ItemInventario>> listarTodos() {
        return ResponseEntity.ok(itemService.listarTodos());
    }

    // BUSCAR ITEM POR ID
    @GetMapping("/{id}")
    public ResponseEntity<ItemInventario> buscarPorId(
            @PathVariable Long id) {
        return ResponseEntity.ok(itemService.buscarPorId(id));
    }

    // LISTAR ITENS DE UM INVENTÁRIO
    @GetMapping("/inventario/{inventarioId}")
    public ResponseEntity<List<ItemInventario>> listarPorInventario(
            @PathVariable Long inventarioId) {
        return ResponseEntity.ok(
                itemService.listarPorInventario(inventarioId));
    }

    // CADASTRAR ITEM
    @PostMapping
    public ResponseEntity<ItemInventario> cadastrar(
            @RequestBody ItemInventario item,
            @RequestParam Long inventarioId,
            @RequestParam Long materialId,
            @RequestParam(required = false) Long variacaoId) {

        ItemInventario novoItem = itemService.cadastrar(
                item, inventarioId, materialId, variacaoId);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(novoItem);
    }

    // ATUALIZAR ITEM
    @PutMapping("/{id}")
    public ResponseEntity<ItemInventario> atualizar(
            @PathVariable Long id,
            @RequestBody ItemInventario item,
            @RequestParam Long inventarioId,
            @RequestParam Long materialId,
            @RequestParam(required = false) Long variacaoId) {

        ItemInventario itemAtualizado = itemService.atualizar(
                id, item, inventarioId, materialId, variacaoId);

        return ResponseEntity.ok(itemAtualizado);
    }

    // EXCLUIR ITEM
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {

        itemService.excluir(id);

        return ResponseEntity.noContent().build();
    }
}

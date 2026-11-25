
package com.estoke.api.controller;

import com.estoke.api.entity.Material;
import com.estoke.api.service.MaterialService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/materiais")
@CrossOrigin(origins = "*")
public class MaterialController {

    private final MaterialService materialService;

    public MaterialController(MaterialService materialService) {
        this.materialService = materialService;
    }

    @GetMapping
    public ResponseEntity<List<Material>> listarTodos() {
        return ResponseEntity.ok(materialService.listarTodos());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Material> buscarPorId(@PathVariable Long id) {
        return ResponseEntity.ok(materialService.buscarPorId(id));
    }

    @GetMapping("/buscar")
    public ResponseEntity<List<Material>> buscarPorNome(
            @RequestParam String nome) {

        return ResponseEntity.ok(
                materialService.buscarPorNome(nome)
        );
    }

    @GetMapping("/categoria/{categoriaId}")
    public ResponseEntity<List<Material>> buscarPorCategoria(
            @PathVariable Long categoriaId) {

        return ResponseEntity.ok(
                materialService.buscarPorCategoria(categoriaId)
        );
    }

    @PostMapping
    public ResponseEntity<Material> cadastrar(
            @RequestBody Material material,
            @RequestParam Long categoriaId) {

        Material novoMaterial =
                materialService.cadastrar(material, categoriaId);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(novoMaterial);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Material> atualizar(
            @PathVariable Long id,
            @RequestBody Material material,
            @RequestParam Long categoriaId) {

        return ResponseEntity.ok(
                materialService.atualizar(id, material, categoriaId)
        );
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        materialService.excluir(id);
        return ResponseEntity.noContent().build();
    }
}


package com.estoke.api.controller;

import com.estoke.api.entity.VariacaoMaterial;
import com.estoke.api.service.VariacaoMaterialService;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/variacoes")
public class VariacaoMaterialController {

    private final VariacaoMaterialService variacaoService;

    public VariacaoMaterialController(
            VariacaoMaterialService variacaoService) {

        this.variacaoService = variacaoService;
    }

    // LISTAR TODAS AS VARIAÇÕES
    @GetMapping
    public ResponseEntity<List<VariacaoMaterial>> listarTodas() {

        return ResponseEntity.ok(
                variacaoService.listarTodas());
    }

    // BUSCAR VARIAÇÃO POR ID
    @GetMapping("/{id}")
    public ResponseEntity<VariacaoMaterial> buscarPorId(
            @PathVariable Long id) {

        return ResponseEntity.ok(
                variacaoService.buscarPorId(id));
    }

    // LISTAR VARIAÇÕES DE UM MATERIAL
    @GetMapping("/material/{materialId}")
    public ResponseEntity<List<VariacaoMaterial>> listarPorMaterial(
            @PathVariable Long materialId) {

        return ResponseEntity.ok(
                variacaoService.listarPorMaterial(materialId));
    }

    // CADASTRAR VARIAÇÃO
    @PostMapping
    public ResponseEntity<VariacaoMaterial> cadastrar(
            @RequestParam Long materialId,
            @RequestBody VariacaoMaterial variacao) {

        VariacaoMaterial salva =
                variacaoService.cadastrar(variacao, materialId);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(salva);
    }

    // ATUALIZAR VARIAÇÃO
    @PutMapping("/{id}")
    public ResponseEntity<VariacaoMaterial> atualizar(
            @PathVariable Long id,
            @RequestParam Long materialId,
            @RequestBody VariacaoMaterial dados) {

        return ResponseEntity.ok(
                variacaoService.atualizar(
                        id, dados, materialId));
    }

    // EXCLUIR VARIAÇÃO
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(
            @PathVariable Long id) {

        variacaoService.excluir(id);

        return ResponseEntity.noContent().build();
    }
}


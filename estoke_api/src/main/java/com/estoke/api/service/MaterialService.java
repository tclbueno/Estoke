
package com.estoke.api.service;

import com.estoke.api.entity.Categoria;
import com.estoke.api.entity.Material;
import com.estoke.api.repository.CategoriaRepository;
import com.estoke.api.repository.MaterialRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MaterialService {

    private final MaterialRepository materialRepository;
    private final CategoriaRepository categoriaRepository;

    public MaterialService(
            MaterialRepository materialRepository,
            CategoriaRepository categoriaRepository
    ) {
        this.materialRepository = materialRepository;
        this.categoriaRepository = categoriaRepository;
    }

    public List<Material> listarTodos() {
        return materialRepository.findAll();
    }

    public Material buscarPorId(Long id) {
        return materialRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Material não encontrado."
                        )
                );
    }

    public List<Material> buscarPorNome(String nome) {
        return materialRepository.findByNomeContainingIgnoreCase(nome);
    }

    public List<Material> buscarPorCategoria(Long categoriaId) {
        return materialRepository.findByCategoriaId(categoriaId);
    }

    public Material cadastrar(Material material, Long categoriaId) {

        Categoria categoria = categoriaRepository.findById(categoriaId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Categoria não encontrada."
                        )
                );

        material.setCategoria(categoria);

        return materialRepository.save(material);
    }

    public Material atualizar(
            Long id,
            Material dados,
            Long categoriaId
    ) {

        Material material = buscarPorId(id);

        Categoria categoria = categoriaRepository.findById(categoriaId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Categoria não encontrada."
                        )
                );

        material.setNome(dados.getNome());
        material.setCategoria(categoria);
        material.setQuantidade(dados.getQuantidade());
        material.setQuantidadeMinima(dados.getQuantidadeMinima());
        material.setUnidade(dados.getUnidade());
        material.setLocalizacao(dados.getLocalizacao());
        material.setDescricao(dados.getDescricao());

        return materialRepository.save(material);
    }

    public void excluir(Long id) {
        Material material = buscarPorId(id);
        materialRepository.delete(material);
    }
}

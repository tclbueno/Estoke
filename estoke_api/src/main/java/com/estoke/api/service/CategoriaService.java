
package com.estoke.api.service;

import com.estoke.api.entity.Categoria;
import com.estoke.api.repository.CategoriaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CategoriaService {

    private final CategoriaRepository categoriaRepository;

    public CategoriaService(CategoriaRepository categoriaRepository) {
        this.categoriaRepository = categoriaRepository;
    }

    public List<Categoria> listarTodas() {
        return categoriaRepository.findAll();
    }

    public Categoria buscarPorId(Long id) {
        return categoriaRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Categoria não encontrada."
                        )
                );
    }

    public Categoria cadastrar(Categoria categoria) {

        if (categoriaRepository.findByNome(categoria.getNome()).isPresent()) {
            throw new IllegalArgumentException(
                    "Já existe uma categoria com esse nome."
            );
        }

        return categoriaRepository.save(categoria);
    }

    public Categoria atualizar(Long id, Categoria dados) {

        Categoria categoria = buscarPorId(id);

        categoria.setNome(dados.getNome());
        categoria.setDescricao(dados.getDescricao());

        return categoriaRepository.save(categoria);
    }

    public void excluir(Long id) {
        Categoria categoria = buscarPorId(id);
        categoriaRepository.delete(categoria);
    }
}



package com.estoke.api.service;

import com.estoke.api.entity.Material;
import com.estoke.api.entity.VariacaoMaterial;
import com.estoke.api.repository.MaterialRepository;
import com.estoke.api.repository.VariacaoMaterialRepository;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class VariacaoMaterialService {

    private final VariacaoMaterialRepository variacaoRepository;
    private final MaterialRepository materialRepository;

    public VariacaoMaterialService(
            VariacaoMaterialRepository variacaoRepository,
            MaterialRepository materialRepository) {

        this.variacaoRepository = variacaoRepository;
        this.materialRepository = materialRepository;
    }

    // LISTAR TODAS AS VARIAÇÕES
    public List<VariacaoMaterial> listarTodas() {
        return variacaoRepository.findAll();
    }

    // BUSCAR VARIAÇÃO POR ID
    public VariacaoMaterial buscarPorId(Long id) {
        return variacaoRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Variação não encontrada."));
    }

    // LISTAR VARIAÇÕES POR MATERIAL
    public List<VariacaoMaterial> listarPorMaterial(Long materialId) {

        return variacaoRepository.findAll()
                .stream()
                .filter(variacao ->
                        variacao.getMaterial().getId().equals(materialId))
                .toList();
    }

    // CADASTRAR VARIAÇÃO
    public VariacaoMaterial cadastrar(
            VariacaoMaterial variacao,
            Long materialId) {

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Material não encontrado."));

        validarVariacao(variacao);

        variacao.setMaterial(material);

        return variacaoRepository.save(variacao);
    }

    // ATUALIZAR VARIAÇÃO
    public VariacaoMaterial atualizar(
            Long id,
            VariacaoMaterial dados,
            Long materialId) {

        VariacaoMaterial existente = buscarPorId(id);

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Material não encontrado."));

        validarVariacao(dados);

        existente.setMaterial(material);
        existente.setNome(dados.getNome());
        existente.setQuantidade(dados.getQuantidade());
        existente.setQuantidadeMinima(dados.getQuantidadeMinima());

        return variacaoRepository.save(existente);
    }

    // EXCLUIR VARIAÇÃO
    public void excluir(Long id) {

        VariacaoMaterial variacao = buscarPorId(id);

        variacaoRepository.delete(variacao);
    }

    // VALIDAR VARIAÇÃO
    private void validarVariacao(VariacaoMaterial variacao) {

        if (variacao.getNome() == null
                || variacao.getNome().isBlank()) {

            throw new IllegalArgumentException(
                    "O nome da variação é obrigatório.");
        }

        if (variacao.getQuantidade() == null
                || variacao.getQuantidade()
                .compareTo(BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "A quantidade não pode ser negativa.");
        }

        if (variacao.getQuantidadeMinima() == null
                || variacao.getQuantidadeMinima()
                .compareTo(BigDecimal.ZERO) < 0) {

            throw new IllegalArgumentException(
                    "A quantidade mínima não pode ser negativa.");
        }
    }
}

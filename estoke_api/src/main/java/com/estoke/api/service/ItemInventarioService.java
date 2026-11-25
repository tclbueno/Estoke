
package com.estoke.api.service;

import com.estoke.api.entity.ItemInventario;
import com.estoke.api.entity.Inventario;
import com.estoke.api.entity.Material;
import com.estoke.api.entity.VariacaoMaterial;

import com.estoke.api.repository.ItemInventarioRepository;
import com.estoke.api.repository.InventarioRepository;
import com.estoke.api.repository.MaterialRepository;
import com.estoke.api.repository.VariacaoMaterialRepository;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class ItemInventarioService {

    private final ItemInventarioRepository itemRepository;
    private final InventarioRepository inventarioRepository;
    private final MaterialRepository materialRepository;
    private final VariacaoMaterialRepository variacaoRepository;

    public ItemInventarioService(
            ItemInventarioRepository itemRepository,
            InventarioRepository inventarioRepository,
            MaterialRepository materialRepository,
            VariacaoMaterialRepository variacaoRepository) {

        this.itemRepository = itemRepository;
        this.inventarioRepository = inventarioRepository;
        this.materialRepository = materialRepository;
        this.variacaoRepository = variacaoRepository;
    }

    // LISTAR TODOS OS ITENS
    public List<ItemInventario> listarTodos() {
        return itemRepository.findAll();
    }

    // BUSCAR ITEM POR ID
    public ItemInventario buscarPorId(Long id) {
        return itemRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Item de inventário não encontrado."));
    }

    // LISTAR ITENS DE UM INVENTÁRIO
    public List<ItemInventario> listarPorInventario(Long inventarioId) {
        return itemRepository.findAll().stream()
                .filter(item ->
                        item.getInventario().getId().equals(inventarioId))
                .toList();
    }

    // CADASTRAR ITEM
    public ItemInventario cadastrar(
            ItemInventario item,
            Long inventarioId,
            Long materialId,
            Long variacaoId) {

        Inventario inventario = inventarioRepository.findById(inventarioId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Inventário não encontrado."));

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Material não encontrado."));

        VariacaoMaterial variacao = buscarVariacao(
                variacaoId, materialId);

        validarDuplicidade(
                inventarioId, materialId, variacaoId, null);

        item.setInventario(inventario);
        item.setMaterial(material);
        item.setVariacao(variacao);

        calcularDiferenca(item);

        return itemRepository.save(item);
    }

    // ATUALIZAR ITEM
    public ItemInventario atualizar(
            Long id,
            ItemInventario dados,
            Long inventarioId,
            Long materialId,
            Long variacaoId) {

        ItemInventario itemExistente = buscarPorId(id);

        Inventario inventario = inventarioRepository.findById(inventarioId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Inventário não encontrado."));

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Material não encontrado."));

        VariacaoMaterial variacao = buscarVariacao(
                variacaoId, materialId);

        validarDuplicidade(
                inventarioId, materialId, variacaoId, id);

        itemExistente.setInventario(inventario);
        itemExistente.setMaterial(material);
        itemExistente.setVariacao(variacao);

        itemExistente.setQuantidadeSistema(
                dados.getQuantidadeSistema());

        itemExistente.setQuantidadeContada(
                dados.getQuantidadeContada());

        calcularDiferenca(itemExistente);

        return itemRepository.save(itemExistente);
    }

    // BUSCAR E VALIDAR VARIAÇÃO
    private VariacaoMaterial buscarVariacao(
            Long variacaoId,
            Long materialId) {

        if (variacaoId == null) {
            return null;
        }

        VariacaoMaterial variacao = variacaoRepository.findById(variacaoId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Variação não encontrada."));

        if (!variacao.getMaterial().getId().equals(materialId)) {
            throw new IllegalArgumentException(
                    "A variação não pertence ao material informado.");
        }

        return variacao;
    }

    // VALIDAR DUPLICIDADE
    private void validarDuplicidade(
            Long inventarioId,
            Long materialId,
            Long variacaoId,
            Long itemId) {

        boolean duplicado;

        if (variacaoId == null) {

            if (itemId == null) {
                duplicado = itemRepository
                        .existsByInventario_IdAndMaterial_IdAndVariacaoIsNull(
                                inventarioId, materialId);
            } else {
                duplicado = itemRepository
                        .existsByInventario_IdAndMaterial_IdAndVariacaoIsNullAndIdNot(
                                inventarioId, materialId, itemId);
            }

        } else {

            if (itemId == null) {
                duplicado = itemRepository
                        .existsByInventario_IdAndMaterial_IdAndVariacao_Id(
                                inventarioId, materialId, variacaoId);
            } else {
                duplicado = itemRepository
                        .existsByInventario_IdAndMaterial_IdAndVariacao_IdAndIdNot(
                                inventarioId, materialId, variacaoId, itemId);
            }
        }

        if (duplicado) {
            throw new IllegalArgumentException(
                    "Este material e esta variação já foram cadastrados neste inventário.");
        }
    }

    // CALCULAR DIFERENÇA
    private void calcularDiferenca(ItemInventario item) {

        if (item.getQuantidadeSistema() == null
                || item.getQuantidadeContada() == null) {

            throw new IllegalArgumentException(
                    "As quantidades do sistema e da contagem são obrigatórias.");
        }

        BigDecimal diferenca = item.getQuantidadeContada()
                .subtract(item.getQuantidadeSistema());

        item.setDiferenca(diferenca);
    }

    // EXCLUIR ITEM
    public void excluir(Long id) {
        ItemInventario item = buscarPorId(id);
        itemRepository.delete(item);
    }
}

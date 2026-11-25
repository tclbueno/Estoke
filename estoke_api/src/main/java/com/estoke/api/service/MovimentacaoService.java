
package com.estoke.api.service;

import com.estoke.api.entity.*;
import com.estoke.api.repository.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
public class MovimentacaoService {

    private final MovimentacaoRepository movimentacaoRepository;
    private final MaterialRepository materialRepository;
    private final UsuarioRepository usuarioRepository;
    private final VariacaoMaterialRepository variacaoRepository;
    private final SimpMessagingTemplate messagingTemplate;

    public MovimentacaoService(
            MovimentacaoRepository movimentacaoRepository,
            MaterialRepository materialRepository,
            UsuarioRepository usuarioRepository,
            VariacaoMaterialRepository variacaoRepository,
            SimpMessagingTemplate messagingTemplate) {

        this.movimentacaoRepository = movimentacaoRepository;
        this.materialRepository = materialRepository;
        this.usuarioRepository = usuarioRepository;
        this.variacaoRepository = variacaoRepository;
        this.messagingTemplate = messagingTemplate;
    }

    // LISTAR TODAS AS MOVIMENTAÇÕES
    public List<Movimentacao> listarTodas() {
        return movimentacaoRepository.findAll();
    }

    // BUSCAR MOVIMENTAÇÃO POR ID
    public Movimentacao buscarPorId(Long id) {
        return movimentacaoRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Movimentação não encontrada."));
    }

    // LISTAR MOVIMENTAÇÕES DE UM MATERIAL
    public List<Movimentacao> listarPorMaterial(Long materialId) {
        return movimentacaoRepository.findByMaterialId(materialId);
    }

    // LISTAR MOVIMENTAÇÕES DE UM USUÁRIO
    public List<Movimentacao> listarPorUsuario(Long usuarioId) {
        return movimentacaoRepository.findByUsuarioId(usuarioId);
    }

    // CADASTRAR MOVIMENTAÇÃO
    @Transactional
    public Movimentacao cadastrar(
            Movimentacao movimentacao,
            Long materialId,
            Long usuarioId,
            Long variacaoId) {

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Material não encontrado."));

        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Usuário não encontrado."));

        movimentacao.setMaterial(material);
        movimentacao.setUsuario(usuario);

        if (variacaoId != null) {
            VariacaoMaterial variacao =
                    buscarVariacao(variacaoId, materialId);

            movimentacao.setVariacao(variacao);
        }

        validarMovimentacao(movimentacao);
        aplicarMovimentacao(movimentacao);

        Movimentacao salva =
                movimentacaoRepository.save(movimentacao);

        publicarEvento("CRIADA", salva);

        return salva;
    }

    // ATUALIZAR MOVIMENTAÇÃO
    @Transactional
    public Movimentacao atualizar(
            Long id,
            Movimentacao dados,
            Long materialId,
            Long usuarioId,
            Long variacaoId) {

        Movimentacao existente = buscarPorId(id);

        // Desfaz o efeito da movimentação anterior.
        reverterMovimentacao(existente);

        Material material = materialRepository.findById(materialId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Material não encontrado."));

        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Usuário não encontrado."));

        existente.setMaterial(material);
        existente.setUsuario(usuario);
        existente.setTipo(dados.getTipo());
        existente.setQuantidade(dados.getQuantidade());
        existente.setMotivo(dados.getMotivo());
        existente.setOutroMotivo(dados.getOutroMotivo());
        existente.setObservacao(dados.getObservacao());

        if (variacaoId != null) {
            existente.setVariacao(
                    buscarVariacao(variacaoId, materialId));
        } else {
            existente.setVariacao(null);
        }

        validarMovimentacao(existente);
        aplicarMovimentacao(existente);

        Movimentacao atualizada =
                movimentacaoRepository.save(existente);

        publicarEvento("ATUALIZADA", atualizada);

        return atualizada;
    }

    // EXCLUIR MOVIMENTAÇÃO
    @Transactional
    public void excluir(Long id) {

        Movimentacao movimentacao = buscarPorId(id);

        // Recupera o estoque anterior à movimentação.
        reverterMovimentacao(movimentacao);

        // Publica os dados antes da exclusão.
        publicarEvento("EXCLUIDA", movimentacao);

        movimentacaoRepository.delete(movimentacao);
    }

    // BUSCAR VARIAÇÃO E CONFERIR SE PERTENCE AO MATERIAL
    private VariacaoMaterial buscarVariacao(
            Long variacaoId,
            Long materialId) {

        VariacaoMaterial variacao =
                variacaoRepository.findById(variacaoId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Variação não encontrada."));

        if (!variacao.getMaterial().getId().equals(materialId)) {
            throw new IllegalArgumentException(
                    "A variação não pertence ao material informado.");
        }

        return variacao;
    }

    // VALIDAR DADOS DA MOVIMENTAÇÃO
    private void validarMovimentacao(Movimentacao movimentacao) {

        if (movimentacao.getTipo() == null) {
            throw new IllegalArgumentException(
                    "O tipo da movimentação é obrigatório.");
        }

        if (movimentacao.getQuantidade() == null
                || movimentacao.getQuantidade()
                .compareTo(BigDecimal.ZERO) <= 0) {

            throw new IllegalArgumentException(
                    "A quantidade deve ser maior que zero.");
        }

        if (movimentacao.getMotivo() == null
                || movimentacao.getMotivo().isBlank()) {

            throw new IllegalArgumentException(
                    "O motivo da movimentação é obrigatório.");
        }
    }

    // APLICAR ENTRADA OU SAÍDA
    private void aplicarMovimentacao(Movimentacao movimentacao) {

        BigDecimal quantidade = movimentacao.getQuantidade();
        BigDecimal saldo = obterSaldo(movimentacao);

        if (movimentacao.getTipo() == TipoMovimentacao.ENTRADA) {

            saldo = saldo.add(quantidade);

        } else {

            if (saldo.compareTo(quantidade) < 0) {
                throw new IllegalArgumentException(
                        "Estoque insuficiente para realizar a saída.");
            }

            saldo = saldo.subtract(quantidade);
        }

        atualizarSaldo(movimentacao, saldo);
    }

    // REVERTER UMA MOVIMENTAÇÃO
    private void reverterMovimentacao(Movimentacao movimentacao) {

        BigDecimal quantidade = movimentacao.getQuantidade();
        BigDecimal saldo = obterSaldo(movimentacao);

        if (movimentacao.getTipo() == TipoMovimentacao.ENTRADA) {

            if (saldo.compareTo(quantidade) < 0) {
                throw new IllegalArgumentException(
                        "Não é possível reverter a entrada: estoque insuficiente.");
            }

            saldo = saldo.subtract(quantidade);

        } else {

            saldo = saldo.add(quantidade);
        }

        atualizarSaldo(movimentacao, saldo);
    }

    // OBTER SALDO DO MATERIAL OU DA VARIAÇÃO
    private BigDecimal obterSaldo(Movimentacao movimentacao) {

        if (movimentacao.getVariacao() != null) {
            return movimentacao.getVariacao().getQuantidade();
        }

        return movimentacao.getMaterial().getQuantidade();
    }

    // ATUALIZAR SALDO NO BANCO
    private void atualizarSaldo(
            Movimentacao movimentacao,
            BigDecimal saldo) {

        if (movimentacao.getVariacao() != null) {

            movimentacao.getVariacao().setQuantidade(saldo);
            variacaoRepository.save(movimentacao.getVariacao());

        } else {

            movimentacao.getMaterial().setQuantidade(saldo);
            materialRepository.save(movimentacao.getMaterial());
        }
    }

    // PUBLICAR EVENTO WEBSOCKET
    private void publicarEvento(
            String acao,
            Movimentacao movimentacao) {

        Map<String, Object> evento = new HashMap<>();

        evento.put("acao", acao);
        evento.put("id", movimentacao.getId());
        evento.put("material", movimentacao.getMaterial().getNome());
        evento.put("tipo", movimentacao.getTipo().name());
        evento.put("quantidade", movimentacao.getQuantidade());
        evento.put("motivo", movimentacao.getMotivo());

        messagingTemplate.convertAndSend(
                "/topic/movimentacoes",
                (Object) evento
        );
    }
}

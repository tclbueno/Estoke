
package com.estoke.api.service;

import com.estoke.api.entity.Inventario;
import com.estoke.api.entity.Usuario;
import com.estoke.api.repository.InventarioRepository;
import com.estoke.api.repository.UsuarioRepository;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class InventarioService {

    private final InventarioRepository inventarioRepository;
    private final UsuarioRepository usuarioRepository;

    public InventarioService(
            InventarioRepository inventarioRepository,
            UsuarioRepository usuarioRepository) {

        this.inventarioRepository = inventarioRepository;
        this.usuarioRepository = usuarioRepository;
    }

    // LISTAR TODOS OS INVENTÁRIOS
    public List<Inventario> listarTodos() {
        return inventarioRepository.findAll();
    }

    // BUSCAR INVENTÁRIO POR ID
    public Inventario buscarPorId(Long id) {
        return inventarioRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Inventário não encontrado."));
    }

    // CADASTRAR INVENTÁRIO
    public Inventario cadastrar(Inventario inventario, Long usuarioId) {

        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Usuário não encontrado."));

        if (inventario.getDataInventario() == null) {
            inventario.setDataInventario(LocalDateTime.now());
        }

        inventario.setUsuario(usuario);

        return inventarioRepository.save(inventario);
    }

    // ATUALIZAR INVENTÁRIO
    public Inventario atualizar(
            Long id,
            Inventario dados,
            Long usuarioId) {

        Inventario inventarioExistente = buscarPorId(id);

        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Usuário não encontrado."));

        inventarioExistente.setUsuario(usuario);

        if (dados.getDataInventario() != null) {
            inventarioExistente.setDataInventario(
                    dados.getDataInventario());
        }

        inventarioExistente.setObservacao(dados.getObservacao());

        return inventarioRepository.save(inventarioExistente);
    }

    // EXCLUIR INVENTÁRIO
    public void excluir(Long id) {

        Inventario inventario = buscarPorId(id);

        inventarioRepository.delete(inventario);
    }
}

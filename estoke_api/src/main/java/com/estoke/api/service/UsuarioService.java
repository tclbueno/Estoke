
package com.estoke.api.service;

import com.estoke.api.entity.Perfil;
import com.estoke.api.entity.Usuario;
import com.estoke.api.repository.PerfilRepository;
import com.estoke.api.repository.UsuarioRepository;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final PerfilRepository perfilRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    public UsuarioService(
            UsuarioRepository usuarioRepository,
            PerfilRepository perfilRepository) {

        this.usuarioRepository = usuarioRepository;
        this.perfilRepository = perfilRepository;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    // LISTAR TODOS OS USUÁRIOS
    public List<Usuario> listarTodos() {
        return usuarioRepository.findAll();
    }

    // BUSCAR USUÁRIO POR ID
    public Usuario buscarPorId(Long id) {
        return usuarioRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException("Usuário não encontrado."));
    }

    // CADASTRAR USUÁRIO
    public Usuario cadastrar(Usuario usuario, Long perfilId) {

        if (usuarioRepository.existsByEmail(usuario.getEmail())) {
            throw new IllegalArgumentException(
                    "Já existe um usuário cadastrado com esse e-mail.");
        }

        Perfil perfil = perfilRepository.findById(perfilId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Perfil não encontrado."));

        usuario.setPerfil(perfil);

        String senhaCriptografada =
                passwordEncoder.encode(usuario.getSenhaHash());

        usuario.setSenhaHash(senhaCriptografada);
        usuario.setAtivo(true);

        return usuarioRepository.save(usuario);
    }

    // ATUALIZAR USUÁRIO
    public Usuario atualizar(Long id, Usuario dados, Long perfilId) {

        Usuario usuarioExistente = buscarPorId(id);

        if (dados.getNome() == null || dados.getNome().isBlank()) {
            throw new IllegalArgumentException(
                    "O nome do usuário é obrigatório.");
        }

        if (dados.getEmail() == null || dados.getEmail().isBlank()) {
            throw new IllegalArgumentException(
                    "O e-mail do usuário é obrigatório.");
        }

        if (usuarioRepository.existsByEmailAndIdNot(
                dados.getEmail(), id)) {
            throw new IllegalArgumentException(
                    "Esse e-mail já está sendo utilizado por outro usuário.");
        }

        Perfil perfil = perfilRepository.findById(perfilId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Perfil não encontrado."));

        usuarioExistente.setNome(dados.getNome());
        usuarioExistente.setEmail(dados.getEmail());
        usuarioExistente.setPerfil(perfil);

        if (dados.getAtivo() != null) {
            usuarioExistente.setAtivo(dados.getAtivo());
        }

        // Só altera a senha quando uma nova senha for informada.
        if (dados.getSenhaHash() != null
                && !dados.getSenhaHash().isBlank()) {

            String senhaCriptografada =
                    passwordEncoder.encode(dados.getSenhaHash());

            usuarioExistente.setSenhaHash(senhaCriptografada);
        }

        return usuarioRepository.save(usuarioExistente);
    }

    // EXCLUIR USUÁRIO
    public void excluir(Long id) {

        Usuario usuario = buscarPorId(id);

        usuarioRepository.delete(usuario);
    }
}

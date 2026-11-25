
package com.estoke.api.repository;

import com.estoke.api.entity.Movimentacao;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface MovimentacaoRepository
        extends JpaRepository<Movimentacao, Long> {

    List<Movimentacao> findByMaterialId(Long materialId);

    List<Movimentacao> findByUsuarioId(Long usuarioId);
}


package com.estoke.api.repository;

import com.estoke.api.entity.ItemInventario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemInventarioRepository
        extends JpaRepository<ItemInventario, Long> {

    // Verifica duplicidade sem variação
    boolean existsByInventario_IdAndMaterial_IdAndVariacaoIsNull(
            Long inventarioId,
            Long materialId
    );

    // Verifica duplicidade com variação
    boolean existsByInventario_IdAndMaterial_IdAndVariacao_Id(
            Long inventarioId,
            Long materialId,
            Long variacaoId
    );

    // Verifica duplicidade sem variação, ignorando o próprio item
    boolean existsByInventario_IdAndMaterial_IdAndVariacaoIsNullAndIdNot(
            Long inventarioId,
            Long materialId,
            Long id
    );

    // Verifica duplicidade com variação, ignorando o próprio item
    boolean existsByInventario_IdAndMaterial_IdAndVariacao_IdAndIdNot(
            Long inventarioId,
            Long materialId,
            Long variacaoId,
            Long id
    );
}


package com.estoke.api.repository;

import com.estoke.api.entity.Material;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.EntityGraph;

import java.util.List;
import java.util.Optional;

public interface MaterialRepository extends JpaRepository<Material, Long> {

    @Override
    @EntityGraph(attributePaths = {"categoria"})
    List<Material> findAll();

    @Override
    @EntityGraph(attributePaths = {"categoria"})
    Optional<Material> findById(Long id);

    @EntityGraph(attributePaths = {"categoria"})
    List<Material> findByNomeContainingIgnoreCase(String nome);

    @EntityGraph(attributePaths = {"categoria"})
    List<Material> findByCategoriaId(Long categoriaId);
}

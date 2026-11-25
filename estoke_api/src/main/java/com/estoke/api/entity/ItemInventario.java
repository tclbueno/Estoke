
package com.estoke.api.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "itens_inventario")
public class ItemInventario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inventario_id", nullable = false)
    private Inventario inventario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "material_id", nullable = false)
    private Material material;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "variacao_id")
    private VariacaoMaterial variacao;

    @Column(name = "quantidade_sistema", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantidadeSistema;

    @Column(name = "quantidade_contada", nullable = false, precision = 10, scale = 2)
    private BigDecimal quantidadeContada;

    @Column(name = "diferenca", nullable = false, precision = 10, scale = 2)
    private BigDecimal diferenca;

    public ItemInventario() {
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Inventario getInventario() {
        return inventario;
    }

    public void setInventario(Inventario inventario) {
        this.inventario = inventario;
    }

    public Material getMaterial() {
        return material;
    }

    public void setMaterial(Material material) {
        this.material = material;
    }

    public VariacaoMaterial getVariacao() {
        return variacao;
    }

    public void setVariacao(VariacaoMaterial variacao) {
        this.variacao = variacao;
    }

    public BigDecimal getQuantidadeSistema() {
        return quantidadeSistema;
    }

    public void setQuantidadeSistema(BigDecimal quantidadeSistema) {
        this.quantidadeSistema = quantidadeSistema;
    }

    public BigDecimal getQuantidadeContada() {
        return quantidadeContada;
    }

    public void setQuantidadeContada(BigDecimal quantidadeContada) {
        this.quantidadeContada = quantidadeContada;
    }

    public BigDecimal getDiferenca() {
        return diferenca;
    }

    public void setDiferenca(BigDecimal diferenca) {
        this.diferenca = diferenca;
    }
}

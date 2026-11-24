-- Fast Splash
-- Migration 001: Exclusao logica dos cadastros

USE fast_splash;

-- CLIENTES
ALTER TABLE cliente
    ADD COLUMN excluido_em DATETIME DEFAULT NULL,
    ADD INDEX idx_cliente_status (ativo, excluido_em),
    ADD CONSTRAINT chk_cliente_exclusao
        CHECK (excluido_em IS NULL OR ativo = FALSE);

-- VEICULOS
ALTER TABLE veiculo
    ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN excluido_em DATETIME DEFAULT NULL,
    ADD INDEX idx_veiculo_status (ativo, excluido_em),
    ADD CONSTRAINT chk_veiculo_exclusao
        CHECK (excluido_em IS NULL OR ativo = FALSE);

-- SERVICOS
ALTER TABLE servico
    ADD COLUMN excluido_em DATETIME DEFAULT NULL,
    ADD INDEX idx_servico_status (ativo, excluido_em),
    ADD CONSTRAINT chk_servico_exclusao
        CHECK (excluido_em IS NULL OR ativo = FALSE);

-- COLABORADORES
ALTER TABLE colaborador
    ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT TRUE,
    ADD COLUMN excluido_em DATETIME DEFAULT NULL,
    ADD INDEX idx_colaborador_status (ativo, excluido_em),
    ADD CONSTRAINT chk_colaborador_exclusao
        CHECK (excluido_em IS NULL OR ativo = FALSE);

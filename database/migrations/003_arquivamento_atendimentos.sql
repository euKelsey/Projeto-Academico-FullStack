USE fast_splash;

ALTER TABLE atendimento
    ADD COLUMN arquivado_em DATETIME NULL DEFAULT NULL,
    ADD INDEX idx_atendimento_arquivamento
        (arquivado_em, status),
    ADD CONSTRAINT chk_atendimento_arquivamento
        CHECK (
            arquivado_em IS NULL
            OR status = 'FINALIZADO'
        );

USE fast_splash;

ALTER TABLE agendamento
    ADD COLUMN arquivado_em DATETIME NULL DEFAULT NULL,
    ADD INDEX idx_agendamento_arquivamento
        (arquivado_em, status),
    ADD CONSTRAINT chk_agendamento_arquivamento
        CHECK (
            arquivado_em IS NULL
            OR status IN ('CANCELADO', 'CONCLUIDO')
        );

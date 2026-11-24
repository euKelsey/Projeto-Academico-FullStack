USE fast_splash;

ALTER TABLE pagamento
    ADD COLUMN arquivado_em DATETIME NULL DEFAULT NULL,
    ADD INDEX idx_pagamento_arquivamento
        (arquivado_em, status_pagamento),
    ADD CONSTRAINT chk_pagamento_arquivamento
        CHECK (
            arquivado_em IS NULL
            OR status_pagamento IN ('PAGO', 'CANCELADO')
        );

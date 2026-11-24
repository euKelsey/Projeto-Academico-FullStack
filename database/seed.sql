-- Fast Splash | dados ficticios apenas para desenvolvimento local.
-- Executar uma unica vez, apos schema.sql, em tabelas vazias.
-- Senha de teste de todas as contas com acesso: FastSplash@2026
USE fast_splash;
START TRANSACTION;

INSERT INTO cliente (id_cliente,nome,cpf,telefone,email,senha_hash,ativo) VALUES
(1,'Lucas Almeida','52998224725','11999990001','lucas@fastsplash.test','pbkdf2$120000$jzKSZxoleBUT7dblAGteXg==$dONmUDtpjGpvyUtWU76GhzbikvQkAExTZKxOSTdjdUY=',1),
(2,'Mariana Costa','11144477735','11999990002','mariana@fastsplash.test','pbkdf2$120000$HQg6/Bc7v5Xje+6Oi15P8g==$/gNDl3b80SrMgUB0Hj/wjYrJm05loxzrXb2cWKutdQo=',1),
(3,'Rafael Lima','12345678909','11999990003','rafael@fastsplash.test','pbkdf2$120000$TTtww0wJFZ4V7UePob7nog==$NBYpBzJ6uroQVuU8nGHcbcrt1jmqDl1MH4X60Ruzy/0=',1),
(4,'Camila Rocha','93541134780','11999990004','camila@fastsplash.test','pbkdf2$120000$hZQaUVEL4//Pl20OTBingQ==$BX+V/ECSr6aGsmMr617FFiOvjzKN/dmfYj/rzr/UPRU=',0);

INSERT INTO veiculo (id_veiculo,id_cliente,placa,marca,modelo,cor) VALUES
(1,1,'FST1A01','Volkswagen','Polo','Prata'),
(2,1,'FST1A02','Toyota','Corolla','Preto'),
(3,2,'FST1A03','Honda','Civic','Branco'),
(4,3,'FST1A04','Chevrolet','Onix','Azul');

INSERT INTO servico (id_servico,nome,descricao,preco,ativo) VALUES
(1,'Lavagem Simples','Lavagem externa',35.00,TRUE),
(2,'Lavagem Completa','Lavagem externa e limpeza interna',60.00,TRUE),
(3,'Enceramento','Protecao e brilho da pintura',40.00,TRUE),
(4,'Higienizacao Interna','Limpeza detalhada do interior',120.00,TRUE),
(5,'Servico promocional','Exemplo de servico inativo',25.00,FALSE);

INSERT INTO colaborador (id_colaborador,nome,cargo,nivel_acesso,email,senha_hash) VALUES
(1,'Ana Souza','Gerente','ADMINISTRADOR','admin@fastsplash.test','pbkdf2$120000$3yLQh4+vJ+uqoNH+iuyOiQ==$eIIS4NRKETApIaCV+npptKyzAAl4vszTJtIHAb2XpFo='),
(2,'Bruno Lima','Atendente','ATENDENTE','atendente@fastsplash.test','pbkdf2$120000$VtBOq0Ajq/XBaP2HsauxQw==$ctu9cKG4AxBan5Ek9me9vkU+j2tXWJQZqfY6fIRAc4U='),
(3,'Diego Martins','Lavador','OPERACIONAL',NULL,NULL),
(4,'Fernanda Alves','Lavadora','OPERACIONAL',NULL,NULL);

INSERT INTO agendamento (id_agendamento,id_veiculo,data,horario,status) VALUES
(1,1,CURDATE()+INTERVAL 1 DAY,'09:00:00','AGENDADO'),
(2,2,CURDATE(),'10:30:00','AGENDADO'),
(3,3,CURDATE()-INTERVAL 1 DAY,'14:00:00','CONCLUIDO'),
(4,4,CURDATE()-INTERVAL 2 DAY,'08:30:00','CANCELADO');

INSERT INTO agendamento_servico (id_agendamento,id_servico,valor_praticado) VALUES
(1,1,35.00),(1,3,40.00),(2,2,60.00),(3,2,60.00),(3,4,120.00),(4,1,35.00);

INSERT INTO atendimento (id_atendimento,id_agendamento,status,data_inicio,data_fim) VALUES
(1,2,'EM_LAVAGEM',TIMESTAMP(CURDATE(),'10:35:00'),NULL),
(2,3,'FINALIZADO',TIMESTAMP(CURDATE()-INTERVAL 1 DAY,'14:05:00'),TIMESTAMP(CURDATE()-INTERVAL 1 DAY,'15:40:00'));

INSERT INTO colaborador_atendimento (id_colaborador,id_atendimento) VALUES (3,1),(3,2),(4,2);

INSERT INTO pagamento (id_pagamento,id_agendamento,data_pagamento,valor,forma_pagamento,status_pagamento) VALUES
(1,1,NULL,75.00,NULL,'PENDENTE'),
(2,2,TIMESTAMP(CURDATE(),'10:25:00'),60.00,'PIX','PAGO'),
(3,3,TIMESTAMP(CURDATE()-INTERVAL 1 DAY,'14:00:00'),180.00,'CREDITO','PAGO'),
(4,4,NULL,35.00,NULL,'CANCELADO');

COMMIT;
SELECT id_colaborador,nome,nivel_acesso,email FROM colaborador;

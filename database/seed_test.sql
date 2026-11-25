-- Fast Splash - Seed exclusivo de testes automatizados
-- Nao utilizar em desenvolvimento normal ou producao.
-- Senha ficticia das contas de teste: SenhaFicticia@123

USE fast_splash_test;

SET NAMES utf8mb4;

START TRANSACTION;

SET @senha_teste = 'pbkdf2$120000$RmFzdFNwbGFzaFRlc3QwMQ==$IzmXjIeK3ZfuwJlGntKOSSffoAm9LjquJbuI+Z5f0IA=';

-- ==========================================
-- CLIENTES
-- ==========================================

INSERT INTO cliente
(id_cliente, nome, cpf, telefone, email, senha_hash, ativo, excluido_em)
VALUES
(101, 'Cliente Teste Ativo', '98765410130', '11900000101',
 'ativo@example.test', @senha_teste, 1, NULL),

(102, 'Cliente Teste Livre', '98765410211', '11900000102',
 'livre@example.test', @senha_teste, 1, NULL),

(103, 'Cliente Teste Inativo', '98765410300', '11900000103',
 'inativo@example.test', @senha_teste, 0, NULL),

(104, 'Cliente Teste Excluido', '98765410483', '11900000104',
 'excluido@example.test', @senha_teste, 0,
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- ==========================================
-- VEICULOS
-- ==========================================

INSERT INTO veiculo
(id_veiculo, id_cliente, placa, marca, modelo, cor, ativo, excluido_em)
VALUES
(201, 101, 'TST1A01', 'Volkswagen', 'Polo', 'Branco', 1, NULL),
(202, 101, 'TST1A02', 'Honda', 'Civic', 'Preto', 1, NULL),
(203, 102, 'TST1A03', 'Fiat', 'Argo', 'Prata', 1, NULL),
(204, 103, 'TST1A04', 'Toyota', 'Corolla', 'Cinza', 0, NULL),
(205, 104, 'TST1A05', 'Chevrolet', 'Onix', 'Azul', 0,
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- ==========================================
-- SERVICOS
-- ==========================================

INSERT INTO servico
(id_servico, nome, descricao, preco, ativo, excluido_em)
VALUES
(301, 'Lavagem Simples Teste', 'Lavagem externa', 50.00, 1, NULL),
(302, 'Lavagem Completa Teste', 'Lavagem interna e externa', 80.00, 1, NULL),
(303, 'Enceramento Teste', 'Aplicacao de cera', 40.00, 0, NULL),
(304, 'Servico Excluido Teste', 'Servico historico', 100.00, 0,
 DATE_SUB(NOW(), INTERVAL 10 DAY));

-- ==========================================
-- COLABORADORES
-- ==========================================

INSERT INTO colaborador
(id_colaborador, nome, cargo, nivel_acesso, email, senha_hash, ativo, excluido_em)
VALUES
(401, 'Administrador Teste', 'Administrador', 'ADMINISTRADOR',
 'admin@example.test', @senha_teste, 1, NULL),

(402, 'Atendente Teste', 'Atendente', 'ATENDENTE',
 'atendente@example.test', @senha_teste, 1, NULL),

(403, 'Operacional Teste A', 'Lavador', 'OPERACIONAL',
 NULL, NULL, 1, NULL),

(404, 'Operacional Teste B', 'Lavador', 'OPERACIONAL',
 NULL, NULL, 1, NULL),

(405, 'Colaborador Inativo Teste', 'Lavador', 'OPERACIONAL',
 NULL, NULL, 0, NULL);

-- ==========================================
-- AGENDAMENTOS
-- ==========================================

INSERT INTO agendamento
(id_agendamento, id_veiculo, data, horario, status, arquivado_em)
VALUES
(501, 201, DATE_ADD(CURDATE(), INTERVAL 1 DAY),
 '09:00:00', 'AGENDADO', NULL),

(502, 202, DATE_ADD(CURDATE(), INTERVAL 1 DAY),
 '10:00:00', 'AGENDADO', NULL),

(503, 201, CURDATE(),
 '08:00:00', 'AGENDADO', NULL),

(504, 202, DATE_SUB(CURDATE(), INTERVAL 2 DAY),
 '09:00:00', 'CONCLUIDO', NULL),

(505, 202, DATE_SUB(CURDATE(), INTERVAL 3 DAY),
 '10:00:00', 'CANCELADO', NULL),

(506, 205, DATE_SUB(CURDATE(), INTERVAL 20 DAY),
 '11:00:00', 'CONCLUIDO',
 DATE_SUB(NOW(), INTERVAL 15 DAY));

-- ==========================================
-- SERVICOS DOS AGENDAMENTOS
-- ==========================================

INSERT INTO agendamento_servico
(id_agendamento, id_servico, valor_praticado)
VALUES
(501, 301, 50.00),
(502, 302, 80.00),
(503, 302, 80.00),
(504, 301, 50.00),
(504, 303, 40.00),
(505, 301, 50.00),
(506, 304, 100.00);

-- ==========================================
-- PAGAMENTOS
-- ==========================================

INSERT INTO pagamento
(id_pagamento, id_agendamento, data_pagamento, valor,
 forma_pagamento, status_pagamento, arquivado_em)
VALUES
(701, 501, NULL, 50.00,
 NULL, 'PENDENTE', NULL),

(702, 502, NOW(), 80.00,
 'PIX', 'PAGO', NULL),

(703, 503, TIMESTAMP(CURDATE(), '07:55:00'), 80.00,
 'CREDITO', 'PAGO', NULL),

(704, 504, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '08:55:00'),
 90.00, 'DEBITO', 'PAGO', NULL),

(705, 505, NULL, 50.00,
 NULL, 'CANCELADO', NULL),

(706, 506, TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 20 DAY), '10:55:00'),
 100.00, 'DINHEIRO', 'PAGO',
 DATE_SUB(NOW(), INTERVAL 15 DAY));

-- ==========================================
-- ATENDIMENTOS
-- ==========================================

INSERT INTO atendimento
(id_atendimento, id_agendamento, status, data_inicio, data_fim, arquivado_em)
VALUES
(601, 501, 'AGUARDANDO', NULL, NULL, NULL),

(602, 502, 'AGUARDANDO', NULL, NULL, NULL),

(603, 503, 'EM_LAVAGEM',
 TIMESTAMP(CURDATE(), '08:00:00'),
 NULL, NULL),

(604, 504, 'FINALIZADO',
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '09:00:00'),
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY), '09:45:00'),
 NULL),

(605, 506, 'FINALIZADO',
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 20 DAY), '11:00:00'),
 TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 20 DAY), '12:00:00'),
 DATE_SUB(NOW(), INTERVAL 15 DAY));

-- ==========================================
-- VINCULOS DOS COLABORADORES
-- ==========================================

INSERT INTO colaborador_atendimento
(id_colaborador, id_atendimento)
VALUES
(403, 603),
(403, 604),
(404, 604),
(404, 605);

COMMIT;

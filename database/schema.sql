
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `fast_splash` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `fast_splash`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agendamento` (
  `id_agendamento` int NOT NULL AUTO_INCREMENT,
  `id_veiculo` int NOT NULL,
  `data` date NOT NULL,
  `horario` time NOT NULL,
  `status` enum('AGENDADO','CANCELADO','CONCLUIDO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AGENDADO',
  `arquivado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_agendamento`),
  UNIQUE KEY `uq_agendamento_veiculo_data_horario` (`id_veiculo`,`data`,`horario`),
  KEY `idx_agendamento_data_horario` (`data`,`horario`),
  KEY `idx_agendamento_status` (`status`),
  KEY `idx_agendamento_arquivamento` (`arquivado_em`,`status`),
  CONSTRAINT `fk_agendamento_veiculo` FOREIGN KEY (`id_veiculo`) REFERENCES `veiculo` (`id_veiculo`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_agendamento_arquivamento` CHECK (((`arquivado_em` is null) or (`status` in (_cp850'CANCELADO',_cp850'CONCLUIDO'))))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `agendamento_servico` (
  `id_agendamento` int NOT NULL,
  `id_servico` int NOT NULL,
  `valor_praticado` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_agendamento`,`id_servico`),
  KEY `fk_agendamento_servico_servico` (`id_servico`),
  CONSTRAINT `fk_agendamento_servico_agendamento` FOREIGN KEY (`id_agendamento`) REFERENCES `agendamento` (`id_agendamento`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_agendamento_servico_servico` FOREIGN KEY (`id_servico`) REFERENCES `servico` (`id_servico`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_agendamento_servico_valor` CHECK ((`valor_praticado` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atendimento` (
  `id_atendimento` int NOT NULL AUTO_INCREMENT,
  `id_agendamento` int NOT NULL,
  `status` enum('AGUARDANDO','EM_LAVAGEM','FINALIZADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AGUARDANDO',
  `data_inicio` datetime DEFAULT NULL,
  `data_fim` datetime DEFAULT NULL,
  `arquivado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_atendimento`),
  UNIQUE KEY `id_agendamento` (`id_agendamento`),
  KEY `idx_atendimento_status` (`status`),
  KEY `idx_atendimento_arquivamento` (`arquivado_em`,`status`),
  CONSTRAINT `fk_atendimento_agendamento` FOREIGN KEY (`id_agendamento`) REFERENCES `agendamento` (`id_agendamento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_atendimento_arquivamento` CHECK (((`arquivado_em` is null) or (`status` = _cp850'FINALIZADO'))),
  CONSTRAINT `chk_atendimento_datas` CHECK (((`data_fim` is null) or (`data_inicio` is null) or (`data_fim` >= `data_inicio`)))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cpf` char(11) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `senha_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `excluido_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `cpf` (`cpf`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_cliente_status` (`ativo`,`excluido_em`),
  CONSTRAINT `chk_cliente_exclusao` CHECK (((`excluido_em` is null) or (`ativo` = false)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `colaborador` (
  `id_colaborador` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cargo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nivel_acesso` enum('ADMINISTRADOR','ATENDENTE','OPERACIONAL') COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `senha_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `excluido_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_colaborador`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_colaborador_status` (`ativo`,`excluido_em`),
  CONSTRAINT `chk_colaborador_exclusao` CHECK (((`excluido_em` is null) or (`ativo` = false)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `colaborador_atendimento` (
  `id_colaborador` int NOT NULL,
  `id_atendimento` int NOT NULL,
  PRIMARY KEY (`id_colaborador`,`id_atendimento`),
  KEY `fk_colaborador_atendimento_atendimento` (`id_atendimento`),
  CONSTRAINT `fk_colaborador_atendimento_atendimento` FOREIGN KEY (`id_atendimento`) REFERENCES `atendimento` (`id_atendimento`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_colaborador_atendimento_colaborador` FOREIGN KEY (`id_colaborador`) REFERENCES `colaborador` (`id_colaborador`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pagamento` (
  `id_pagamento` int NOT NULL AUTO_INCREMENT,
  `id_agendamento` int NOT NULL,
  `data_pagamento` datetime DEFAULT NULL,
  `valor` decimal(10,2) NOT NULL,
  `forma_pagamento` enum('DINHEIRO','PIX','CREDITO','DEBITO') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status_pagamento` enum('PENDENTE','PAGO','CANCELADO') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDENTE',
  `arquivado_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_pagamento`),
  UNIQUE KEY `id_agendamento` (`id_agendamento`),
  KEY `idx_pagamento_arquivamento` (`arquivado_em`,`status_pagamento`),
  CONSTRAINT `fk_pagamento_agendamento` FOREIGN KEY (`id_agendamento`) REFERENCES `agendamento` (`id_agendamento`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_pagamento_arquivamento` CHECK (((`arquivado_em` is null) or (`status_pagamento` in (_cp850'PAGO',_cp850'CANCELADO')))),
  CONSTRAINT `chk_pagamento_pago` CHECK (((`status_pagamento` <> _utf8mb4'PAGO') or ((`data_pagamento` is not null) and (`forma_pagamento` is not null)))),
  CONSTRAINT `chk_pagamento_valor` CHECK ((`valor` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `servico` (
  `id_servico` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descricao` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preco` decimal(10,2) NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `excluido_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_servico`),
  KEY `idx_servico_status` (`ativo`,`excluido_em`),
  CONSTRAINT `chk_servico_exclusao` CHECK (((`excluido_em` is null) or (`ativo` = false))),
  CONSTRAINT `chk_servico_preco` CHECK ((`preco` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `veiculo` (
  `id_veiculo` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `placa` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `marca` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `modelo` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cor` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT '1',
  `excluido_em` datetime DEFAULT NULL,
  PRIMARY KEY (`id_veiculo`),
  UNIQUE KEY `placa` (`placa`),
  KEY `fk_veiculo_cliente` (`id_cliente`),
  KEY `idx_veiculo_status` (`ativo`,`excluido_em`),
  CONSTRAINT `fk_veiculo_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_veiculo_exclusao` CHECK (((`excluido_em` is null) or (`ativo` = false)))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

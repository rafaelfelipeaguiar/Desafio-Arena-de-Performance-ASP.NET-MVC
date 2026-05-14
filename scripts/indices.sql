-- ============================================================
-- SCRIPT DE OTIMIZAÇÃO: ÍNDICES PARA MARIADB
-- Schema: ecommerce_db | Tabelas: clientes, pedidos
-- ============================================================

USE ecommerce_db;

-- 1. Índice Full-Text para busca SARGable por parte do nome
-- Permite MATCH(c.nome) AGAINST(@termo IN BOOLEAN MODE)
ALTER TABLE clientes
    ADD FULLTEXT INDEX idx_nome_fulltext (nome);

-- 2. Índice Covering na tabela pedidos
-- Cobre: JOIN (cliente_id), Filtro (data_pedido), Agregação (valor_total, id para COUNT)
CREATE INDEX idx_pedidos_covering_jiparana
    ON pedidos(cliente_id, data_pedido, id, valor_total);

-- 3. Índice Covering na tabela clientes
-- Cobre: filtro cidade + projeção nome/id
CREATE INDEX idx_clientes_covering_jiparana
    ON clientes(cidade, nome, id);

-- ============================================================
-- QUERY FINAL (OURO - Full-Text + Covering Index)
-- ============================================================
/*
SELECT 
    c.nome AS NomeCliente,
    c.cidade,
    SUM(p.valor_total) AS ValorTotalAcumulado
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id
WHERE c.cidade = 'Ji-Paraná'
    AND p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    AND MATCH(c.nome) AGAINST('termo*' IN BOOLEAN MODE)
GROUP BY c.id, c.nome, c.cidade
HAVING COUNT(DISTINCT p.id) > 5
ORDER BY ValorTotalAcumulado DESC;
*/

-- ============================================================
-- VERIFICAR PLANOS DE EXECUÇÃO (EXPLAIN)
-- ============================================================
/*
EXPLAIN
SELECT 
    c.nome AS NomeCliente,
    c.cidade,
    SUM(p.valor_total) AS ValorTotalAcumulado
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id
WHERE c.cidade = 'Ji-Paraná'
    AND p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY c.id, c.nome, c.cidade
HAVING COUNT(DISTINCT p.id) > 5
ORDER BY ValorTotalAcumulado DESC;
*/

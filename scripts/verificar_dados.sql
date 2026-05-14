-- ============================================================
-- VERIFICAÇÃO RÁPIDA: DADOS PARA O RELATÓRIO (MARIADB)
-- ============================================================

SELECT 'TOTAL DE REGISTROS' AS info;
SELECT 
    (SELECT COUNT(*) FROM clientes) AS total_clientes,
    (SELECT COUNT(*) FROM pedidos) AS total_pedidos;

SELECT 'CIDADES DISPONIVEIS' AS info;
SELECT DISTINCT cidade, COUNT(*) as total
FROM clientes
GROUP BY cidade
ORDER BY total DESC;

SELECT 'CLIENTES DE JI-PARANA COM MAIS DE 5 PEDIDOS (ULTIMOS 90 DIAS)' AS info;
SELECT 
    c.nome,
    c.cidade,
    COUNT(DISTINCT p.id) AS total_pedidos,
    SUM(p.valor_total) AS valor_total_acumulado
FROM clientes c
INNER JOIN pedidos p ON p.cliente_id = c.id
WHERE c.cidade = 'Ji-Paraná'
    AND p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
GROUP BY c.id, c.nome, c.cidade
HAVING COUNT(DISTINCT p.id) > 5
ORDER BY valor_total_acumulado DESC;

SELECT 'AMOSTRA DE PEDIDOS RECENTES' AS info;
SELECT 
    p.id, 
    p.cliente_id, 
    p.data_pedido, 
    p.valor_total,
    c.nome AS cliente_nome
FROM pedidos p
INNER JOIN clientes c ON c.id = p.cliente_id
WHERE p.data_pedido >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
ORDER BY p.data_pedido DESC
LIMIT 10;

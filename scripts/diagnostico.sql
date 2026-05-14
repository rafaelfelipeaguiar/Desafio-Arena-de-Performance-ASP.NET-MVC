-- ============================================================
-- DIAGNÓSTICO RÁPIDO DO BANCO
-- Rode isso no console do Rider (ou SSMS) para ver o estado
-- ============================================================

PRINT '=== 1. VERIFICANDO TABELAS EXISTENTES ===';
SELECT 
    t.name AS NomeTabela,
    SCHEMA_NAME(t.schema_id) AS SchemaName
FROM sys.tables t
WHERE t.name IN ('Clientes', 'Pedidos')
ORDER BY t.name;

PRINT '=== 2. ESTRUTURA DAS TABELAS ===';
SELECT 
    t.name AS Tabela,
    c.name AS Coluna,
    ty.name AS Tipo,
    c.max_length AS TamanhoMax,
    c.is_nullable AS PodeSerNulo
FROM sys.columns c
INNER JOIN sys.tables t ON c.object_id = t.object_id
INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
WHERE t.name IN ('Clientes', 'Pedidos')
ORDER BY t.name, c.column_id;

PRINT '=== 3. CONTAGEM DE REGISTROS ===';
SELECT 
    (SELECT COUNT(*) FROM Clientes) AS TotalClientes,
    (SELECT COUNT(*) FROM Pedidos) AS TotalPedidos;

PRINT '=== 4. VERIFICANDO CLIENTES DE JI-PARANA COM PEDIDOS RECENTES ===';
SELECT 
    c.Nome,
    c.Cidade,
    COUNT(p.Id) AS TotalPedidos,
    SUM(p.ValorTotal) AS ValorTotal
FROM Clientes c
LEFT JOIN Pedidos p ON p.ClienteId = c.Id 
    AND p.DataPedido >= DATEADD(DAY, -90, GETDATE())
WHERE c.Cidade = 'Ji-Paraná'
GROUP BY c.Id, c.Nome, c.Cidade
HAVING COUNT(p.Id) > 5
ORDER BY ValorTotal DESC;

PRINT '=== 5. VERIFICANDO ÍNDICES EXISTENTES ===';
SELECT 
    t.name AS Tabela,
    i.name AS NomeIndice,
    i.type_desc AS TipoIndice
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('Clientes', 'Pedidos')
    AND i.name IS NOT NULL
ORDER BY t.name, i.name;

PRINT '=== 6. VERIFICANDO FULL-TEXT SEARCH ===';
SELECT 
    name AS Catalogo,
    is_default AS Padrao
FROM sys.fulltext_catalogs;

SELECT 
    t.name AS Tabela,
    c.name AS ColunaFullText
FROM sys.fulltext_indexes fi
INNER JOIN sys.tables t ON fi.object_id = t.object_id
INNER JOIN sys.fulltext_index_columns fic ON fi.object_id = fic.object_id
INNER JOIN sys.columns c ON fic.column_id = c.column_id AND fic.object_id = c.object_id
WHERE t.name = 'Clientes';

PRINT '=== DIAGNÓSTICO FINALIZADO ===';

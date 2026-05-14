-- ============================================================
-- SCRIPT COMPLETO: CRIAÇÃO DE TABELAS + DADOS DE TESTE
-- Rode isso se o diagnóstico mostrar que as tabelas NÃO existem
-- ============================================================

-- Cria tabela Clientes
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Clientes')
BEGIN
    CREATE TABLE Clientes (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        Nome NVARCHAR(200) NOT NULL,
        Cidade NVARCHAR(100) NOT NULL,
        Email NVARCHAR(200) NULL,
        DataCadastro DATETIME2 DEFAULT GETDATE()
    );
    PRINT 'Tabela Clientes criada.';
END
ELSE
BEGIN
    PRINT 'Tabela Clientes já existe.';
END
GO

-- Cria tabela Pedidos
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Pedidos')
BEGIN
    CREATE TABLE Pedidos (
        Id INT IDENTITY(1,1) PRIMARY KEY,
        ClienteId INT NOT NULL,
        DataPedido DATETIME2 NOT NULL,
        ValorTotal DECIMAL(18,2) NOT NULL,
        Status NVARCHAR(50) DEFAULT 'Finalizado'
    );
    
    ALTER TABLE Pedidos 
        ADD CONSTRAINT FK_Pedidos_Clientes 
        FOREIGN KEY (ClienteId) REFERENCES Clientes(Id);
    
    PRINT 'Tabela Pedidos criada.';
END
ELSE
BEGIN
    PRINT 'Tabela Pedidos já existe.';
END
GO

-- ============================================================
-- INSERÇÃO DE DADOS DE TESTE
-- ============================================================

-- Limpa dados antigos de teste (cuidado em produção!)
-- DELETE FROM Pedidos;
-- DELETE FROM Clientes;

-- Clientes de Ji-Paraná (com pedidos)
INSERT INTO Clientes (Nome, Cidade, Email) VALUES
('João Silva', 'Ji-Paraná', 'joao@teste.com'),
('Maria Oliveira', 'Ji-Paraná', 'maria@teste.com'),
('Carlos Pereira', 'Ji-Paraná', 'carlos@teste.com'),
('Ana Souza', 'Ji-Paraná', 'ana@teste.com'),
('Pedro Santos', 'Ji-Paraná', 'pedro@teste.com'),
('Juliana Costa', 'Ji-Paraná', 'juliana@teste.com'),
('Roberto Lima', 'Ji-Paraná', 'roberto@teste.com'),
('Fernanda Dias', 'Ji-Paraná', 'fernanda@teste.com'),
('Marcos Rocha', 'Ji-Paraná', 'marcos@teste.com'),
('Patrícia Almeida', 'Ji-Paraná', 'patricia@teste.com');

-- Clientes de outras cidades (para testar filtro)
INSERT INTO Clientes (Nome, Cidade, Email) VALUES
('Lucas Porto', 'Porto Velho', 'lucas@teste.com'),
('Bruna Cuiabá', 'Cuiabá', 'bruna@teste.com'),
('Tiago Manaus', 'Manaus', 'tiago@teste.com');

DECLARE @i INT = 1;
DECLARE @ClienteId INT;
DECLARE @DataBase DATETIME2 = GETDATE();

-- Cursor simples para inserir pedidos
WHILE @i <= 10
BEGIN
    SELECT @ClienteId = Id FROM Clientes WHERE Nome = 
        CASE @i
            WHEN 1 THEN 'João Silva'
            WHEN 2 THEN 'Maria Oliveira'
            WHEN 3 THEN 'Carlos Pereira'
            WHEN 4 THEN 'Ana Souza'
            WHEN 5 THEN 'Pedro Santos'
            WHEN 6 THEN 'Juliana Costa'
            WHEN 7 THEN 'Roberto Lima'
            WHEN 8 THEN 'Fernanda Dias'
            WHEN 9 THEN 'Marcos Rocha'
            WHEN 10 THEN 'Patrícia Almeida'
        END;

    -- Insere de 3 a 8 pedidos por cliente nos últimos 90 dias
    DECLARE @j INT = 1;
    DECLARE @NumPedidos INT = ABS(CHECKSUM(NEWID())) % 6 + 3; -- 3 a 8 pedidos
    
    WHILE @j <= @NumPedidos
    BEGIN
        INSERT INTO Pedidos (ClienteId, DataPedido, ValorTotal)
        VALUES (
            @ClienteId,
            DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 90, @DataBase),
            CAST(ABS(CHECKSUM(NEWID())) % 1000 + 50 AS DECIMAL(18,2))
        );
        SET @j = @j + 1;
    END

    SET @i = @i + 1;
END

PRINT 'Dados de teste inseridos com sucesso!';
GO

-- ============================================================
-- ÍNDICES DE PERFORMANCE (APÓS INSERÇÃO DOS DADOS)
-- ============================================================

-- Índice para filtro de cidade e nome
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Clientes_Cidade_Nome')
    CREATE NONCLUSTERED INDEX IX_Clientes_Cidade_Nome ON Clientes(Cidade, Nome);
GO

-- Índice para JOIN e filtro de data
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pedidos_ClienteId_DataPedido')
    CREATE NONCLUSTERED INDEX IX_Pedidos_ClienteId_DataPedido ON Pedidos(ClienteId, DataPedido) INCLUDE (ValorTotal);
GO

PRINT 'Script finalizado. Tabelas, dados e índices criados!';
GO

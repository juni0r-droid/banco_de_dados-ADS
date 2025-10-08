CREATE DATABASE CLINICA_MEDICA

-- =============================
-- EXERCÍCIO 1 - PACIENTES
-- =============================
CREATE TABLE Pacientes (
    IdPaciente INT IDENTITY(1,1) PRIMARY KEY,
    NomeCompleto NVARCHAR(100) NOT NULL,
    CPF CHAR(11) UNIQUE NOT NULL,
    DataNascimento DATE NOT NULL,
    Ativo BIT DEFAULT 1
);
GO

CREATE PROCEDURE sp_InserirPaciente
    @NomeCompleto NVARCHAR(100),
    @CPF CHAR(11),
    @DataNascimento DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Pacientes WHERE CPF = @CPF)
    BEGIN
        PRINT 'CPF já cadastrado!';
        RETURN;
    END;

    INSERT INTO Pacientes (NomeCompleto, CPF, DataNascimento)
    VALUES (@NomeCompleto, @CPF, @DataNascimento);

    DECLARE @NovoId INT = SCOPE_IDENTITY();
    PRINT 'Paciente inserido com sucesso. ID: ' + CAST(@NovoId AS NVARCHAR(10));
END;
GO


-- =============================
-- EXERCÍCIO 2 - MÉDICOS
-- =============================
CREATE TABLE Medicos (
    IdMedico INT IDENTITY(1,1) PRIMARY KEY,
    NomeCompleto NVARCHAR(100) NOT NULL,
    CRM NVARCHAR(20) UNIQUE NOT NULL,
    Especialidade NVARCHAR(50) NOT NULL
);
GO

CREATE PROCEDURE sp_InserirMedico
    @NomeCompleto NVARCHAR(100),
    @CRM NVARCHAR(20),
    @Especialidade NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Medicos WHERE CRM = @CRM)
    BEGIN
        PRINT 'CRM já cadastrado!';
        RETURN;
    END;

    INSERT INTO Medicos (NomeCompleto, CRM, Especialidade)
    VALUES (@NomeCompleto, @CRM, @Especialidade);

    PRINT 'Médico inserido com sucesso.';
END;
GO


-- =============================
-- EXERCÍCIO 3 - CONSULTAS
-- =============================
CREATE TABLE Consultas (
    IdConsulta INT IDENTITY(1,1) PRIMARY KEY,
    IdPaciente INT NOT NULL FOREIGN KEY REFERENCES Pacientes(IdPaciente),
    IdMedico INT NOT NULL FOREIGN KEY REFERENCES Medicos(IdMedico),
    DataHoraInicio DATETIME NOT NULL,
    DataHoraFim DATETIME NOT NULL,
    Status NVARCHAR(20) DEFAULT 'Agendada'
);
GO

CREATE PROCEDURE sp_AgendarConsulta
    @IdPaciente INT,
    @IdMedico INT,
    @DataHoraInicio DATETIME,
    @DataHoraFim DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM Consultas
        WHERE IdMedico = @IdMedico
        AND Status = 'Agendada'
        AND (
            (@DataHoraInicio BETWEEN DataHoraInicio AND DataHoraFim)
            OR (@DataHoraFim BETWEEN DataHoraInicio AND DataHoraFim)
            OR (DataHoraInicio BETWEEN @DataHoraInicio AND @DataHoraFim)
        )
    )
    BEGIN
        PRINT 'Horário indisponível para este médico.';
        RETURN;
    END;

    INSERT INTO Consultas (IdPaciente, IdMedico, DataHoraInicio, DataHoraFim)
    VALUES (@IdPaciente, @IdMedico, @DataHoraInicio, @DataHoraFim);

    PRINT 'Consulta agendada.';
END;
GO


-- =============================
-- EXERCÍCIO 4 - STATUS CONSULTA
-- =============================
CREATE PROCEDURE sp_AtualizarStatusConsulta
    @IdConsulta INT,
    @NovoStatus NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StatusAtual NVARCHAR(20);
    SELECT @StatusAtual = Status FROM Consultas WHERE IdConsulta = @IdConsulta;

    IF @StatusAtual IS NULL
    BEGIN
        PRINT 'Consulta não encontrada.';
        RETURN;
    END;

    IF @StatusAtual = 'Cancelada' AND @NovoStatus = 'Agendada'
    BEGIN
        PRINT 'Não é possível reverter consulta cancelada.';
        RETURN;
    END;

    UPDATE Consultas
    SET Status = @NovoStatus
    WHERE IdConsulta = @IdConsulta;

    PRINT 'Status atualizado.';
END;
GO


-- =============================
-- EXERCÍCIO 5 - ESTOQUE
-- =============================
CREATE TABLE EstoqueMedicamentos (
    IdMedicamento INT IDENTITY(1,1) PRIMARY KEY,
    Nome NVARCHAR(100) NOT NULL,
    Quantidade INT NOT NULL DEFAULT 0,
    QuantidadeMinima INT NOT NULL DEFAULT 10
);
GO

CREATE PROCEDURE sp_AtualizarEstoqueMedicamento
    @IdMedicamento INT,
    @QuantidadeAlterada INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @QtdAtual INT;
    SELECT @QtdAtual = Quantidade FROM EstoqueMedicamentos WHERE IdMedicamento = @IdMedicamento;

    IF @QtdAtual IS NULL
    BEGIN
        PRINT 'Medicamento não encontrado.';
        RETURN;
    END;

    IF @QtdAtual + @QuantidadeAlterada < 0
    BEGIN
        PRINT 'Estoque insuficiente.';
        RETURN;
    END;

    UPDATE EstoqueMedicamentos
    SET Quantidade = Quantidade + @QuantidadeAlterada
    WHERE IdMedicamento = @IdMedicamento;

    PRINT 'Estoque atualizado.';
END;
GO


-- =============================
-- TESTES
-- =============================

-- Pacientes
EXEC sp_InserirPaciente 'João da Silva', '12345678901', '2000-01-01';
EXEC sp_InserirPaciente 'Maria Oliveira', '98765432100', '1995-05-10';
EXEC sp_InserirPaciente 'Outro João', '12345678901', '1990-10-10'; -- duplicado

-- Médicos
EXEC sp_InserirMedico 'Dr. Carlos Mendes', 'CRM12345', 'Clínico Geral';
EXEC sp_InserirMedico 'Dra. Ana Paula', 'CRM67890', 'Dermatologia';
EXEC sp_InserirMedico 'Dr. Falso', 'CRM12345', 'Ortopedia'; -- duplicado

-- Consultas
EXEC sp_AgendarConsulta 1, 1, '2025-10-10 09:00', '2025-10-10 09:30';
EXEC sp_AgendarConsulta 2, 1, '2025-10-10 09:15', '2025-10-10 09:45'; -- conflito
EXEC sp_AgendarConsulta 2, 2, '2025-10-10 10:00', '2025-10-10 10:30'; -- ok

-- Status
EXEC sp_AtualizarStatusConsulta 1, 'Concluída';
EXEC sp_AtualizarStatusConsulta 1, 'Cancelada';
EXEC sp_AtualizarStatusConsulta 1, 'Agendada'; -- regra violada

-- Estoque
INSERT INTO EstoqueMedicamentos (Nome, Quantidade, QuantidadeMinima)
VALUES ('Paracetamol', 20, 5), ('Ibuprofeno', 10, 3);

EXEC sp_AtualizarEstoqueMedicamento 1, 5;   -- entrada
EXEC sp_AtualizarEstoqueMedicamento 1, -10; -- saída ok
EXEC sp_AtualizarEstoqueMedicamento 2, -20; -- erro

-- Visualizar dados
SELECT * FROM Pacientes;
SELECT * FROM Medicos;
SELECT * FROM Consultas;
SELECT * FROM EstoqueMedicamentos;
GO

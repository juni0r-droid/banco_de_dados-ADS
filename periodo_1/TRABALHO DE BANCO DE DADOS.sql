--ALUNOS:jo�o junior e f�bio manuel

--CRIANDO BANCO DE DAOS ACADEMIA

CREATE DATABASE ACADEMIA

--ESTRUTURA DE TABELAS

CREATE TABLE ALUNOS (

 NOME VARCHAR(40),
 DATA_DE_NASCIMENTO DATE,
 BAIRRO VARCHAR(40),
 STATUS_DE_PAGAMENTO VARCHAR(50),
 );
 --INSER��O DA TABELA ALUNOS
 INSERT INTO ALUNOS (NOME, DATA_DE_NASCIMENTO, BAIRRO, STATUS_DE_PAGAMENTO)
 VALUES   ('John Marston', '2008-12-23', 'centro', 'pago'),
          ('Jo�o Godofredo', '1300-09-12', 'centro', 'em d�vida'),
		  ('Fabio Bundoviski', '2005-08-13', 'centro', 'em d�vida'),
		  ('Henry de Skalitz', '1380-10-01', 'skalitz', 'pago'),
		  ('Maju Toucinho', '2010-12-21', 'santos', 'pago'),
		  ('Luiz Bolsonaro da Silva', '2001-06-15', 'planalto central', 'pago');

 
 CREATE TABLE CHECK_INS (

 NOME_DO_ALUNO VARCHAR(50),
 DATA_E_HORA_DE_ENTRADA DATETIME,
 VEZEZ_ENTRADA FLOAT,
 );
 INSERT INTO CHECK_INS (NOME_DO_ALUNO, DATA_E_HORA_DE_ENTRADA, VEZEZ_ENTRADA)
 VALUES ('John Marston', '2025-09-25T17:30:25', 6),
        ('Jo�o Godofredo', '2025-12-25T19:30:10', 10),
		('Fabio Bundoviski', '2025-08-13T13:00:13', 8),
		('Henry de Skalitz', '2025-08-12T15:09:12', 9),
		('Maju Toucinho', '2025-07-20T17:00:29', 20),
		('Luiz Bolsonaro da Silva', '2025-12-25T17:00:14', 4);

 CREATE TABLE COMPRAS(

 NOME_DO_ALUNO VARCHAR(50),
 PRODUTO VARCHAR(50),
 VALOR SMALLMONEY,
 DATA_DE_COMPRA DATETIME,
 );

INSERT INTO COMPRAS (NOME_DO_ALUNO, PRODUTO, VALOR, DATA_DE_COMPRA)
VALUES ('John Marston', 'bomba', 50.00, '2025-09-04T18:30:25'),
       ('Fabio Bundoviski', 'pastilhas valda', 15.00, '2025-12-25T19:30:10'),
	   ('Maju Toucinho', '�gua', 10.00, '2025-08-12T15:09:12'),
	   ('Luiz Bolsonaro da Silva', 'ivermectina', 22.00, '2025-12-25T19:30:10');

 --RELAT�RIOS A SEREM GERADOS

 --Alunos que mais entraram na academia no m�s:
  SELECT 
    NOME_DO_ALUNO, 
    COUNT(*) AS VEZEZ_ENTRADA
FROM CHECK_INS
WHERE FORMAT(DATA_E_HORA_DE_ENTRADA, '%Y-%m') = '2024-03'  -- Filtra o m�s e ano desejado
GROUP BY NOME_DO_ALUNO
ORDER BY VEZEZ_ENTRADA DESC;  -- Ordena pelos que mais entraram




 --DROP DE TABELAS

 drop table ALUNOS
 drop table CHECK_INS

 --TESTE DE SELE��O

 SELECT * FROM ALUNOS
 SELECT * FROM CHECK_INS
 SELECT * FROM COMPRAS
-- o usuário deve conter informações como: nome, e-mail, telefone e endereço
CREATE TABLE usuario 
(
	CPF VARCHAR(15) PRIMARY KEY NOT NULL,
	telefone VARCHAR(30),
	nome VARCHAR(30),
	email VARCHAR(30),
	endereço VARCHAR(50)
);

-- inserção em usuario
INSERT INTO usuario(cpf, telefone, nome, email, endereço)
VALUES('123.456.789-10','(34) 9 9999-9999' , 'Gleidson Barbosa', 'plufty@hotmail.com', 'Rua A, 123 - Rio paranaíba, MG'),
	  ('321.654.987-01','(34) 8 8888-8888' , 'Lucas Nardelli', 'Lucao@outlook.com', 'Rua Gigantes, 258 - Rio paranaíba, MG'),
	  ('987.654.321-00','(34) 7 7777-7777' , 'Daniel Pereira', 'Daniboy@live.com', 'Rua Seduzente, 69 - Rio paranaíba, MG');

CREATE TABLE categorias
(
	categoria INT PRIMARY KEY,
	descricao VARCHAR(20),
	sigla	VARCHAR(3)
);

-- Inserção em categorias
INSERT INTO categorias VALUES(1, 'Imagem', 'IMG');
INSERT INTO categorias VALUES(2, 'Áudio', 'AUD');
INSERT INTO categorias VALUES(3, 'Vídeos', 'VID');
INSERT INTO categorias VALUES(4, 'Fotografias', 'FOT');
INSERT INTO categorias VALUES(5, 'Arquivos de texto', 'TXT');
INSERT INTO categorias VALUES(6, 'Mapas', 'MAP');


-- publicação 
CREATE TABLE publicacao
(
	ID INT PRIMARY KEY,
	cpf_usuario VARCHAR(15) NOT NULL,
	categoria INT,	
	nome_autor VARCHAR(20),
	titulo VARCHAR(20),
	genero VARCHAR(20),
	editora VARCHAR(30),
	oid_midia OID
	
);
ALTER TABLE publicacao ADD CONSTRAINT FK_categorias_publicacao FOREIGN KEY (categoria) REFERENCES categorias(categoria);
ALTER TABLE publicacao ADD CONSTRAINT FK_usuario_publicacao FOREIGN KEY (cpf_usuario) REFERENCES usuario(CPF);

-- inserção em publicação
INSERT INTO publicacao(ID, cpf_usuario, categoria, nome_autor, titulo, genero, editora, oid_midia) 
VALUES (1,'123.456.789-10',1,'Entediado','Dormindo na Rede','Fotografias','Fotogênica', lo_import('C:\Users\Public\entediado\Rede Boa.png')),
(2,'987.654.321-00',1,'Daniboy','Daniboy Supinão com 100KG','Fotografias', 'BodyBuilders', lo_import('C:\Users\Public\bodybuilder\BIRLLLL.png')),
(3,'321.654.987-01',3,'Lucão the Anão', 'Aula Discreta', 'Aulas','Monitorando', lo_import('C:\Users\Public\lucao\discreta.mp4')),
(4,'123.456.789-10',3,'Leo Stronda','Bonde da Stronda - Bonde da maromba', 'Música', 'Bonde da Stronda',lo_import('C:\Users\Public\plufty\Bonde da Maromba.mp4'));

-- TABELAS LOGS
CREATE TABLE logs_exclusao
(
 tabela VARCHAR(30),
 usuario VARCHAR(30),
 hora TIME,
 data DATE
);

CREATE TABLE logs_atualizacoes
(
 tabela VARCHAR(20),
 usuario VARCHAR(25),
 hora TIME,
 data DATE
);

-- INSERÇÃO LOGS

CREATE OR REPLACE RULE excluir_publicacao
AS ON DELETE TO publicacao DO
INSERT INTO logs_exclusao(tabela,usuario,hora,data)
VALUES('Publicação',
	   current_user, 
	   current_time, 
	   current_date);

CREATE OR REPLACE RULE remover_oid 
AS ON DELETE TO publicacao DO
SELECT lo_unlink(old.oid_midia);

CREATE OR REPLACE RULE delete_usuarios
AS ON DELETE TO usuario DO
INSERT INTO logs_exclusao(tabela,usuario,hora,data)
VALUES('usuario',
	   current_user,
	   current_time,
	   current_date);

CREATE OR REPLACE RULE atualizar_publicacao 
AS ON UPDATE TO publicacao DO
INSERT INTO logs_atualizacoes(tabela,usuario,hora,data)
values('publicacao',
	   current_user,
	   current_time,
	   current_date);

CREATE OR REPLACE RULE update_usuarios
AS ON UPDATE TO usuario DO
INSERT INTO logs_atualizacoes(tabela,usuario,hora,data)
VALUES('usuario',
	   current_user,
	   current_time,
	   current_date);

-- FUNÇÕES - editora, autor, categoria
CREATE FUNCTION filtrar_editora (VARCHAR)
RETURNS SETOF publicacao AS $$
BEGIN
	SELECT * 
	FROM publicacao
	WHERE $1 ILIKE publicacao.editora;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION filtrar_autor (VARCHAR)
RETURNS SETOF publicacao AS $$
BEGIN
	SELECT * 
	FROM publicacao
	WHERE $1 ILIKE publicacao.autor;
END
$$ LANGUAGE PLPGSQL;

CREATE FUNCTION filtrar_categoria (VARCHAR)
RETURNS SETOF publicacao AS $$
BEGIN
	SELECT * 
	FROM publicacao
	WHERE $1 ILIKE publicacao.categoria;
END
$$ LANGUAGE PLPGSQL;

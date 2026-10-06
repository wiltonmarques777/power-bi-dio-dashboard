-- =============================================================================
-- MODELAGEM DIMENSIONAL - STAR SCHEMA (ACADÊMICO - FOCO EM PROFESSOR)
-- Script DDL para criação do Banco de Dados / Data Warehouse
-- Dialeto: ANSI SQL / PostgreSQL
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. TABELA DIMENSÃO: Dim_Professor
-- -----------------------------------------------------------------------------
CREATE TABLE Dim_Professor (
    sk_professor        SERIAL PRIMARY KEY,
    id_professor_nk     INT NOT NULL,              -- Natural Key (ID do sistema OLTP)
    nome_professor      VARCHAR(150) NOT NULL,
    matricula           VARCHAR(50),
    titulacao           VARCHAR(50),               -- Ex: Especialista, Mestre, Doutor
    regime_trabalho     VARCHAR(50),               -- Ex: Dedicação Exclusiva, 20h, 40h
    status_docente      VARCHAR(50),               -- Ex: Ativo, Licenciado, Aposentado
    data_admissao       DATE
);

-- -----------------------------------------------------------------------------
-- 2. TABELA DIMENSÃO: Dim_Departamento
-- -----------------------------------------------------------------------------
CREATE TABLE Dim_Departamento (
    sk_departamento     SERIAL PRIMARY KEY,
    id_departamento_nk  INT NOT NULL,              -- Natural Key
    nome_departamento   VARCHAR(150) NOT NULL,
    sigla_departamento  VARCHAR(20),
    centro_academico    VARCHAR(100),
    campus              VARCHAR(100),
    chefe_departamento  VARCHAR(150)
);

-- -----------------------------------------------------------------------------
-- 3. TABELA DIMENSÃO: Dim_Curso
-- -----------------------------------------------------------------------------
CREATE TABLE Dim_Curso (
    sk_curso            SERIAL PRIMARY KEY,
    id_curso_nk         INT NOT NULL,              -- Natural Key
    nome_curso          VARCHAR(150) NOT NULL,
    nivel_curso         VARCHAR(50),               -- Ex: Graduação, Pós-Graduação
    modalidade          VARCHAR(50),               -- Ex: Presencial, EAD
    turno               VARCHAR(50)                -- Ex: Matutino, Noturno, Integral
);

-- -----------------------------------------------------------------------------
-- 4. TABELA DIMENSÃO: Dim_Disciplina
-- -----------------------------------------------------------------------------
CREATE TABLE Dim_Disciplina (
    sk_disciplina       SERIAL PRIMARY KEY,
    id_disciplina_nk    INT NOT NULL,              -- Natural Key
    nome_disciplina     VARCHAR(150) NOT NULL,
    codigo_disciplina   VARCHAR(20),
    carga_horaria_teorica INT DEFAULT 0,
    carga_horaria_pratica INT DEFAULT 0,
    carga_horaria_total INT DEFAULT 0,
    tipo_disciplina     VARCHAR(50)                -- Ex: Obrigatória, Eletiva
);

-- -----------------------------------------------------------------------------
-- 5. TABELA DIMENSÃO: Dim_Data (Dimensão Temporal)
-- -----------------------------------------------------------------------------
CREATE TABLE Dim_Data (
    sk_data             INT PRIMARY KEY,           -- Formato YYYYMMDD (ex: 20260301)
    data_completa       DATE NOT NULL,
    ano                 INT NOT NULL,
    semestre            INT NOT NULL,              -- 1 ou 2
    ano_semestre        VARCHAR(10) NOT NULL,      -- Ex: '2026/1'
    trimestre           INT NOT NULL,              -- 1, 2, 3 ou 4
    mes                 INT NOT NULL,
    nome_mes            VARCHAR(20) NOT NULL,      -- Ex: 'Março'
    dia_da_semana       VARCHAR(20) NOT NULL,      -- Ex: 'Segunda-feira'
    eh_dia_util         BOOLEAN NOT NULL DEFAULT TRUE
);

-- -----------------------------------------------------------------------------
-- 6. TABELA FATO: Fato_Professor_Atividade
-- -----------------------------------------------------------------------------
CREATE TABLE Fato_Professor_Atividade (
    sk_fato                     BIGSERIAL PRIMARY KEY,
    sk_professor                INT NOT NULL,
    sk_departamento             INT NOT NULL,
    sk_curso                    INT NOT NULL,
    sk_disciplina               INT NOT NULL,
    sk_data_oferta              INT NOT NULL,
    
    -- Métricas Quantitativas
    carga_horaria_ministrada    INT NOT NULL DEFAULT 0,
    quantidade_turmas           INT NOT NULL DEFAULT 1,
    quantidade_disciplinas      INT NOT NULL DEFAULT 1,
    valor_hora_aula             DECIMAL(10,2),
    custo_total_oferta          DECIMAL(10,2),

    -- Chaves Estrangeiras (Foreign Keys)
    CONSTRAINT fk_fato_professor    FOREIGN KEY (sk_professor)    REFERENCES Dim_Professor (sk_professor),
    CONSTRAINT fk_fato_departamento FOREIGN KEY (sk_departamento) REFERENCES Dim_Departamento (sk_departamento),
    CONSTRAINT fk_fato_curso        FOREIGN KEY (sk_curso)        REFERENCES Dim_Curso (sk_curso),
    CONSTRAINT fk_fato_disciplina   FOREIGN KEY (sk_disciplina)   REFERENCES Dim_Disciplina (sk_disciplina),
    CONSTRAINT fk_fato_data_oferta  FOREIGN KEY (sk_data_oferta)  REFERENCES Dim_Data (sk_data)
);

-- -----------------------------------------------------------------------------
-- 7. ÍNDICES DE PERFORMANCE PARA CONSULTAS ANALÍTICAS (OLAP / DWH)
-- -----------------------------------------------------------------------------
CREATE INDEX idx_fato_professor    ON Fato_Professor_Atividade(sk_professor);
CREATE INDEX idx_fato_departamento ON Fato_Professor_Atividade(sk_departamento);
CREATE INDEX idx_fato_curso        ON Fato_Professor_Atividade(sk_curso);
CREATE INDEX idx_fato_disciplina   ON Fato_Professor_Atividade(sk_disciplina);
CREATE INDEX idx_fato_data_oferta  ON Fato_Professor_Atividade(sk_data_oferta);

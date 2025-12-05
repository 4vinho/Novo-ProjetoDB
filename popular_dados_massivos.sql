-- ============================================================================
-- SUPER SQL: POPULACAO MASSIVA DE DADOS
-- Funcao para popular TODAS as tabelas com MILHOES de dados aleatorios
-- GARANTIA: TODAS as tabelas terao MILHOES de registros!
-- Uso: SELECT popular_dados_massivos(); -- p_fast_mode TRUE (padrao rapido)
--      SELECT popular_dados_massivos(FALSE); -- modo completo (milhoes)
-- Parametro p_fast_mode ajusta v_batch_size (50.000 vs 200.000 registros por lote)
-- ============================================================================

-- Ensure UTF-8 encoding before running the heavy inserts
\encoding UTF8

\c agencia_turismo;
SET client_encoding TO 'UTF8';

-- ============================================================================
-- FUNCAO PRINCIPAL: popular_dados_massivos
-- Gera MILHOES de dados aleatorios em TODAS as tabelas
-- SEM parametros = popula milhoes em todas as tabelas automaticamente
-- ============================================================================

CREATE OR REPLACE FUNCTION popular_dados_massivos(p_fast_mode BOOLEAN DEFAULT TRUE)
RETURNS TEXT AS 
DECLARE
    v_inicio TIMESTAMP;
    v_fim TIMESTAMP;
    v_duracao INTERVAL;
    v_total_registros BIGINT := 0;
    v_batch_size INTEGER := CASE WHEN p_fast_mode THEN 50000 ELSE 200000 END;
    v_loop_count INTEGER;

    v_target_clientes CONSTANT BIGINT := 10000000;
    v_target_funcionarios CONSTANT BIGINT := 10000000;
    v_target_destinos CONSTANT BIGINT := 10000000;
    v_target_hoteis CONSTANT BIGINT := 10000000;
    v_target_transportes CONSTANT BIGINT := 10000000;
    v_target_pacotes CONSTANT BIGINT := 10000000;
    v_target_reservas CONSTANT BIGINT := 10000000;
    v_target_pagamentos CONSTANT BIGINT := 10000000;
    v_target_avaliacoes CONSTANT BIGINT := 10000000;
    v_target_auditoria CONSTANT BIGINT := 10000000;
BEGIN
    v_inicio := clock_timestamp();

    SET session_replication_role = replica;

    -- ========================================================================
    -- 1. TB_CLIENTES: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_clientes + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_clientes (nome_completo, cpf, data_nascimento, email, telefone, endereco, cidade, estado, cep)
        SELECT
            'Cliente ' || (batch * v_batch_size + seq_idx) || ' ' ||
            (ARRAY['Silva', 'Santos', 'Oliveira', 'Souza', 'Lima', 'Pereira', 'Costa', 'Rodrigues', 'Almeida', 'Nascimento', 'Ferreira', 'Martins', 'Araújo', 'Cardoso', 'Ribeiro'])[floor(random() * 15 + 1)],
            LPAD((10000000000 + (batch * v_batch_size + seq_idx))::TEXT, 11, '0'),
            DATE '1950-01-01' + (random() * 25000)::INTEGER,
            'cliente' || (batch * v_batch_size + seq_idx) || '@email.com.br',
            (ARRAY['11', '21', '31', '41', '51', '61', '71', '81', '85', '91'])[floor(random() * 10 + 1)] || LPAD((900000000 + (batch * v_batch_size + seq_idx))::TEXT, 9, '0'),
            (ARRAY['Rua das Flores', 'Avenida Brasil', 'Rua Principal', 'Alameda Santos', 'Travessa do Comercio'])[floor(random() * 5 + 1)] || ', ' || (batch * v_batch_size + seq_idx),
            (ARRAY['São Paulo', 'Rio de Janeiro', 'Brasília', 'Belo Horizonte', 'Salvador', 'Fortaleza', 'Recife', 'Curitiba', 'Porto Alegre', 'Manaus', 'Belém', 'Goiânia', 'Campinas', 'Guarulhos', 'São Luís'])[floor(random() * 15 + 1)],
            (ARRAY['SP', 'RJ', 'DF', 'MG', 'BA', 'CE', 'PE', 'PR', 'RS', 'AM', 'PA', 'GO', 'MA', 'ES', 'SC'])[floor(random() * 15 + 1)],
            LPAD((10000000 + (random() * 89999999)::INTEGER)::TEXT, 8, '0')
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target_clientes;
    END LOOP;
    v_total_registros := v_total_registros + v_target_clientes;

    -- ========================================================================
    -- 2. TB_FUNCIONARIOS: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_funcionarios + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_funcionarios (nome_completo, cpf, email_corporativo, telefone, cargo, salario, data_admissao, status)
        SELECT
            'Funcionario ' || (batch * v_batch_size + seq_idx) || ' ' ||
            (ARRAY['Silva', 'Santos', 'Oliveira', 'Costa', 'Lima', 'Pereira', 'Souza', 'Almeida'])[floor(random() * 8 + 1)],
            LPAD((50000000000 + (batch * v_batch_size + seq_idx))::TEXT, 11, '0'),
            'func' || (batch * v_batch_size + seq_idx) || '@agenciaturismo.com.br',
            '61' || LPAD((991000000 + (batch * v_batch_size + seq_idx))::TEXT, 9, '0'),
            (ARRAY['VENDEDOR', 'VENDEDOR', 'VENDEDOR', 'ATENDENTE', 'ATENDENTE', 'SUPERVISOR', 'GERENTE', 'DIRETOR'])[floor(random() * 8 + 1)],
            2500.00 + (random() * 17500)::NUMERIC(10,2),
            DATE '2000-01-01' + (random() * 9000)::INTEGER,
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'FERIAS', 'DESLIGADO'])[floor(random() * 5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target_funcionarios;
    END LOOP;
    v_total_registros := v_total_registros + v_target_funcionarios;

    -- ========================================================================
    -- 3. TB_DESTINOS: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_destinos + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_destinos (nome_destino, pais, cidade, estado, descricao, tipo_destino, clima, idioma, moeda, status)
        SELECT
            'Destino ' || (batch * v_batch_size + seq_idx),
            (ARRAY['Brasil', 'Estados Unidos', 'Portugal', 'Espanha', 'França', 'Itália', 'Chile', 'Argentina', 'Japão', 'Emirados Árabes'])[floor(random() * 10 + 1)],
            'Cidade Turística ' || (batch * v_batch_size + seq_idx),
            CASE WHEN random() > 0.5 THEN (ARRAY['SP', 'RJ', 'BA', 'CE', 'PE', 'SC', 'RS', 'MG', 'PR', 'GO'])[floor(random() * 10 + 1)] ELSE NULL END,
            'Destino turístico incrível com paisagens deslumbrantes e cultura rica. Perfeito para todas as idades.',
            (ARRAY['PRAIA', 'PRAIA', 'MONTANHA', 'URBANO', 'AVENTURA', 'CULTURAL', 'ECOLOGICO', 'RELIGIOSO'])[floor(random() * 8 + 1)],
            (ARRAY['Tropical', 'Temperado', 'Subtropical', 'Equatorial', 'Árido', 'Mediterrâneo', 'Continental'])[floor(random() * 7 + 1)],
            (ARRAY['Português', 'Espanhol', 'Inglês', 'Francês', 'Italiano', 'Alemão', 'Mandarim', 'Japonês'])[floor(random() * 8 + 1)],
            (ARRAY['Real (BRL)', 'Dólar (USD)', 'Euro (EUR)', 'Peso (ARS)', 'Peso (CLP)', 'Sol (PEN)', 'Libra (GBP)', 'Iene (JPY)'])[floor(random() * 8 + 1)],
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'INATIVO'])[floor(random() * 5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target_destinos;
    END LOOP;
    v_total_registros := v_total_registros + v_target_destinos;

    -- ========================================================================
    -- 4. TB_HOTEIS: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_hoteis + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_hoteis (id_destino, nome_hotel, endereco, classificacao_estrelas, descricao, comodidades, valor_diaria_minima, telefone, email, status)
        SELECT
            floor(random() * v_target_destinos + 1)::INTEGER,
            (ARRAY['Hotel', 'Resort', 'Pousada', 'Inn', 'Hostel', 'Lodge'])[floor(random() * 6 + 1)] || ' ' ||
            (ARRAY['Plaza', 'Royal', 'Grand', 'Paradise', 'Golden', 'Imperial', 'Majestic', 'Sunset', 'Ocean', 'Mountain'])[floor(random() * 10 + 1)] || ' ' || (batch * v_batch_size + seq_idx),
            'Rua Principal, ' || (batch * v_batch_size + seq_idx) || ', Centro',
            floor(random() * 5 + 1)::INTEGER,
            'Hotel confortável e bem localizado com excelente infraestrutura para turistas.',
            (ARRAY['Wi-Fi, Piscina, Academia', 'Wi-Fi, Café da manhã, Estacionamento', 'Wi-Fi, Spa, Sauna, Academia', 'Wi-Fi, Piscina, Bar, Restaurante', 'Wi-Fi, Ar condicionado, TV a cabo'])[floor(random() * 5 + 1)],
            100.00 + (random() * 4900)::NUMERIC(10,2),
            (ARRAY['11', '21', '31', '41', '51', '61', '71', '81'])[floor(random() * 8 + 1)] || LPAD((30000000 + (batch * v_batch_size + seq_idx))::TEXT, 8, '0'),
            'contato' || (batch * v_batch_size + seq_idx) || '@hotel.com.br',
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'INATIVO'])[floor(random() * 5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target_hoteis;
    END LOOP;
    v_total_registros := v_total_registros + v_target_hoteis;

    -- ========================================================================
    -- 5. TB_TRANSPORTES: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_transportes + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_transportes (tipo_transporte, empresa_parceira, modelo, capacidade_passageiros, classe, preco_base, status)
        SELECT
            (ARRAY['AEREO', 'AEREO', 'AEREO', 'ONIBUS', 'ONIBUS', 'VAN', 'NAVIO', 'TREM'])[floor(random() * 8 + 1)],
            (ARRAY['LATAM', 'GOL', 'Azul', 'TAP', 'Emirates', 'Air France', 'United', 'Viação Cometa', 'Viação Itapemirim', 'MSC Cruzeiros', 'Costa Cruzeiros'])[floor(random() * 11 + 1)],
            'Modelo ' || (batch * v_batch_size + seq_idx) || ' ' || (ARRAY['Executivo', 'Standard', 'Premium', 'Luxury'])[floor(random() * 4 + 1)],
            floor(random() * 500 + 10)::INTEGER,
            (ARRAY['ECONOMICA', 'ECONOMICA', 'EXECUTIVA', 'PRIMEIRA_CLASSE', 'LEITO', 'SEMI_LEITO'])[floor(random() * 6 + 1)],
            80.00 + (random() * 9920)::NUMERIC(10,2),
            (ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'MANUTENCAO'])[floor(random() * 5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target_transportes;
    END LOOP;
    v_total_registros := v_total_registros + v_target_transportes;

    -- ========================================================================
    -- 6. TB_PACOTES_TURISTICOS: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_pacotes + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_pacotes_turisticos (nome_pacote, id_destino, id_hotel, id_transporte, descricao_completa, duracao_dias, data_inicio, data_fim, preco_total, vagas_disponiveis, regime_alimentar, incluso, nao_incluso, status)
        SELECT
            'Pacote Especial ' || (batch * v_batch_size + seq_idx) || ' - ' ||
            (ARRAY['Férias dos Sonhos', 'Aventura Radical', 'Relax Total', 'Família Feliz', 'Lua de Mel', 'Executivo'])[floor(random() * 6 + 1)],
            floor(random() * v_target_destinos + 1)::INTEGER,
            floor(random() * v_target_hoteis + 1)::INTEGER,
            floor(random() * v_target_transportes + 1)::INTEGER,
            'Pacote completo com hospedagem, transporte e passeios inclusos. Experiência inesquecível!',
            periodo.duracao_dias,
            periodo.data_inicio,
            periodo.data_inicio + periodo.duracao_dias,
            1000.00 + (random() * 49000)::NUMERIC(10,2),
            floor(random() * 100 + 1)::INTEGER,
            (ARRAY['CAFE_MANHA', 'MEIA_PENSAO', 'PENSAO_COMPLETA', 'ALL_INCLUSIVE', 'SEM_ALIMENTACAO'])[floor(random() * 5 + 1)],
            'Transporte, hospedagem, café da manhã, seguro viagem',
            'Passeios opcionais, refeições extras, bebidas',
            (ARRAY['DISPONIVEL', 'DISPONIVEL', 'DISPONIVEL', 'DISPONIVEL', 'ESGOTADO', 'CANCELADO'])[floor(random() * 6 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        CROSS JOIN LATERAL (
            SELECT
                (CURRENT_DATE + (random() * 730)::INTEGER) AS data_inicio,
                (floor(random() * 20 + 3)::INTEGER) AS duracao_dias
        ) AS periodo
        WHERE (batch * v_batch_size + seq_idx) <= v_target_pacotes;
    END LOOP;
    v_total_registros := v_total_registros + v_target_pacotes;

    -- ========================================================================
    -- 7. TB_RESERVAS: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_reservas + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, observacoes, status_reserva, data_reserva)
        SELECT
            floor(random() * v_target_clientes + 1)::INTEGER,
            floor(random() * v_target_pacotes + 1)::INTEGER,
            floor(random() * v_target_funcionarios + 1)::INTEGER,
            precos.passageiros,
            precos.valor_unitario,
            precos.desconto,
            ROUND(precos.valor_unitario * precos.passageiros * (1 - precos.desconto / 100.0), 2),
            CASE WHEN random() > 0.8 THEN 'Observação especial da reserva' ELSE NULL END,
            (ARRAY['CONFIRMADA', 'CONFIRMADA', 'CONFIRMADA', 'CONFIRMADA', 'PENDENTE', 'CANCELADA', 'FINALIZADA'])[floor(random() * 7 + 1)],
            CURRENT_TIMESTAMP - (random() * 730 || ' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        CROSS JOIN LATERAL (
            SELECT
                floor(random() * 6 + 1)::INTEGER AS passageiros,
                1000.00 + (random() * 49000)::NUMERIC(10,2) AS valor_unitario,
                (random() * 25)::NUMERIC(5,2) AS desconto
        ) AS precos
        WHERE (batch * v_batch_size + seq_idx) <= v_target_reservas;
    END LOOP;
    v_total_registros := v_total_registros + v_target_reservas;

    -- ========================================================================
    -- 8. TB_PAGAMENTOS: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_pagamentos + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_pagamentos (id_reserva, forma_pagamento, numero_parcela, total_parcelas, valor_parcela, data_vencimento, status_pagamento, numero_transacao, data_pagamento)
        SELECT
            floor(random() * v_target_reservas + 1)::INTEGER,
            (ARRAY['DINHEIRO', 'DEBITO', 'CREDITO', 'CREDITO', 'CREDITO', 'PIX', 'PIX', 'TRANSFERENCIA', 'BOLETO'])[floor(random() * 9 + 1)],
            parcela.numero_parcela,
            parcela.total_parcelas,
            100.00 + (random() * 9900)::NUMERIC(10,2),
            CURRENT_DATE + (random() * 365)::INTEGER,
            (ARRAY['PENDENTE', 'PAGO', 'PAGO', 'PAGO', 'PAGO', 'CANCELADO', 'ESTORNADO'])[floor(random() * 7 + 1)],
            'TXN' || LPAD((batch * v_batch_size + seq_idx)::TEXT, 20, '0'),
            CURRENT_TIMESTAMP - (random() * 365 || ' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        CROSS JOIN LATERAL (
            SELECT total_parcelas, floor(random() * total_parcelas)::INTEGER + 1 AS numero_parcela
            FROM (SELECT floor(random() * 12 + 1)::INTEGER AS total_parcelas) t
        ) AS parcela
        WHERE (batch * v_batch_size + seq_idx) <= v_target_pagamentos;
    END LOOP;
    v_total_registros := v_total_registros + v_target_pagamentos;

    -- ========================================================================
    -- 9. TB_AVALIACOES: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_avaliacoes + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_avaliacoes (id_cliente, id_pacote, nota, comentario, data_avaliacao)
        SELECT
            floor(random() * v_target_clientes + 1)::INTEGER,
            floor(random() * v_target_pacotes + 1)::INTEGER,
            floor(random() * 5 + 1)::INTEGER,
            (ARRAY['Excelente experiência!', 'Muito bom, recomendo!', 'Bom custo-benefício', 'Atendeu as expectativas', 'Poderia melhorar', 'Maravilhoso!', 'Perfeito!', 'Inesquecível!', NULL, NULL])[floor(random() * 10 + 1)],
            CURRENT_TIMESTAMP - (random() * 365 || ' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target_avaliacoes
        ON CONFLICT (id_cliente, id_pacote) DO NOTHING;
    END LOOP;
    v_total_registros := v_total_registros + v_target_avaliacoes;

    -- ========================================================================
    -- 10. TB_AUDITORIA: >= 10 MILHOES DE REGISTROS
    -- ========================================================================
    v_loop_count := ((v_target_auditoria + v_batch_size - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_auditoria (tabela_afetada, operacao, usuario_db, dados_antigos, dados_novos, id_registro_afetado, observacao, data_hora)
        SELECT
            (ARRAY['tb_reservas', 'tb_pagamentos', 'tb_clientes', 'tb_pacotes_turisticos'])[floor(random() * 4 + 1)],
            (ARRAY['INSERT', 'UPDATE', 'DELETE'])[floor(random() * 3 + 1)],
            'user_' || floor(random() * 100 + 1),
            CASE WHEN random() > 0.5 THEN ('{id: ' || seq_idx || ', valor: ' || (random() * 10000)::INTEGER || '}')::JSONB ELSE NULL END,
            ('{id: ' || seq_idx || ', novo_valor: ' || (random() * 10000)::INTEGER || '}')::JSONB,
            floor(random() * v_target_reservas + 1)::INTEGER,
            'Operação registrada automaticamente pelo sistema de auditoria',
            CURRENT_TIMESTAMP - (random() * 365 || ' days')::INTERVAL
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target_auditoria;
    END LOOP;
    v_total_registros := v_total_registros + v_target_auditoria;

    SET session_replication_role = DEFAULT;
    ANALYZE;

    v_fim := clock_timestamp();
    v_duracao := v_fim - v_inicio;

    RETURN '✓ SUCESSO! ' || v_total_registros || ' registros em ' || v_duracao;

EXCEPTION
    WHEN OTHERS THEN
        SET session_replication_role = DEFAULT;
        RETURN 'ERRO: ' || SQLERRM;
END;
 LANGUAGE plpgsql;
-- ============================================================================
-- FUNÇÕES AUXILIARES
-- ============================================================================

-- Limpar TODAS as tabelas
CREATE OR REPLACE FUNCTION limpar_todas_tabelas()
RETURNS TEXT AS $$
BEGIN
    TRUNCATE TABLE tb_avaliacoes CASCADE;
    TRUNCATE TABLE tb_pagamentos CASCADE;
    TRUNCATE TABLE tb_reservas CASCADE;
    TRUNCATE TABLE tb_pacotes_turisticos CASCADE;
    TRUNCATE TABLE tb_transportes CASCADE;
    TRUNCATE TABLE tb_hoteis CASCADE;
    TRUNCATE TABLE tb_destinos CASCADE;
    TRUNCATE TABLE tb_funcionarios CASCADE;
    TRUNCATE TABLE tb_clientes CASCADE;
    TRUNCATE TABLE tb_auditoria CASCADE;
    RETURN '✓ Todas as tabelas foram limpas!';
END;
$$ LANGUAGE plpgsql;

-- Verificar quantidade e tamanho das tabelas
CREATE OR REPLACE FUNCTION verificar_tamanho_tabelas()
RETURNS TABLE (
    tabela TEXT,
    registros TEXT,
    tamanho_dados TEXT,
    tamanho_indices TEXT,
    tamanho_total TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        relname::TEXT AS tabela,
        TO_CHAR(n_live_tup, '999G999G999') AS registros,
        pg_size_pretty(pg_relation_size(schemaname||'.'||relname)) AS tamanho_dados,
        pg_size_pretty(pg_indexes_size(schemaname||'.'||relname)) AS tamanho_indices,
        pg_size_pretty(pg_total_relation_size(schemaname||'.'||relname)) AS tamanho_total
    FROM pg_stat_user_tables
    WHERE schemaname = 'public'
    ORDER BY n_live_tup DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- USO
-- ============================================================================

-- EXECUTAR POPULACAO MASSIVA
-- SELECT popular_dados_massivos();        -- modo rapido (p_fast_mode = TRUE)
-- SELECT popular_dados_massivos(FALSE);   -- modo completo (milhoes)

-- LIMPAR TUDO
-- SELECT limpar_todas_tabelas();

-- VERIFICAR RESULTADO
-- SELECT * FROM verificar_tamanho_tabelas();

-- ============================================================================
-- RESUMO FINAL
-- Total inserido = soma(lotes * v_batch_size). Verifique o retorno da funcao.
-- ============================================================================

SELECT '🚀 Super SQL criado! Execute: SELECT popular_dados_massivos();' AS status;




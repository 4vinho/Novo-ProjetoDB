-- ============================================================================
-- SUPER SQL: POPULACAO MASSIVA DE DADOS
-- Gera ao menos 10 MILHOES de registros em CADA tabela
-- Uso rapido: SELECT popular_dados_massivos(); -- p_fast_mode = TRUE (50k por lote)
-- Uso completo: SELECT popular_dados_massivos(FALSE); -- 200k por lote
-- ============================================================================

\encoding UTF8
\c agencia_turismo;
SET client_encoding TO 'UTF8';

CREATE OR REPLACE FUNCTION popular_dados_massivos(p_fast_mode BOOLEAN DEFAULT TRUE)
RETURNS TEXT AS $$
DECLARE
    v_inicio TIMESTAMP := clock_timestamp();
    v_fim TIMESTAMP;
    v_duracao INTERVAL;
    v_total BIGINT := 0;
    v_batch_size INTEGER := CASE WHEN p_fast_mode THEN 50000 ELSE 200000 END;
    v_loop_count INTEGER;

    v_target CONSTANT BIGINT := 10000000; -- minimo por tabela

    -- auxiliares para limites de chaves estrangeiras
    v_last_cliente BIGINT := 0;
    v_last_funcionario BIGINT := 0;
    v_last_destino BIGINT := 0;
    v_last_hotel BIGINT := 0;
    v_last_transporte BIGINT := 0;
    v_last_pacote BIGINT := 0;
    v_last_reserva BIGINT := 0;
BEGIN
    SET session_replication_role = replica;

    -- ========================================================================
    -- 1. CLIENTES
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_clientes (nome_completo, cpf, data_nascimento, email, telefone, endereco, cidade, estado, cep)
        SELECT
            'Cliente ' || (batch * v_batch_size + seq_idx) || ' ' ||
            (ARRAY['Silva','Santos','Oliveira','Souza','Lima','Pereira','Costa','Rodrigues','Almeida','Nascimento','Ferreira','Martins','Araujo','Cardoso','Ribeiro'])[floor(random()*15 + 1)],
            LPAD((10000000000 + batch * v_batch_size + seq_idx)::TEXT, 11, '0'),
            DATE '1950-01-01' + (random() * 25000)::INT,
            'cliente' || (batch * v_batch_size + seq_idx) || '@email.com.br',
            (ARRAY['11','21','31','41','51','61','71','81','85','91'])[floor(random()*10 + 1)] ||
                LPAD((900000000 + seq_idx)::TEXT, 9, '0'),
            (ARRAY['Rua das Flores','Avenida Brasil','Rua Principal','Alameda Santos','Travessa do Comercio'])[floor(random()*5 + 1)] || ', ' || (batch * v_batch_size + seq_idx),
            (ARRAY['Sao Paulo','Rio de Janeiro','Brasilia','Belo Horizonte','Salvador','Fortaleza','Recife','Curitiba','Porto Alegre','Manaus','Belem','Goiania','Campinas','Guarulhos','Sao Luis'])[floor(random()*15 + 1)],
            (ARRAY['SP','RJ','DF','MG','BA','CE','PE','PR','RS','AM','PA','GO','MA','ES','SC'])[floor(random()*15 + 1)],
            LPAD((10000000 + (random()*89999999)::INT)::TEXT, 8, '0')
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_last_cliente := v_target;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 2. FUNCIONARIOS
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_funcionarios (nome_completo, cpf, email_corporativo, telefone, cargo, salario, data_admissao, status)
        SELECT
            'Funcionario ' || (batch * v_batch_size + seq_idx) || ' ' ||
            (ARRAY['Silva','Santos','Oliveira','Costa','Lima','Pereira','Souza','Almeida'])[floor(random()*8 + 1)],
            LPAD((50000000000 + batch * v_batch_size + seq_idx)::TEXT, 11, '0'),
            'func' || (batch * v_batch_size + seq_idx) || '@agenciaturismo.com.br',
            '61' || LPAD((991000000 + seq_idx)::TEXT, 9, '0'),
            (ARRAY['VENDEDOR','VENDEDOR','VENDEDOR','ATENDENTE','ATENDENTE','SUPERVISOR','GERENTE','DIRETOR'])[floor(random()*8 + 1)],
            2500 + (random()*17500)::NUMERIC(10,2),
            DATE '2000-01-01' + (random()*9000)::INT,
            (ARRAY['ATIVO','ATIVO','ATIVO','FERIAS','DESLIGADO'])[floor(random()*5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_last_funcionario := v_target;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 3. DESTINOS
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_destinos (nome_destino, pais, cidade, estado, descricao, tipo_destino, clima, idioma, moeda, status)
        SELECT
            'Destino ' || (batch * v_batch_size + seq_idx),
            (ARRAY['Brasil','Estados Unidos','Portugal','Espanha','Franca','Italia','Chile','Argentina','Japao','Emirados Arabes'])[floor(random()*10 + 1)],
            'Cidade Turistica ' || (batch * v_batch_size + seq_idx),
            CASE WHEN random() > 0.5 THEN (ARRAY['SP','RJ','BA','CE','PE','SC','RS','MG','PR','GO'])[floor(random()*10 + 1)] ELSE NULL END,
            'Destino com paisagens incriveis e cultura rica.',
            (ARRAY['PRAIA','MONTANHA','URBANO','AVENTURA','CULTURAL','ECOLOGICO','RELIGIOSO'])[floor(random()*7 + 1)],
            (ARRAY['Tropical','Temperado','Subtropical','Equatorial','Arido','Mediterraneo','Continental'])[floor(random()*7 + 1)],
            (ARRAY['Portugues','Espanhol','Ingles','Frances','Italiano','Alemao','Mandarim','Japones'])[floor(random()*8 + 1)],
            (ARRAY['Real','Dolar','Euro','Peso','Sol','Libra','Iene'])[floor(random()*7 + 1)],
            (ARRAY['ATIVO','ATIVO','ATIVO','ATIVO','INATIVO'])[floor(random()*5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_last_destino := v_target;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 4. HOTEIS
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_hoteis (id_destino, nome_hotel, endereco, classificacao_estrelas, descricao, comodidades, valor_diaria_minima, telefone, email, status)
        SELECT
            floor(random()*v_last_destino + 1)::INT,
            (ARRAY['Hotel','Resort','Pousada','Inn','Hostel','Lodge'])[floor(random()*6 + 1)] || ' ' ||
            (ARRAY['Plaza','Royal','Grand','Paradise','Golden','Imperial','Majestic','Sunset','Ocean','Mountain'])[floor(random()*10 + 1)] || ' ' || (batch * v_batch_size + seq_idx),
            'Rua Principal, ' || (batch * v_batch_size + seq_idx) || ', Centro',
            floor(random()*5 + 1)::INT,
            'Hospedagem completa com excelente estrutura.',
            (ARRAY['WiFi e Piscina','WiFi e Cafe','WiFi e Spa','WiFi e Restaurante','WiFi e TV'])[floor(random()*5 + 1)],
            100 + (random()*4900)::NUMERIC(10,2),
            (ARRAY['11','21','31','41','51','61','71','81'])[floor(random()*8 + 1)] || LPAD((30000000 + seq_idx)::TEXT, 8, '0'),
            'contato' || (batch * v_batch_size + seq_idx) || '@hotel.com.br',
            (ARRAY['ATIVO','ATIVO','ATIVO','ATIVO','INATIVO'])[floor(random()*5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_last_hotel := v_target;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 5. TRANSPORTES
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_transportes (tipo_transporte, empresa_parceira, modelo, capacidade_passageiros, classe, preco_base, status)
        SELECT
            (ARRAY['AEREO','ONIBUS','VAN','NAVIO','TREM'])[floor(random()*5 + 1)],
            (ARRAY['LATAM','GOL','Azul','TAP','Emirates','Air France','United','Cometa','Itapemirim','MSC','Costa'])[floor(random()*11 + 1)],
            'Modelo ' || (batch * v_batch_size + seq_idx) || ' ' || (ARRAY['Executivo','Standard','Premium','Luxury'])[floor(random()*4 + 1)],
            floor(random()*500 + 20)::INT,
            (ARRAY['ECONOMICA','EXECUTIVA','PRIMEIRA','LEITO'])[floor(random()*4 + 1)],
            80 + (random()*9920)::NUMERIC(10,2),
            (ARRAY['ATIVO','ATIVO','ATIVO','ATIVO','MANUTENCAO'])[floor(random()*5 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_last_transporte := v_target;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 6. PACOTES TURISTICOS
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_pacotes_turisticos (nome_pacote, id_destino, id_hotel, id_transporte, descricao_completa, duracao_dias, data_inicio, data_fim, preco_total, vagas_disponiveis, regime_alimentar, incluso, nao_incluso, status)
        SELECT
            'Pacote Especial ' || (batch * v_batch_size + seq_idx) || ' - ' ||
            (ARRAY['Ferias dos Sonhos','Aventura Radical','Relax Total','Familia Feliz','Lua de Mel','Executivo'])[floor(random()*6 + 1)],
            floor(random()*v_last_destino + 1)::INT,
            floor(random()*v_last_hotel + 1)::INT,
            floor(random()*v_last_transporte + 1)::INT,
            'Pacote completo com hospedagem, transporte e passeios.',
            periodo.dias,
            periodo.data_inicio,
            periodo.data_inicio + periodo.dias,
            1000 + (random()*49000)::NUMERIC(10,2),
            floor(random()*100 + 1)::INT,
            (ARRAY['CAFE_MANHA','MEIA_PENSAO','PENSAO_COMPLETA','ALL_INCLUSIVE','SEM_ALIMENTACAO'])[floor(random()*5 + 1)],
            'Transporte, hospedagem, seguro viagem',
            'Passeios opcionais, refeicoes extras, bebidas',
            (ARRAY['DISPONIVEL','DISPONIVEL','DISPONIVEL','DISPONIVEL','ESGOTADO','CANCELADO'])[floor(random()*6 + 1)]
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        CROSS JOIN LATERAL (
            SELECT (CURRENT_DATE + (random()*730)::INT) AS data_inicio,
                   (floor(random()*20 + 3)::INT) AS dias
        ) AS periodo
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_last_pacote := v_target;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 7. RESERVAS
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_reservas (id_cliente, id_pacote, id_funcionario, numero_passageiros, valor_unitario, desconto_percentual, valor_total, observacoes, status_reserva, data_reserva)
        SELECT
            floor(random()*v_last_cliente + 1)::INT,
            floor(random()*v_last_pacote + 1)::INT,
            floor(random()*v_last_funcionario + 1)::INT,
            precos.passageiros,
            precos.valor_unitario,
            precos.desconto,
            ROUND(precos.valor_unitario * precos.passageiros * (1 - precos.desconto / 100), 2),
            CASE WHEN random() > 0.8 THEN 'Observacao especial' ELSE NULL END,
            (ARRAY['CONFIRMADA','CONFIRMADA','CONFIRMADA','CONFIRMADA','PENDENTE','CANCELADA','FINALIZADA'])[floor(random()*7 + 1)],
            CURRENT_TIMESTAMP - ((random()*730)::INT * INTERVAL '1 day')
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        CROSS JOIN LATERAL (
            SELECT floor(random()*6 + 1)::INT AS passageiros,
                   1000 + (random()*49000)::NUMERIC(10,2) AS valor_unitario,
                   (random()*25)::NUMERIC(5,2) AS desconto
        ) AS precos
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_last_reserva := v_target;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 8. PAGAMENTOS
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_pagamentos (id_reserva, forma_pagamento, numero_parcela, total_parcelas, valor_parcela, data_vencimento, status_pagamento, numero_transacao, data_pagamento)
        SELECT
            floor(random()*v_last_reserva + 1)::INT,
            (ARRAY['DINHEIRO','DEBITO','CREDITO','PIX','TRANSFERENCIA','BOLETO'])[floor(random()*6 + 1)],
            parcelas.numero_parcela,
            parcelas.total_parcelas,
            100 + (random()*9900)::NUMERIC(10,2),
            CURRENT_DATE + (random()*365)::INT,
            (ARRAY['PENDENTE','PAGO','PAGO','PAGO','PAGO','CANCELADO','ESTORNADO'])[floor(random()*7 + 1)],
            'TXN' || LPAD((batch * v_batch_size + seq_idx)::TEXT, 20, '0'),
            CURRENT_TIMESTAMP - ((random()*365)::INT * INTERVAL '1 day')
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        CROSS JOIN LATERAL (
            SELECT total_parcelas,
                   floor(random() * total_parcelas)::INT + 1 AS numero_parcela
            FROM (SELECT floor(random()*12 + 1)::INT AS total_parcelas) AS tmp
        ) AS parcelas
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 9. AVALIACOES
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_avaliacoes (id_cliente, id_pacote, nota, comentario, data_avaliacao)
        SELECT
            floor(random()*v_last_cliente + 1)::INT,
            floor(random()*v_last_pacote + 1)::INT,
            floor(random()*5 + 1)::INT,
            (ARRAY['Excelente experiencia','Muito bom','Bom custo beneficio','Atendeu as expectativas','Poderia melhorar','Maravilhoso','Perfeito','Inesquecivel', NULL, NULL])[floor(random()*10 + 1)],
            CURRENT_TIMESTAMP - ((random()*365)::INT * INTERVAL '1 day')
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target
        ON CONFLICT (id_cliente, id_pacote) DO NOTHING;
    END LOOP;
    v_total := v_total + v_target;

    -- ========================================================================
    -- 10. AUDITORIA
    -- ========================================================================
    v_loop_count := ((v_target + v_batch_size::BIGINT - 1) / v_batch_size)::INTEGER;
    FOR batch IN 0..v_loop_count - 1 LOOP
        INSERT INTO tb_auditoria (tabela_afetada, operacao, usuario_db, dados_antigos, dados_novos, id_registro_afetado, observacao, data_hora)
        SELECT
            (ARRAY['tb_reservas','tb_pagamentos','tb_clientes','tb_pacotes_turisticos'])[floor(random()*4 + 1)],
            (ARRAY['INSERT','UPDATE','DELETE'])[floor(random()*3 + 1)],
            'user_' || floor(random()*100 + 1),
            CASE WHEN random() > 0.5 THEN jsonb_build_object('id', seq_idx, 'valor', (random()*10000)::INT) ELSE NULL END,
            jsonb_build_object('id', seq_idx, 'novo_valor', (random()*10000)::INT),
            floor(random()*v_last_reserva + 1)::INT,
            'Registro criado automaticamente para auditoria',
            CURRENT_TIMESTAMP - ((random()*365)::INT * INTERVAL '1 day')
        FROM generate_series(1, v_batch_size) AS seq(seq_idx)
        WHERE (batch * v_batch_size + seq_idx) <= v_target;
    END LOOP;
    v_total := v_total + v_target;

    SET session_replication_role = DEFAULT;
    ANALYZE;

    v_fim := clock_timestamp();
    v_duracao := v_fim - v_inicio;

    RETURN format('SUCESSO: %s registros inseridos em %s (lote=%s)', v_total, v_duracao, v_batch_size);
EXCEPTION
    WHEN OTHERS THEN
        SET session_replication_role = DEFAULT;
        RETURN 'ERRO: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- FUNCOES AUXILIARES
-- ============================================================================

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
    RETURN 'Todas as tabelas foram limpas!';
END;
$$ LANGUAGE plpgsql;

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
        relname::TEXT,
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
-- SELECT popular_dados_massivos();        -- modo rapido
-- SELECT popular_dados_massivos(FALSE);   -- modo completo
-- SELECT limpar_todas_tabelas();
-- SELECT * FROM verificar_tamanho_tabelas();
-- ============================================================================

SELECT 'Super SQL criado! Execute: SELECT popular_dados_massivos();' AS status;

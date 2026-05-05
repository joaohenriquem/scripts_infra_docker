-- ============================================================
-- Seed Data: Dados de domínio e massa de teste
-- ============================================================

USE serasa_score_dev;

-- ============================================================
-- Subjects (clientes de teste)
-- ============================================================
INSERT INTO tb_subject (subject_type, name, document_number, document_hash) VALUES
    ('PF', 'João Almeida Cardoso', '123.542.107-00', 'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2'),
    ('PF', 'Catarina Fonseca Lima', '789.891.234-00', 'b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3'),
    ('PF', 'Leonardo Leme Junior', '456.789.123-00', 'c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4'),
    ('PJ', 'Escola Eduka LTDA', '34.797.970/0001-81', 'd4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5'),
    ('PF', 'Felipe Gonçalves', '321.654.987-00', 'e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6'),
    ('PF', 'Maria Silva Santos', '987.123.456-00', 'f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1');

-- ============================================================
-- Score Inquiries (consultas de teste)
-- ============================================================

-- Inquiry 1: EM_PROCESSAMENTO
INSERT INTO tb_score_inquiry (subject_id, inquiry_type, protocol, source_system, requested_at, current_status_id, fee_amount, fee_status, request_payload)
VALUES (1, 'SCORE', 'PROT-2026-0001', 'EFI_EMPRESAS', '2026-04-29 10:30:00.000',
        (SELECT id FROM tb_inquiry_status WHERE code = 'EM_PROCESSAMENTO'),
        16.50, 'BLOQUEADO', '{"cpf": "123.542.107-00"}');

-- Inquiry 2: FALHA (Serasa falhou)
INSERT INTO tb_score_inquiry (subject_id, inquiry_type, protocol, source_system, requested_at, completed_at, current_status_id, fee_amount, fee_status, error_code, error_message, request_payload)
VALUES (2, 'SCORE', 'PROT-2026-0002', 'EFI_EMPRESAS', '2026-04-28 14:00:00.000', '2026-04-28 14:00:05.000',
        (SELECT id FROM tb_inquiry_status WHERE code = 'FALHA'),
        16.50, 'DESBLOQUEADO', 'SERASA_ERROR', 'Falha na comunicação com Serasa', '{"cpf": "789.891.234-00"}');

-- Inquiry 3: DISPONIVEL (sucesso, com score)
INSERT INTO tb_score_inquiry (subject_id, inquiry_type, protocol, source_system, requested_at, completed_at, expires_at, current_status_id, score_value, score_range, fee_amount, fee_status, request_payload, response_payload)
VALUES (3, 'SCORE', 'PROT-2026-0003', 'EFI_EMPRESAS', '2026-04-27 09:00:00.000', '2026-04-27 09:01:00.000', '2026-05-27 09:00:00.000',
        (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'),
        750, 'ALTA', 16.50, 'DEBITADO', '{"cpf": "456.789.123-00"}', '{"score": 750, "range": "ALTA"}');

-- Inquiry 4: DISPONIVEL PJ
INSERT INTO tb_score_inquiry (subject_id, inquiry_type, protocol, source_system, requested_at, completed_at, expires_at, current_status_id, score_value, score_range, fee_amount, fee_status, request_payload, response_payload)
VALUES (4, 'SCORE', 'PROT-2026-0004', 'EFI_EMPRESAS', '2026-04-27 11:00:00.000', '2026-04-27 11:01:00.000', '2026-05-27 11:00:00.000',
        (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'),
        680, 'MEDIA', 16.50, 'DEBITADO', '{"cnpj": "34.797.970/0001-81"}', '{"score": 680, "range": "MEDIA"}');

-- Inquiry 5: DISPONIVEL mas EXPIRADO (expires_at no passado)
INSERT INTO tb_score_inquiry (subject_id, inquiry_type, protocol, source_system, requested_at, completed_at, expires_at, current_status_id, score_value, score_range, fee_amount, fee_status, request_payload, response_payload)
VALUES (5, 'SCORE', 'PROT-2026-0005', 'EFI_EMPRESAS', '2026-02-20 16:45:00.000', '2026-02-20 16:46:00.000', '2026-03-20 16:45:00.000',
        (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'),
        520, 'MEDIA', 16.50, 'DEBITADO', '{"cpf": "321.654.987-00"}', '{"score": 520, "range": "MEDIA"}');

-- Inquiry 6: DISPONIVEL recente
INSERT INTO tb_score_inquiry (subject_id, inquiry_type, protocol, source_system, requested_at, completed_at, expires_at, current_status_id, score_value, score_range, fee_amount, fee_status, request_payload, response_payload)
VALUES (6, 'SCORE', 'PROT-2026-0006', 'EFI_EMPRESAS', '2026-04-25 08:15:00.000', '2026-04-25 08:16:00.000', '2026-05-25 08:15:00.000',
        (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'),
        810, 'ALTA', 16.50, 'DEBITADO', '{"cpf": "987.123.456-00"}', '{"score": 810, "range": "ALTA"}');

-- ============================================================
-- Reports (PDFs gerados)
-- ============================================================
INSERT INTO tb_report (inquiry_id, file_name, mime_type, storage_provider, storage_key, checksum, generated_at)
VALUES
    (3, 'score_45678912300_2026-04-27.pdf', 'application/pdf', 'S3', 'reports/2026/04/score_3.pdf', 'sha256:abc123def456', '2026-04-27 09:01:30.000'),
    (4, 'score_34797970000181_2026-04-27.pdf', 'application/pdf', 'S3', 'reports/2026/04/score_4.pdf', 'sha256:def456ghi789', '2026-04-27 11:01:30.000'),
    (5, 'score_32165498700_2026-02-20.pdf', 'application/pdf', 'S3', 'reports/2026/02/score_5.pdf', 'sha256:ghi789jkl012', '2026-02-20 16:46:30.000'),
    (6, 'score_98712345600_2026-04-25.pdf', 'application/pdf', 'S3', 'reports/2026/04/score_6.pdf', 'sha256:jkl012mno345', '2026-04-25 08:16:30.000');

-- ============================================================
-- Audit Trail (histórico de status)
-- ============================================================
INSERT INTO tb_audit_trail (inquiry_id, status_id, changed_at, detail) VALUES
    -- Inquiry 1
    (1, (SELECT id FROM tb_inquiry_status WHERE code = 'EM_PROCESSAMENTO'), '2026-04-29 10:30:00.000', 'Score inquiry criada'),
    -- Inquiry 2
    (2, (SELECT id FROM tb_inquiry_status WHERE code = 'EM_PROCESSAMENTO'), '2026-04-28 14:00:00.000', 'Score inquiry criada'),
    (2, (SELECT id FROM tb_inquiry_status WHERE code = 'FALHA'), '2026-04-28 14:00:05.000', 'Falha Serasa. Valor desbloqueado.'),
    -- Inquiry 3
    (3, (SELECT id FROM tb_inquiry_status WHERE code = 'EM_PROCESSAMENTO'), '2026-04-27 09:00:00.000', 'Score inquiry criada'),
    (3, (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'), '2026-04-27 09:01:00.000', 'Score recebido com sucesso'),
    -- Inquiry 4
    (4, (SELECT id FROM tb_inquiry_status WHERE code = 'EM_PROCESSAMENTO'), '2026-04-27 11:00:00.000', 'Score inquiry criada'),
    (4, (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'), '2026-04-27 11:01:00.000', 'Score recebido com sucesso'),
    -- Inquiry 5
    (5, (SELECT id FROM tb_inquiry_status WHERE code = 'EM_PROCESSAMENTO'), '2026-02-20 16:45:00.000', 'Score inquiry criada'),
    (5, (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'), '2026-02-20 16:46:00.000', 'Score recebido com sucesso'),
    -- Inquiry 6
    (6, (SELECT id FROM tb_inquiry_status WHERE code = 'EM_PROCESSAMENTO'), '2026-04-25 08:15:00.000', 'Score inquiry criada'),
    (6, (SELECT id FROM tb_inquiry_status WHERE code = 'DISPONIVEL'), '2026-04-25 08:16:00.000', 'Score recebido com sucesso');

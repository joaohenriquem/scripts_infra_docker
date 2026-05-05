-- Schema para serasa_score_dev
USE serasa_score_dev;

CREATE TABLE tb_inquiry_status (
    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(30) NOT NULL,
    description VARCHAR(100) NOT NULL,
    is_terminal TINYINT(1) NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT uq_tb_inquiry_status_code UNIQUE (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_subject (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    subject_type VARCHAR(20) NOT NULL,
    name VARCHAR(200) NOT NULL,
    document_number VARCHAR(20) NOT NULL,
    document_hash CHAR(64) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT uq_tb_subject_document_hash UNIQUE (document_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_score_inquiry (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    subject_id BIGINT UNSIGNED NOT NULL,
    inquiry_type VARCHAR(50) NOT NULL DEFAULT 'SCORE',
    protocol VARCHAR(100) NOT NULL,
    source_system VARCHAR(50) NOT NULL DEFAULT 'EFI_EMPRESAS',
    requested_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    completed_at DATETIME(3) NULL,
    expires_at DATETIME(3) NULL,
    current_status_id SMALLINT UNSIGNED NOT NULL,
    score_value INTEGER NULL,
    score_range VARCHAR(50) NULL,
    fee_amount DECIMAL(12,2) NOT NULL DEFAULT 16.50,
    fee_status VARCHAR(20) NOT NULL DEFAULT 'BLOQUEADO',
    error_code VARCHAR(50) NULL,
    error_message TEXT NULL,
    request_payload JSON NULL,
    response_payload JSON NULL,
    external_request_id VARCHAR(100) NULL,
    request_hash CHAR(64) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT uq_tb_score_inquiry_protocol UNIQUE (protocol),
    CONSTRAINT fk_tb_score_inquiry_subject FOREIGN KEY (subject_id) REFERENCES tb_subject(id),
    CONSTRAINT fk_tb_score_inquiry_status FOREIGN KEY (current_status_id) REFERENCES tb_inquiry_status(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_report (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    inquiry_id BIGINT UNSIGNED NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL DEFAULT 'application/pdf',
    storage_provider VARCHAR(30) NOT NULL DEFAULT 'S3',
    storage_key VARCHAR(500) NOT NULL,
    checksum VARCHAR(128) NULL,
    generated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    downloaded_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT fk_tb_report_inquiry FOREIGN KEY (inquiry_id) REFERENCES tb_score_inquiry(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tb_audit_trail (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    inquiry_id BIGINT UNSIGNED NOT NULL,
    status_id SMALLINT UNSIGNED NULL,
    changed_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    detail TEXT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_tb_audit_trail_inquiry FOREIGN KEY (inquiry_id) REFERENCES tb_score_inquiry(id),
    CONSTRAINT fk_tb_audit_trail_status FOREIGN KEY (status_id) REFERENCES tb_inquiry_status(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seeds
INSERT INTO tb_inquiry_status (code, description, is_terminal) VALUES
    ('EM_PROCESSAMENTO', 'Em processamento', 0),
    ('FALHA', 'Falha', 1),
    ('DISPONIVEL', 'Disponível', 1);

-- Indexes
CREATE INDEX idx_tb_score_inquiry_subject_id ON tb_score_inquiry(subject_id);
CREATE INDEX idx_tb_score_inquiry_requested_at ON tb_score_inquiry(requested_at);
CREATE INDEX idx_tb_report_inquiry_id ON tb_report(inquiry_id);
CREATE INDEX idx_tb_audit_trail_inquiry_id ON tb_audit_trail(inquiry_id);

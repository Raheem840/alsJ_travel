CREATE TABLE audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    user_id UUID,
    action VARCHAR(60) NOT NULL,
    entity_type VARCHAR(60),
    entity_id VARCHAR(64),
    ip_address INET,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

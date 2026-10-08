CREATE TABLE stage_history (
    history_id BIGSERIAL PRIMARY KEY,
    application_id UUID NOT NULL,
    from_stage_id SMALLINT NOT NULL,
    to_stage_id SMALLINT NOT NULL,
    changed_by UUID,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- Phase 1: tables. Foreign keys are added in migrations/relationships.
CREATE TABLE staff_profiles (
    user_id UUID PRIMARY KEY,
    employee_no VARCHAR(50) NOT NULL UNIQUE,
    date_hired DATE NOT NULL
);

CREATE TABLE applications (
    application_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL,
    assigned_agent_id UUID,
    current_stage_id SMALLINT,
    service_type VARCHAR(100) NOT NULL,
    destination VARCHAR(150),
    travel_purpose TEXT,
    preferred_travel_date DATE,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT fk_applications_client
        FOREIGN KEY (client_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_applications_agent
        FOREIGN KEY (assigned_agent_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_applications_stage
        FOREIGN KEY (current_stage_id)
        REFERENCES pipeline_stages(stage_id)
);

-- 006_create_applications.sql
-- Table: applications (central business record) and its two enum types

CREATE TYPE application_service_type AS ENUM ('LABOUR_MIGRATION', 'DOMESTIC_TOURISM');
CREATE TYPE application_status AS ENUM ('ACTIVE', 'CLOSED', 'ARCHIVED', 'CANCELLED');

CREATE TABLE applications (
    application_id        UUID                     PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id             UUID                     NOT NULL,
    assigned_agent_id     UUID,
    current_stage_id      SMALLINT                 NOT NULL,
    service_type          application_service_type NOT NULL,
    destination           VARCHAR(80)              NOT NULL,
    travel_purpose        VARCHAR(120),
    preferred_travel_date DATE                     NOT NULL,
    status                application_status       NOT NULL DEFAULT 'ACTIVE',
    created_at            TIMESTAMPTZ              NOT NULL DEFAULT now(),
    updated_at            TIMESTAMPTZ              NOT NULL DEFAULT now()
);
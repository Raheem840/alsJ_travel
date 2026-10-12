C
REATE TYPE appointment_status AS ENUM ('UPCOMING', 'COMPLETED', 'CANCELLED');

CREATE TABLE schedule_records (
    schedule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL, -- Stored as a plain identifier for now
    staff_id UUID NOT NULL,  -- Stored as a plain identifier for now
    appointment_type VARCHAR(60) NOT NULL,
    scheduled_datetime TIMESTAMPTZ NOT NULL,
    status appointment_status NOT NULL DEFAULT 'UPCOMING'
);

-- Performance Indexes
CREATE INDEX idx_schedule_records_client ON schedule_records(client_id);
CREATE INDEX idx_schedule_records_staff ON schedule_records(staff_id);
CREATE INDEX idx_schedule_records_datetime ON schedule_records(scheduled_datetime);
CREATE TABLE staff_profiles (
    user_id INTEGER PRIMARY KEY,
    employee_no VARCHAR(50) NOT NULL UNIQUE,
    date_hired DATE NOT NULL,

    CONSTRAINT fk_staff_profiles_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

CREATE TABLE applications (
    application_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id INTEGER NOT NULL,
    assigned_agent_id INTEGER,
    current_stage_id INTEGER,
    service_type VARCHAR(100) NOT NULL,
    destination VARCHAR(150),
    travel_purpose TEXT,
    preferred_travel_date DATE,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_applications_client
        FOREIGN KEY (client_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_applications_agent
        FOREIGN KEY (assigned_agent_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_applications_stage
        FOREIGN KEY (current_stage_id)
        REFERENCES application_stages(stage_id)
);
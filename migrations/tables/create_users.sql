-- 003_create_users.sql
-- Table: users (one account per person: identity, login and assigned role)
-- Source: data dictionary, "users"
-- Note: role_id references roles(role_id). That foreign key (R01) is added in Phase 2.

CREATE TABLE users (
    user_id       UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name     VARCHAR(120) NOT NULL,
    email         VARCHAR(120) UNIQUE,
    phone         VARCHAR(20)  UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id       SMALLINT     NOT NULL,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);

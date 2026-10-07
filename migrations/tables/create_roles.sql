-- 001_create_roles.sql
-- Table: roles (lookup of access roles; drives role-based access control)
-- Source: data dictionary, "roles"

CREATE TABLE roles (
    role_id   SMALLSERIAL PRIMARY KEY,
    role_name VARCHAR(30) UNIQUE NOT NULL
);

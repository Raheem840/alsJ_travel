-- 013_add_fk_r01_r02_r03.sql
-- Relationships R01, R02, R03 (PDF section 05, page 20)

-- R01: roles (1..1) -> users.role_id (0..*)
-- Every user has exactly one role; a role can belong to many users.
ALTER TABLE users
    ADD CONSTRAINT fk_users_role_id
    FOREIGN KEY (role_id) REFERENCES roles (role_id)
    ON DELETE RESTRICT;

-- R02: users (1..1) -> client_profiles.user_id (0..1)
-- Each client profile belongs to one user (shared primary key and foreign key).
ALTER TABLE client_profiles
    ADD CONSTRAINT fk_client_profiles_user_id
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE RESTRICT;

-- R03: users (1..1) -> staff_profiles.user_id (0..1)
-- Each staff profile belongs to one user (shared primary key and foreign key).
ALTER TABLE staff_profiles
    ADD CONSTRAINT fk_staff_profiles_user_id
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE RESTRICT;

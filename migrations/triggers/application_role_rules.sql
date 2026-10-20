-- 1. Create Permissions Table
CREATE TABLE IF NOT EXISTS permissions (
    id SERIAL PRIMARY KEY,
    permission_name VARCHAR(100) UNIQUE NOT NULL, -- e.g., 'documents:verify', 'users:manage'
    description TEXT
);

-- 2. Create Role-to-Permission Mapping Table
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id INT REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- 3. Seed Basic Permissions
INSERT INTO permissions (permission_name, description) VALUES
('users:manage', 'Ability to create, update, or deactivate users'),
('documents:verify', 'Ability to approve or reject submitted documents'),
('payments:refund', 'Ability to initiate payment refunds')
ON CONFLICT (permission_name) DO NOTHING;

CREATE OR REPLACE FUNCTION fn_has_permission(
    p_user_id INT,
    p_permission_name VARCHAR
) RETURNS BOOLEAN AS $$
DECLARE
    has_perm BOOLEAN := FALSE;
BEGIN
    SELECT EXISTS (
        SELECT 1 
        FROM users u
        JOIN role_permissions rp ON u.role_id = rp.role_id
        JOIN permissions p ON rp.permission_id = p.id
        WHERE u.id = p_user_id 
          AND u.is_active = TRUE
          AND p.permission_name = p_permission_name
    ) INTO has_perm;

    RETURN has_perm;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
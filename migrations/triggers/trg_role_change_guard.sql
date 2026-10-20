-- 1. Create the Guard Function
CREATE OR REPLACE FUNCTION fn_role_change_guard()
RETURNS TRIGGER AS $$
DECLARE
    super_admin_role_id INT;
    super_admin_count INT;
    current_acting_user_id INT;
BEGIN
    -- Get the ID for 'Super Admin' dynamically
    SELECT id INTO super_admin_role_id FROM roles WHERE role_name = 'Super Admin';

    -- Safely grab the current user ID passed from the backend session context
    BEGIN
        current_acting_user_id := current_setting('app.current_user_id', true)::INT;
    EXCEPTION WHEN OTHERS THEN
        current_acting_user_id := NULL;
    END;

    -- Trigger only runs if role or active status is actually changing
    IF OLD.role_id IS DISTINCT FROM NEW.role_id OR OLD.is_active IS DISTINCT FROM NEW.is_active THEN

        -- RULE A: Prevent Self-Demotion / Self-Deactivation
        IF current_acting_user_id IS NOT NULL AND current_acting_user_id = OLD.id THEN
            RAISE EXCEPTION 'Security Violation: Users cannot modify their own role or active status.';
        END IF;

        -- RULE B: Prevent Removing or Deactivating the Last Super Admin
        IF OLD.role_id = super_admin_role_id AND (NEW.role_id <> super_admin_role_id OR NEW.is_active = FALSE) THEN
            SELECT COUNT(*) INTO super_admin_count 
            FROM users 
            WHERE role_id = super_admin_role_id AND is_active = TRUE;

            IF super_admin_count <= 1 THEN
                RAISE EXCEPTION 'Security Violation: Cannot demote or deactivate the last remaining Super Admin.';
            END IF;
        END IF;
        
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Attach the Trigger to the Users Table
DROP TRIGGER IF EXISTS trg_enforce_role_guard ON users;

CREATE TRIGGER trg_enforce_role_guard
    BEFORE UPDATE OF role_id, is_active ON users
    FOR EACH ROW
    EXECUTE FUNCTION fn_role_change_guard();
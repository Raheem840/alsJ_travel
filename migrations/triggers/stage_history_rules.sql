-- =========================================================================
-- Description: Enforces that only the initial history row can have a NULL 
--              from_stage_id, and automatically creates the initial history 
--              row upon application registration[cite: 4, 10].
-- =========================================================================

-- 1. Validation trigger function for stage_history
CREATE OR REPLACE FUNCTION trg_fn_validate_stage_history_from()
RETURNS TRIGGER AS $$
DECLARE
    row_count INT;
BEGIN
    -- Check how many history rows already exist for this application
    SELECT COUNT(*) INTO row_count
    FROM stage_history
    WHERE application_id = NEW.application_id;

    IF row_count = 0 THEN
        -- The first row must have a NULL from_stage_id[cite: 4, 10]
        IF NEW.from_stage_id IS NOT NULL THEN
            RAISE EXCEPTION 'The initial stage history row for an application must have a NULL from_stage_id.';
        END IF;
    ELSE
        -- Subsequent rows cannot have a NULL from_stage_id[cite: 4, 10]
        IF NEW.from_stage_id IS NULL THEN
            RAISE EXCEPTION 'Only the initial stage history row may have a NULL from_stage_id.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply validation trigger before insert on stage_history
CREATE TRIGGER trg_stage_history_validate_from
    BEFORE INSERT ON stage_history
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_validate_stage_history_from();


-- 2. Trigger function to automatically create the initial history row on application creation[cite: 4, 10]
CREATE OR REPLACE FUNCTION trg_fn_create_initial_stage_history()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO stage_history (application_id, from_stage_id, to_stage_id, changed_by)
    VALUES (NEW.application_id, NULL, NEW.current_stage_id, NULL);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger after insert on applications
CREATE TRIGGER trg_applications_initial_history
    AFTER INSERT ON applications
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_create_initial_stage_history();
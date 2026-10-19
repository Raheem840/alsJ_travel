-- 043_create_function_change_stage.sql
-- Routine: move an application to a new pipeline stage and record it in stage_history,
-- in one transaction, one application at a time.
-- Source: PDF p.4 ("Payment and pipeline rules"): update current_stage_id and insert
--         stage_history in one transaction; later rows use the previous current stage;
--         serialize changes per application.

CREATE FUNCTION change_stage(
    p_application_id UUID,
    p_new_stage_id   INTEGER,                -- INTEGER so callers can write a plain 2; it is stored as SMALLINT
    p_changed_by     UUID DEFAULT NULL      -- NULL means a system-triggered change (PDF p.10)
)
RETURNS BIGINT                              -- the history_id of the new stage_history row
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_stage_id SMALLINT;
    v_history_id   BIGINT;
BEGIN
    -- Lock this application's row. A second call for the same application waits here
    -- until the first one finishes, so changes are serialized per application.
    SELECT current_stage_id
      INTO v_old_stage_id
      FROM applications
     WHERE application_id = p_application_id
       FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'application % does not exist', p_application_id;
    END IF;

    UPDATE applications
       SET current_stage_id = p_new_stage_id
     WHERE application_id = p_application_id;

    INSERT INTO stage_history (application_id, from_stage_id, to_stage_id, changed_by)
    VALUES (p_application_id, v_old_stage_id, p_new_stage_id, p_changed_by)
    RETURNING history_id INTO v_history_id;

    RETURN v_history_id;
END;
$$;

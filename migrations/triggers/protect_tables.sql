-- =========================================================================
-- Description: Refuses UPDATE and DELETE on stage_history, audit_logs, 
--              and pipeline_stages while allowing inserts[cite: 4, 6].
-- =========================================================================

-- Create the universal protection function
CREATE OR REPLACE FUNCTION prevent_modifications()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Updates and deletions are not permitted on table %.', TG_TABLE_NAME;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Protect stage_history
CREATE TRIGGER trg_protect_stage_history
    BEFORE UPDATE OR DELETE ON stage_history
    FOR EACH ROW
    EXECUTE FUNCTION prevent_modifications();

-- Protect audit_logs
CREATE TRIGGER trg_protect_audit_logs
    BEFORE UPDATE OR DELETE ON audit_logs
    FOR EACH ROW
    EXECUTE FUNCTION prevent_modifications();

-- Protect pipeline_stages
CREATE TRIGGER trg_protect_pipeline_stages
    BEFORE UPDATE OR DELETE ON pipeline_stages
    FOR EACH ROW
    EXECUTE FUNCTION prevent_modifications();
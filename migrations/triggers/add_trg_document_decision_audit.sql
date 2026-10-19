-- Document decision audit trail:
-- when a document becomes VERIFIED or REJECTED, write a row in audit_logs
-- BEFORE the document row changes (same transaction, so both succeed or both fail).

CREATE OR REPLACE FUNCTION fn_audit_document_decision()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_logs (user_id, action, entity_type, entity_id)
    VALUES (
        NEW.verified_by,                              -- NULL = system
        'DOCUMENT_' || NEW.verification_status::text, -- DOCUMENT_VERIFIED / DOCUMENT_REJECTED
        'documents',
        NEW.document_id::text
    );
    RETURN NEW;  -- required in a BEFORE trigger, or the update is cancelled
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_documents_decision_audit
    BEFORE UPDATE ON documents
    FOR EACH ROW
    WHEN (OLD.verification_status IS DISTINCT FROM NEW.verification_status
          AND NEW.verification_status IN ('VERIFIED', 'REJECTED'))
    EXECUTE FUNCTION fn_audit_document_decision();
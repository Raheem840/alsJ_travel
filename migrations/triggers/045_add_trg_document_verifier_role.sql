-- Your Phase 3 task: a document verifier must be a Field Agent or Data Entry Staff.
-- Apply after users, roles and documents exist. No fixed numeric role IDs.
BEGIN;
CREATE OR REPLACE FUNCTION public.fn_check_document_verifier_role()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    -- PENDING documents have no verifier; the existing CHECK enforces that rule.
    IF NEW.verified_by IS NOT NULL THEN
        PERFORM 1
        FROM public.users AS u
        JOIN public.roles AS r ON r.role_id = u.role_id
        WHERE u.user_id = NEW.verified_by
          AND r.role_name IN ('Field Agent', 'Data Entry Staff')
        FOR SHARE OF u, r;

        IF NOT FOUND THEN
            RAISE EXCEPTION USING
                ERRCODE = '23514',
                CONSTRAINT = 'documents_verifier_role',
                MESSAGE = 'Document verifier must be a Field Agent or Data Entry Staff';
        END IF;
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_documents_verifier_role ON public.documents;
CREATE TRIGGER trg_documents_verifier_role
    BEFORE INSERT OR UPDATE ON public.documents
    FOR EACH ROW EXECUTE FUNCTION public.fn_check_document_verifier_role();
COMMIT;

-- Run AFTER tables, relationships, triggers and chk_documents_pending.sql.
-- Compatible with pgAdmin Query Tool and psql. Run the ENTIRE file.
-- Uses real tables and active constraints/triggers; all test rows are rolled back.
-- If execution stops with an error, run ROLLBACK before continuing.
BEGIN;

DO $$
DECLARE
    test_role SMALLINT;
    test_client_role SMALLINT;
    test_client UUID;
    test_user UUID;
    test_application UUID;
    test_document UUID;
    test_token TEXT := replace(gen_random_uuid()::text, '-', '');
    test_case INTEGER;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conrelid = 'public.documents'::regclass
          AND conname = 'chk_documents_pending'
          AND contype = 'c' AND convalidated
    ) THEN
        RAISE EXCEPTION 'Apply chk_constraints/chk_documents_pending.sql first';
    END IF;

    INSERT INTO public.roles (role_name) VALUES ('Field Agent'), ('Client')
    ON CONFLICT (role_name) DO NOTHING;
    SELECT role_id INTO test_role FROM public.roles WHERE role_name = 'Field Agent';
    SELECT role_id INTO test_client_role FROM public.roles WHERE role_name = 'Client';

    INSERT INTO public.users (full_name, email, phone, password_hash, role_id)
    VALUES ('Pending integration test', test_token || '@example.invalid',
            left(test_token, 20), 'TEST_ONLY_NOT_A_REAL_PASSWORD', test_role)
    RETURNING user_id INTO test_user;

    INSERT INTO public.staff_profiles (user_id, employee_no, date_hired)
    VALUES (test_user, test_token, CURRENT_DATE);
    INSERT INTO public.users (full_name, phone, password_hash, role_id)
    VALUES ('Pending test client', left(test_token, 18) || 'CL', 'TEST_ONLY', test_client_role)
    RETURNING user_id INTO test_client;
    INSERT INTO public.client_profiles (user_id, national_id)
    VALUES (test_client, left(test_token, 30));

    INSERT INTO public.applications (client_id, service_type, status)
    VALUES (test_client, 'Integration test', 'PENDING')
    RETURNING application_id INTO test_application;

    -- A valid PENDING document must succeed with the default status.
    INSERT INTO public.documents
        (application_id, document_type, file_path, file_size_bytes)
    VALUES (test_application, 'PASSPORT', 'integration-test-only.pdf', 100)
    RETURNING document_id INTO test_document;

    -- Each forbidden field must independently cause a CHECK violation.
    FOR test_case IN 1..3 LOOP
        BEGIN
            UPDATE public.documents
            SET verified_by = CASE WHEN test_case = 1 THEN test_user ELSE NULL END,
                verified_at = CASE WHEN test_case = 2 THEN now() ELSE NULL END,
                rejection_reason = CASE WHEN test_case = 3 THEN 'Invalid pending detail' ELSE NULL END
            WHERE document_id = test_document;

            RAISE EXCEPTION 'FAIL: invalid PENDING case % was accepted', test_case;
        EXCEPTION WHEN check_violation THEN
            RAISE NOTICE 'PASS: invalid PENDING case % rejected', test_case;
        END;
    END LOOP;

    -- Existing VERIFIED rules and any decision-audit trigger must still work.
    UPDATE public.documents
    SET verification_status = 'VERIFIED', verified_by = test_user,
        verified_at = now(), rejection_reason = NULL
    WHERE document_id = test_document;

    -- Existing REJECTED rules and any decision-audit trigger must still work.
    UPDATE public.documents
    SET verification_status = 'REJECTED', rejection_reason = 'Test rejection'
    WHERE document_id = test_document;

    RAISE NOTICE 'PASS: valid PENDING, VERIFIED and REJECTED states accepted';
    RAISE NOTICE 'PASS: Documents Pending integration checks completed; test rows will be rolled back';
END;
$$;

ROLLBACK;


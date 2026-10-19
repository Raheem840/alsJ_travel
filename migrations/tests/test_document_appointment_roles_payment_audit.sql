-- Your Phase 3 checks only. Run the WHOLE file after the three new triggers.
-- Real tables/constraints/triggers; fixture rows and audit entries are rolled back.
-- If execution stops on an error, run ROLLBACK; before continuing.
BEGIN;
CREATE TEMP TABLE phase3_results (test TEXT, passed BOOLEAN) ON COMMIT DROP;

CREATE FUNCTION pg_temp.expect_role_failure(label TEXT, statement TEXT)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        EXECUTE statement;
    EXCEPTION WHEN check_violation THEN
        INSERT INTO phase3_results VALUES (label, TRUE);
        RETURN;
    END;
    INSERT INTO phase3_results VALUES (label, FALSE);
END;
$$;

DO $$
DECLARE
    token TEXT := replace(gen_random_uuid()::text, '-', '');
    client_role SMALLINT;
    agent_role SMALLINT;
    entry_role SMALLINT;
    other_role SMALLINT;
    client_user UUID;
    agent_user UUID;
    entry_user UUID;
    other_user UUID;
    no_profile_client UUID;
    no_profile_staff UUID;
    app UUID;
    doc UUID;
    appointment UUID;
    payment UUID;
    audit_count BIGINT;
BEGIN
    INSERT INTO public.roles (role_name) VALUES ('Client'), ('Field Agent'), ('Data Entry Staff')
    ON CONFLICT (role_name) DO NOTHING;
    SELECT role_id INTO client_role FROM public.roles WHERE role_name = 'Client';
    SELECT role_id INTO agent_role FROM public.roles WHERE role_name = 'Field Agent';
    SELECT role_id INTO entry_role FROM public.roles WHERE role_name = 'Data Entry Staff';
    INSERT INTO public.roles (role_name) VALUES ('Test_' || left(token, 20)) RETURNING role_id INTO other_role;

    INSERT INTO public.users (full_name, phone, password_hash, role_id)
    VALUES ('Test client', left(token, 18) || '01', 'TEST_ONLY', client_role) RETURNING user_id INTO client_user;
    INSERT INTO public.users (full_name, phone, password_hash, role_id)
    VALUES ('Test agent', left(token, 18) || '02', 'TEST_ONLY', agent_role) RETURNING user_id INTO agent_user;
    INSERT INTO public.users (full_name, phone, password_hash, role_id)
    VALUES ('Test entry staff', left(token, 18) || '03', 'TEST_ONLY', entry_role) RETURNING user_id INTO entry_user;
    INSERT INTO public.users (full_name, phone, password_hash, role_id)
    VALUES ('Test other', left(token, 18) || '04', 'TEST_ONLY', other_role) RETURNING user_id INTO other_user;
    INSERT INTO public.users (full_name, phone, password_hash, role_id)
    VALUES ('Test client without profile', left(token, 18) || '05', 'TEST_ONLY', client_role) RETURNING user_id INTO no_profile_client;
    INSERT INTO public.users (full_name, phone, password_hash, role_id)
    VALUES ('Test staff without profile', left(token, 18) || '06', 'TEST_ONLY', agent_role) RETURNING user_id INTO no_profile_staff;
    INSERT INTO public.client_profiles (user_id, national_id) VALUES (client_user, left(token, 30));
    INSERT INTO public.staff_profiles (user_id, employee_no, date_hired)
    VALUES (agent_user, token || 'A', CURRENT_DATE), (entry_user, token || 'E', CURRENT_DATE);
    INSERT INTO public.applications (client_id, service_type, status)
    VALUES (client_user, 'Test', 'PENDING') RETURNING application_id INTO app;

    INSERT INTO public.documents (application_id, document_type, file_path, file_size_bytes)
    VALUES (app, 'PASSPORT', 'test.pdf', 100) RETURNING document_id INTO doc;
    INSERT INTO phase3_results VALUES ('PENDING document needs no verifier', TRUE);
    UPDATE public.documents SET verification_status = 'VERIFIED', verified_by = agent_user, verified_at = now() WHERE document_id = doc;
    INSERT INTO phase3_results VALUES ('Field Agent may verify', TRUE);
    UPDATE public.documents SET verification_status = 'REJECTED', verified_by = entry_user, rejection_reason = 'Test' WHERE document_id = doc;
    INSERT INTO phase3_results VALUES ('Data Entry Staff may reject', TRUE);
    PERFORM pg_temp.expect_role_failure('Other role cannot verify on update',
        format('UPDATE public.documents SET verified_by = %L WHERE document_id = %L', other_user, doc));
    PERFORM pg_temp.expect_role_failure('Client cannot verify on insert',
        format('INSERT INTO public.documents (application_id, document_type, file_path, file_size_bytes, verification_status, verified_by, verified_at) VALUES (%L, ''PASSPORT'', ''test.pdf'', 100, ''VERIFIED'', %L, now())', app, client_user));

    INSERT INTO public.schedule_records (client_id, staff_id, appointment_type, scheduled_datetime)
    VALUES (client_user, agent_user, 'Test', now()) RETURNING schedule_id INTO appointment;
    INSERT INTO phase3_results VALUES ('Client profile and staff profile accepted', TRUE);
    UPDATE public.schedule_records SET staff_id = entry_user WHERE schedule_id = appointment;
    INSERT INTO phase3_results VALUES ('Data Entry Staff with staff profile accepted', TRUE);
    PERFORM pg_temp.expect_role_failure('Appointment client requires Client role',
        format('UPDATE public.schedule_records SET client_id = %L WHERE schedule_id = %L', agent_user, appointment));
    PERFORM pg_temp.expect_role_failure('Appointment Client requires client profile',
        format('UPDATE public.schedule_records SET client_id = %L WHERE schedule_id = %L', no_profile_client, appointment));
    PERFORM pg_temp.expect_role_failure('Appointment staff requires staff profile',
        format('UPDATE public.schedule_records SET staff_id = %L WHERE schedule_id = %L', no_profile_staff, appointment));
    PERFORM pg_temp.expect_role_failure('Invalid appointment insert rejected',
        format('INSERT INTO public.schedule_records (client_id, staff_id, appointment_type, scheduled_datetime) VALUES (%L, %L, ''Test'', now())', no_profile_client, agent_user));

    INSERT INTO public.payments (application_id, amount, payment_method, payer_phone)
    VALUES (app, 100, 'MTN_MOMO', '0700000000') RETURNING payment_id INTO payment;
    SELECT count(*) INTO audit_count FROM public.audit_logs WHERE entity_type = 'payments' AND entity_id = payment::text;
    INSERT INTO phase3_results VALUES ('Payment insert is not a status change', audit_count = 0);
    UPDATE public.payments SET status = 'PENDING' WHERE payment_id = payment;
    SELECT count(*) INTO audit_count FROM public.audit_logs WHERE entity_type = 'payments' AND entity_id = payment::text;
    INSERT INTO phase3_results VALUES ('Unchanged payment status produces no audit', audit_count = 0);
    UPDATE public.payments SET status = 'COMPLETED', completed_at = now(), transaction_reference = token WHERE payment_id = payment;
    INSERT INTO phase3_results SELECT 'Completion logs old/new status once', count(*) = 1
      FROM public.audit_logs WHERE entity_type = 'payments' AND entity_id = payment::text AND action = 'PAYMENT_PENDING_TO_COMPLETED' AND user_id IS NULL;
    UPDATE public.payments SET amount = 200 WHERE payment_id = payment;
    SELECT count(*) INTO audit_count FROM public.audit_logs WHERE entity_type = 'payments' AND entity_id = payment::text;
    INSERT INTO phase3_results VALUES ('Other payment updates produce no audit', audit_count = 1);
    UPDATE public.payments SET status = 'REFUNDED' WHERE payment_id = payment;
    INSERT INTO phase3_results SELECT 'Refund logs old/new status once', count(*) = 1
      FROM public.audit_logs WHERE entity_type = 'payments' AND entity_id = payment::text AND action = 'PAYMENT_COMPLETED_TO_REFUNDED';
    BEGIN
        UPDATE public.payments SET status = 'FAILED', completed_at = NULL WHERE payment_id = payment;
        RAISE EXCEPTION USING ERRCODE = 'ZX001', MESSAGE = 'Test transaction rollback';
    EXCEPTION WHEN SQLSTATE 'ZX001' THEN NULL;
    END;
    SELECT count(*) INTO audit_count FROM public.audit_logs WHERE entity_type = 'payments' AND entity_id = payment::text;
    INSERT INTO phase3_results VALUES ('Rolled-back status change leaves no audit', audit_count = 2);
END;
$$;

TABLE phase3_results;
DO $$
DECLARE failures TEXT;
BEGIN
    SELECT string_agg(test, '; ') INTO failures FROM phase3_results WHERE NOT passed;
    IF failures IS NOT NULL THEN RAISE EXCEPTION 'FAIL: %', failures; END IF;
    RAISE NOTICE 'PASS: all % Phase 3 checks passed; rolling back test data', (SELECT count(*) FROM phase3_results);
END;
$$;
ROLLBACK;


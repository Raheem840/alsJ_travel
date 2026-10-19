-- Your Phase 3 task: Client + client profile; appointment staff needs a staff profile.
-- Apply after users, roles, profiles and schedule_records exist.
BEGIN;
CREATE OR REPLACE FUNCTION public.fn_check_appointment_participant_roles()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    PERFORM 1
    FROM public.users AS u
    JOIN public.roles AS r ON r.role_id = u.role_id
    JOIN public.client_profiles AS cp ON cp.user_id = u.user_id
    WHERE u.user_id = NEW.client_id AND r.role_name = 'Client'
    FOR SHARE OF u, r, cp;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514',
            CONSTRAINT = 'appointments_client_role_profile',
            MESSAGE = 'Appointment client must be a Client with a client profile';
    END IF;

    -- The assignment requires a staff profile here, not a specific staff role.
    PERFORM 1
    FROM public.staff_profiles AS sp
    JOIN public.users AS u ON u.user_id = sp.user_id
    WHERE sp.user_id = NEW.staff_id
    FOR SHARE OF sp, u;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING
            ERRCODE = '23514',
            CONSTRAINT = 'appointments_staff_profile',
            MESSAGE = 'Appointment staff member must have a staff profile';
    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_appointments_participant_roles ON public.schedule_records;
CREATE TRIGGER trg_appointments_participant_roles
    BEFORE INSERT OR UPDATE ON public.schedule_records
    FOR EACH ROW EXECUTE FUNCTION public.fn_check_appointment_participant_roles();
COMMIT;

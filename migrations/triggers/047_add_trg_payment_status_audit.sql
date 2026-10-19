-- Your Phase 3 task: audit EVERY actual payment status change, in the same transaction.
-- Apply after payments and audit_logs exist. INSERT is not a status change.
BEGIN;
CREATE OR REPLACE FUNCTION public.fn_audit_payment_status_change()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    -- Payments has no actor column. NULL denotes a system/unspecified actor;
    -- the application's client is NOT necessarily the person changing the payment.
    INSERT INTO public.audit_logs (user_id, action, entity_type, entity_id)
    VALUES (NULL,
            'PAYMENT_' || OLD.status::text || '_TO_' || NEW.status::text,
            'payments', NEW.payment_id::text);
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_payments_status_audit ON public.payments;
CREATE TRIGGER trg_payments_status_audit
    AFTER UPDATE ON public.payments
    FOR EACH ROW
    WHEN (OLD.status IS DISTINCT FROM NEW.status)
    EXECUTE FUNCTION public.fn_audit_payment_status_change();
COMMIT;

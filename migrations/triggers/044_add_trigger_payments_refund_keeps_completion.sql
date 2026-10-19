-- 044_add_trigger_payments_refund_keeps_completion.sql
-- Rule: a refund keeps the original completion time of the payment.
-- Source: PDF p.4 ("A refund retains the original completion timestamp")
--         and p.9 (payments.completed_at: retains original payment completion time).

CREATE FUNCTION payments_refund_keeps_completion()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IN ('COMPLETED', 'REFUNDED')
       AND NEW.status = 'REFUNDED'
       AND NEW.completed_at IS DISTINCT FROM OLD.completed_at THEN
        RAISE EXCEPTION 'payment %: a refund must keep the original completion time', OLD.payment_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_payments_refund_keeps_completion
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION payments_refund_keeps_completion();

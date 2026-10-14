-- _add_check_payments_completed_refunded_need_completion.sql
-- Rule: a COMPLETED or REFUNDED payment must have a completion time.
ALTER TABLE payments
    ADD CONSTRAINT chk_payments_completed_refunded_need_completion
    CHECK (status NOT IN ('COMPLETED', 'REFUNDED') OR completed_at IS NOT NULL);

-- add_check_payments_completed_after_initiated.sql
-- Rule: a payment cannot be completed before it was initiated.
ALTER TABLE payments
    ADD CONSTRAINT chk_payments_completed_after_initiated
    CHECK (completed_at IS NULL OR completed_at >= initiated_at);
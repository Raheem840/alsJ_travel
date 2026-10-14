-- CHK 1: payment amount must be above zero
--- already done in table definition 

-- CHK 2: pending or failed payments must have no completion time
ALTER TABLE payments
    ADD CONSTRAINT chk_payments_pending_failed_no_completion
    CHECK (status NOT IN ('PENDING', 'FAILED') OR completed_at IS NULL);
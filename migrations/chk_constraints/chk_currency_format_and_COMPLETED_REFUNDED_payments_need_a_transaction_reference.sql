-- =========================================================================

-- Description: Adds currency format, transaction reference, and completion 
--              timestamp validation check constraints to the payments table.
-- =========================================================================

-- 1. Check constraint to ensure currency format is a valid 3-letter uppercase code (e.g., 'UGX')
ALTER TABLE payments
    ADD CONSTRAINT chk_currency_format 
    CHECK (currency ~ '^[A-Z]{3}$');

-- 2. Check constraint ensuring COMPLETED and REFUNDED payments have a transaction reference
ALTER TABLE payments
    ADD CONSTRAINT chk_transaction_reference_required 
    CHECK (
        status NOT IN ('COMPLETED', 'REFUNDED') OR transaction_reference IS NOT NULL
    );

-- 3. Check constraint ensuring completion timestamps align with finalized or refunded statuses[cite: 9]
ALTER TABLE payments
    ADD CONSTRAINT chk_completed_at_status 
    CHECK (
        (status IN ('COMPLETED', 'REFUNDED') AND completed_at IS NOT NULL) OR
        (status IN ('PENDING', 'FAILED') AND completed_at IS NULL)
    );
-- Create ENUM types for payments
CREATE TYPE payment_method_enum AS ENUM ('MTN_MOMO', 'AIRTEL_MONEY');
CREATE TYPE payment_status_enum AS ENUM ('PENDING', 'COMPLETED', 'FAILED', 'REFUNDED');

-- Create payments table
CREATE TABLE payments (
    payment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    currency CHAR(3) NOT NULL DEFAULT 'UGX',
    payment_method payment_method_enum NOT NULL,
    payer_phone VARCHAR(20) NOT NULL,
    transaction_reference VARCHAR(60) UNIQUE,
    status payment_status_enum NOT NULL DEFAULT 'PENDING',
    initiated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
    
/** -- Foreign Key constraint
    CONSTRAINT fk_payments_application 
        FOREIGN KEY (application_id) 
        REFERENCES applications(application_id),
        
    -- Conditional constraint: completed_at is required for COMPLETED or REFUNDED, NULL for PENDING or FAILED
    CONSTRAINT chk_completed_at_status CHECK (
        (status IN ('COMPLETED', 'REFUNDED') AND completed_at IS NOT NULL) OR
        (status IN ('PENDING', 'FAILED') AND completed_at IS NULL)
**/       
);
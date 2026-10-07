CREATE TYPE document_type_enum AS ENUM ('PASSPORT', 'NATIONAL_ID', 'TRAVEL_DECLARATION');
CREATE TYPE verification_status_enum AS ENUM ('PENDING', 'VERIFIED', 'REJECTED');

CREATE TABLE documents (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    application_id UUID NOT NULL,
    document_type document_type_enum NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    file_size_bytes INTEGER NOT NULL,
    verification_status verification_status_enum NOT NULL DEFAULT 'PENDING',
    verified_by UUID NULL,
    verified_at TIMESTAMPTZ NULL,
    rejection_reason VARCHAR(500) NULL,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_file_size 
        CHECK (file_size_bytes BETWEEN 1 AND 5242880),

    CONSTRAINT chk_document_verification_rules 
        CHECK (
            (verification_status = 'PENDING' AND verified_by IS NULL AND verified_at IS NULL AND rejection_reason IS NULL) OR
            (verification_status = 'VERIFIED' AND verified_by IS NOT NULL AND verified_at IS NOT NULL AND rejection_reason IS NULL) OR
            (verification_status = 'REJECTED' AND verified_by IS NOT NULL AND verified_at IS NOT NULL AND rejection_reason IS NOT NULL AND trim(rejection_reason) <> '')
        )
);
-- =====================================================
-- Constraints & Rules: documents table
-- =====================================================

-- 1. Enforce the 5 MiB file size limit (between 1 byte and 5,242,880 bytes)
ALTER TABLE documents
ADD CONSTRAINT chk_file_size_limit 
CHECK (file_size_bytes BETWEEN 1 AND 5242880);

-- 2. Enforce PENDING, VERIFIED, and REJECTED state conditional rules
ALTER TABLE documents
ADD CONSTRAINT chk_document_verification_rules CHECK (
    (
        verification_status = 'PENDING' 
        AND verified_by IS NULL 
        AND verified_at IS NULL 
        AND rejection_reason IS NULL
    )
    OR
    (
        verification_status = 'VERIFIED' 
        AND verified_by IS NOT NULL 
        AND verified_at IS NOT NULL 
        AND rejection_reason IS NULL
    )
    OR
    (
        verification_status = 'REJECTED' 
        AND verified_by IS NOT NULL 
        AND verified_at IS NOT NULL 
        AND rejection_reason IS NOT NULL 
        AND TRIM(rejection_reason) <> ''
    )
);
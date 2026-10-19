-- Pending documents must not contain verification details.
ALTER TABLE public.documents
    ADD CONSTRAINT chk_documents_pending
    CHECK (
        verification_status <> 'PENDING'
        OR (
            verified_by IS NULL
            AND verified_at IS NULL
            AND rejection_reason IS NULL
        )
    );

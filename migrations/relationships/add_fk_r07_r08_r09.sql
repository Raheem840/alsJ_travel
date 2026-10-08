-- Relationships R07, R08, R09.
-- R07/R08 numbering follows the documents/application/verifier interpretation of the ERD.
-- Run after users, applications, documents and payments have been created.
-- applications.application_id must be UUID.

BEGIN;

-- R07: Each document belongs to an existing application.
ALTER TABLE documents
    ADD CONSTRAINT fk_documents_application_id
    FOREIGN KEY (application_id) REFERENCES applications (application_id)
    ON DELETE RESTRICT;

-- R08: A verifier, when supplied, must be an existing user.
-- verified_by remains nullable for pending documents.
ALTER TABLE documents
    ADD CONSTRAINT fk_documents_verified_by
    FOREIGN KEY (verified_by) REFERENCES users (user_id)
    ON DELETE RESTRICT;

-- R09: Each payment belongs to an existing application.
ALTER TABLE payments
    ADD CONSTRAINT fk_payments_application_id
    FOREIGN KEY (application_id) REFERENCES applications (application_id)
    ON DELETE RESTRICT;

COMMIT;


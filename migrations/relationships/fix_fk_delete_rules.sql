-- 031_fix_fk_delete_rules.sql
-- Makes R10, R11, R16, R17 and R18 restrict deletion, as the PDF asks (page 4:
-- "Protect stage_history and audit_logs ... restrict deletion of related records").
-- Use this file only if the original relationship files were already merged and run.
-- If they were not merged yet, change ON DELETE in the original files instead.

BEGIN;

-- R10: stage_history.application_id -> applications
ALTER TABLE stage_history DROP CONSTRAINT fk_stage_history_application;
ALTER TABLE stage_history
    ADD CONSTRAINT fk_stage_history_application
    FOREIGN KEY (application_id) REFERENCES applications (application_id)
    ON DELETE RESTRICT;

-- R11: stage_history.from_stage_id -> pipeline_stages
ALTER TABLE stage_history DROP CONSTRAINT fk_stage_history_from_stage;
ALTER TABLE stage_history
    ADD CONSTRAINT fk_stage_history_from_stage
    FOREIGN KEY (from_stage_id) REFERENCES pipeline_stages (stage_id)
    ON DELETE RESTRICT;

-- R16: notifications.user_id -> users
ALTER TABLE notifications DROP CONSTRAINT fk_notifications_user;
ALTER TABLE notifications
    ADD CONSTRAINT fk_notifications_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE RESTRICT;

-- R17: notifications.application_id -> applications
ALTER TABLE notifications DROP CONSTRAINT fk_notifications_application;
ALTER TABLE notifications
    ADD CONSTRAINT fk_notifications_application
    FOREIGN KEY (application_id) REFERENCES applications (application_id)
    ON DELETE RESTRICT;

-- R18: audit_logs.user_id -> users
ALTER TABLE audit_logs DROP CONSTRAINT fk_audit_logs_user;
ALTER TABLE audit_logs
    ADD CONSTRAINT fk_audit_logs_user
    FOREIGN KEY (user_id) REFERENCES users (user_id)
    ON DELETE RESTRICT;

COMMIT;
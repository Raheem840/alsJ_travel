-- R16: users -> notifications.user_id (1..1, required)
ALTER TABLE notifications
    ALTER COLUMN user_id SET NOT NULL;

ALTER TABLE notifications
    ADD CONSTRAINT fk_notifications_user
    FOREIGN KEY (user_id)
    REFERENCES users (user_id)
    ON DELETE CASCADE;

-- R17: applications -> notifications.application_id (0..1, optional)
ALTER TABLE notifications
    ADD CONSTRAINT fk_notifications_application
    FOREIGN KEY (application_id)
    REFERENCES applications (application_id)
    ON DELETE SET NULL;

-- R18: users -> audit_logs.user_id (0..1, optional, NULL = system)
ALTER TABLE audit_logs
    ADD CONSTRAINT fk_audit_logs_user
    FOREIGN KEY (user_id)
    REFERENCES users (user_id)
    ON DELETE SET NULL;
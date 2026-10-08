-- Create ENUM types for notifications
CREATE TYPE notification_channel_enum AS ENUM ('SMS', 'EMAIL');
CREATE TYPE notification_status_enum AS ENUM ('SENT', 'FAILED');

-- Create notifications table
CREATE TABLE notifications (
    notification_id     BIGSERIAL                   PRIMARY KEY,
    user_id             UUID                        NOT NULL,
    application_id      UUID,
    channel             notification_channel_enum   NOT NULL,
    message             VARCHAR(300)                NOT NULL,
    status              notification_status_enum    NOT NULL DEFAULT 'SENT'
);
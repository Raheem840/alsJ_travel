-- Create ENUM types for notifications
CREATE TYPE notification_channel_enum AS ENUM ('SMS', 'EMAIL');
CREATE TYPE notification_status_enum AS ENUM ('SENT', 'FAILED');

-- Create notifications table
CREATE TABLE notifications (
    notification_id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    application_id UUID,
    channel notification_channel_enum NOT NULL,
    message VARCHAR(300) NOT NULL,
    status notification_status_enum NOT NULL DEFAULT 'SENT',
    
    -- Foreign Key constraints
    CONSTRAINT fk_notifications_user 
        FOREIGN KEY (user_id) 
        REFERENCES users(user_id),
        
    CONSTRAINT fk_notifications_application 
        FOREIGN KEY (application_id) 
        REFERENCES applications(application_id)
);
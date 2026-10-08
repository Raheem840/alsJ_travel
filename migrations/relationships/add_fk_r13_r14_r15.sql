-- =========================================================================
-- Description: Adds Foreign Key constraints for R13, R14, and R15 
--              connecting stage_history and schedule_records to users.
-- =========================================================================

-- Relationship R13: users -> stage_history.changed_by
-- Each stage history entry may optionally reference the user who triggered the change (NULL = system action).
ALTER TABLE stage_history
    ADD CONSTRAINT fk_stage_history_changed_by 
    FOREIGN KEY (changed_by) 
    REFERENCES users(user_id);

-- Relationship R14: users -> schedule_records.client_id
-- Each appointment schedule record must reference a valid client user.
ALTER TABLE schedule_records
    ADD CONSTRAINT fk_schedule_records_client 
    FOREIGN KEY (client_id) 
    REFERENCES users(user_id);

-- Relationship R15: users -> schedule_records.staff_id
-- Each appointment schedule record must reference a valid responsible staff user.
ALTER TABLE schedule_records
    ADD CONSTRAINT fk_schedule_records_staff 
    FOREIGN KEY (staff_id) 
    REFERENCES users(user_id);
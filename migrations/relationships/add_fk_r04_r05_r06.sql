ALTER TABLE applications
    ADD CONSTRAINT fk_applications_client
    FOREIGN KEY (client_id) REFERENCES users (user_id)
    ON DELETE RESTRICT ON UPDATE RESTRICT;

ALTER TABLE applications
    ADD CONSTRAINT fk_applications_assigned_agent
    FOREIGN KEY (assigned_agent_id)
    REFERENCES users (user_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;

ALTER TABLE applications
    ADD CONSTRAINT fk_applications_current_stage
    FOREIGN KEY (current_stage_id)
    REFERENCES pipeline_stages (stage_id)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT;
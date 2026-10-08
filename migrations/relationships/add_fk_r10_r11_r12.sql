-- R10: Every history entry belongs to one application
ALTER TABLE stage_history
    ADD CONSTRAINT fk_stage_history_application 
    FOREIGN KEY (application_id) 
    REFERENCES applications(application_id)
    ON DELETE CASCADE;

-- R11: The source stage is optional (NULL allowed for initial entries)
ALTER TABLE stage_history
    ADD CONSTRAINT fk_stage_history_from_stage 
    FOREIGN KEY (from_stage_id) 
    REFERENCES pipeline_stages(stage_id)
    ON DELETE SET NULL;

-- R12: Each history entry must transition to a specific target stage
ALTER TABLE stage_history
    ADD CONSTRAINT fk_stage_history_to_stage 
    FOREIGN KEY (to_stage_id) 
    REFERENCES pipeline_stages(stage_id)
    ON DELETE RESTRICT;
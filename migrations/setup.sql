-- Run with psql -v ON_ERROR_STOP=1 -d YOUR_DATABASE -f migrations/setup.sql
-- For a NEW, EMPTY database only. Existing pgAdmin tables do not need recreation.
\set ON_ERROR_STOP on
BEGIN;
\ir tables/create_roles.sql
\ir tables/create_users.sql
\ir tables/create_pipeline_stages.sql
\ir tables/applications_and_staff_profiles.sql
\ir tables/create_client_profiles.sql
\ir tables/create_schedule_records.sql
\ir tables/create_documents.sql
\ir tables/create_stage_history.sql
\ir tables/create_payments.sql
\ir tables/create_notifications.sql
\ir tables/create_audit_logs.sql
\ir relationships/add_fk_r01_r02_r03.sql
\ir relationships/add_fk_r04_r05_r06.sql
\ir relationships/add_fk_r13_r14_r15.sql
COMMIT;
-- R07-R09 is transactional and runs after all tables exist.
\ir relationships/add_fk_r07_r08_r09.sql

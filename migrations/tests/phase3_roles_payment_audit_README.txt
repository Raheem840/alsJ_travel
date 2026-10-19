Your Phase 3 task ONLY: document/appointment role rules + payment status audit

Run in this order in the SAME project database, after the project's tables and
relationships. Each file works in pgAdmin Query Tool or psql:
1. migrations/triggers/045_add_trg_document_verifier_role.sql
2. migrations/triggers/046_add_trg_appointment_participant_roles.sql
3. migrations/triggers/047_add_trg_payment_status_audit.sql
4. migrations/tests/test_document_appointment_roles_payment_audit.sql (whole file)

The three migrations replace only their own functions/triggers and may be rerun.
They do not modify colleagues' trigger scripts or setup.sql.
Role names must be exactly Client, Field Agent and Data Entry Staff.
Documents: a non-null verifier must be a Field Agent or Data Entry Staff.
Appointments: the client must be a Client with a client profile; the staff member
must have a staff profile. No additional appointment staff role list is imposed.
The existing document CHECK handles the required/null verification fields.

Payments: each UPDATE that actually changes status writes one audit row containing
payment UUID and old/new statuses. No row is logged for INSERT or unchanged status.
Audit user_id is NULL (system/unspecified): payments does not identify the actor.
Failed/rolled-back updates leave no payment audit entries. The existing refund
completion-time trigger is separate and is not changed.

The test uses REAL tables and triggers, creates fixture data and rolls it all back.
It reports 17 checks. If execution stops with an error, run ROLLBACK;.
Sequence counters may advance. Existing rows are not updated.
The test targets the schema/triggers currently in the repository; colleagues' future
profile/stage triggers may require adapting its fixtures to those new prerequisites.

These row triggers validate document/appointment inserts and updates. They do not
scan old rows on installation or replace the separate role-change/profile guards
assigned to your colleagues. Coordinate those guards with these role rules.

psql example from the repository root:
psql -v ON_ERROR_STOP=1 -d YOUR_DATABASE -f migrations/triggers/045_add_trg_document_verifier_role.sql -f migrations/triggers/046_add_trg_appointment_participant_roles.sql -f migrations/triggers/047_add_trg_payment_status_audit.sql -f migrations/tests/test_document_appointment_roles_payment_audit.sql

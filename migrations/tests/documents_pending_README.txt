Documents Pending constraint and integration check

On each teammate's machine:
1. Create the project tables and apply the team's relationships/triggers.
2. In the project database, run migrations/chk_constraints/chk_documents_pending.sql ONCE.
3. Run the entire migrations/tests/test_documents_pending.sql file in pgAdmin.
4. Check Messages for PASS notices followed by ROLLBACK.

The integration test inserts temporary fixture rows into the REAL roles, users,
applications and documents tables, tests three invalid pending states and valid
pending/verified/rejected states, then rolls back all fixture rows and trigger writes.
Sequence counters may advance, which is normal. No existing rows are updated.
The test uses the constraints and triggers currently installed on that machine.
If a query fails, run ROLLBACK; and report the error. Do not remove constraints to pass.
The existing combined verification check may also reject invalid pending rows;
this script checks their integrated behavior and presence of the named new constraint.

psql alternative (from repository root):
psql -v ON_ERROR_STOP=1 -d YOUR_DATABASE -f migrations/tests/test_documents_pending.sql

setup.sql uses psql commands; it is not a pgAdmin Query Tool script.
The new constraint and test are standalone: apply/run them explicitly as above.

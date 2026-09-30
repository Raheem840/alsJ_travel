CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE document_type_enum AS ENUM ('PASSPORT', 'NATIONAL_ID', 'TRAVEL_DECLARATION');
CREATE TYPE verification_status_enum AS ENUM ('PENDING', 'VERIFIED', 'REJECTED');

CREATE TABLE IF NOT EXISTS client_profiles (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    national_id VARCHAR(30) UNIQUE NOT NULL,
    date_of_birth DATE NULL,
    address VARCHAR(200) NULL,
    preferred_language VARCHAR(20) NOT NULL DEFAULT 'EN'
);
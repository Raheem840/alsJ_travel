CREATE TABLE client_profiles (
    user_id UUID PRIMARY KEY,
    national_id VARCHAR(30) UNIQUE NOT NULL,
    date_of_birth DATE NULL,
    address VARCHAR(200) NULL,
    preferred_language VARCHAR(20) NOT NULL DEFAULT 'EN'
);

CREATE TABLE pipeline_stages (
    stage_id SMALLSERIAL PRIMARY KEY,
    stage_name VARCHAR(50) UNIQUE NOT NULL,
    stage_order SMALLINT UNIQUE NOT NULL CHECK (stage_order BETWEEN 1 AND 7),
    description VARCHAR(200)
);

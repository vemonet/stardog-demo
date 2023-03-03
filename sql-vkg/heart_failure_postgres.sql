CREATE DATABASE heart_failure_db;
\c heart_failure_db

CREATE TABLE stroke_data (
	id INTEGER NOT NULL,
	gender VARCHAR(128) NOT NULL,
	age VARCHAR(128) NOT NULL,
	hypertension BOOLEAN NOT NULL,
	heart_disease BOOLEAN NOT NULL,
	ever_married BOOLEAN NOT NULL,
	work_type VARCHAR(128) NOT NULL,
	Residence_type VARCHAR(128) NOT NULL,
	avg_glucose_level VARCHAR(128) NOT NULL,
	bmi VARCHAR(128),
	smoking_status VARCHAR(128) NOT NULL,
	stroke BOOLEAN NOT NULL
);

COPY stroke_data FROM '/data/stroke-data.csv' WITH (FORMAT csv, DELIMITER ',', HEADER true);


SELECT * FROM stroke_data LIMIT 3;

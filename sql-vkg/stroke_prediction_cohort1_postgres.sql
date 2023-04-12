CREATE DATABASE stroke_prediction_dataset;
\c stroke_prediction_dataset

CREATE TABLE stroke_prediction_cohort1 (
	id INTEGER NOT NULL,
	gender VARCHAR(128) NOT NULL,
	age VARCHAR(128) NOT NULL,
	hypertension BOOLEAN NOT NULL,
	heart_disease BOOLEAN NOT NULL,
	ever_married VARCHAR(128) NOT NULL,
	work_type VARCHAR(128) NOT NULL,
	Residence_type VARCHAR(128) NOT NULL,
	avg_glucose_level VARCHAR(128) NOT NULL,
	bmi VARCHAR(128),
	smoking_status VARCHAR(128) NOT NULL,
	stroke BOOLEAN NOT NULL
);

COPY stroke_prediction_cohort1 FROM '/data/stroke-prediction-cohort1.csv' WITH (FORMAT csv, DELIMITER ',', HEADER true);


SELECT * FROM stroke_prediction_cohort1 LIMIT 3;

CREATE DATABASE stroke_prediction_dataset_cohort2;
USE stroke_prediction_dataset_cohort2;

CREATE TABLE stroke_prediction_cohort2 (
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

LOAD DATA INFILE '/data/stroke-prediction-cohort2.csv'
INTO TABLE stroke_prediction_cohort2
FIELDS TERMINATED BY ','
IGNORE 1 LINES;

SELECT * FROM stroke_prediction_cohort2 LIMIT 3;

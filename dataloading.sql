--Create Storage Integration
CREATE OR REPLACE STORAGE INTEGRATION hotel_aws
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::827859361686:role/hotelaccess'
    STORAGE_ALLOWED_LOCATIONS = ('s3://hotelbookings3/')
    ENABLED = TRUE;

--Retrieve IAM Values for AWS Trust Policy
DESC STORAGE INTEGRATION hotel_aws;

--Create File Format for CSV Files
CREATE OR REPLACE FILE FORMAT hotel_csv
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n';

--Create External Stage (Points to S3)
CREATE OR REPLACE STAGE external_hotel
    URL = 's3://hotelbookings3/'
    STORAGE_INTEGRATION = hotel_aws
    FILE_FORMAT = hotel_csv;

--Create Raw Bronze Table
CREATE OR REPLACE TABLE hotel_booking_raw.BRONZE_HOTEL_BOOKING (
    booking_id STRING,
    hotel_id STRING,
    hotel_city STRING,
    customer_id STRING,
    customer_name STRING,
    customer_email STRING,
    check_in_date STRING,
    check_out_date STRING,
    room_type STRING,
    num_guests STRING,
    total_amount STRING,
    currency STRING,
    booking_status STRING
);

--Validate Files in the S3 External Stage
LIST @external_hotel;

--Load Data from Stage → Bronze Table
COPY INTO hotel_booking_raw.BRONZE_HOTEL_BOOKING
FROM @external_hotel
FILE_FORMAT = (FORMAT_NAME = hotel_csv)
ON_ERROR = 'continue';

--Verify Loaded Data
SELECT * FROM hotel_booking_raw.BRONZE_HOTEL_BOOKING;



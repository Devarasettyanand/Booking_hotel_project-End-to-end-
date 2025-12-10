CREATE TABLE hotel_booking_silver.SILVER_HOTEL_BOOKINGS (
    booking_id VARCHAR,
    hotel_id VARCHAR,
    hotel_city VARCHAR,
    customer_id VARCHAR,
    customer_name VARCHAR,
    customer_email VARCHAR,
    check_in_date DATE,
    check_out_date DATE,
    room_type VARCHAR,
    num_guests INTEGER,
    total_amount FLOAT,
    currency VARCHAR,
    booking_status VARCHAR
);

insert into hotel_booking_silver.SILVER_HOTEL_BOOKINGS
select 
    booking_id ,
    hotel_id ,
    initcap (trim(hotel_city)) as hotel_city,
    customer_id ,
    initcap (trim(customer_name)) as customer_name,
    case
        when CUSTOMER_EMAIL like '%@%.%' then lower(trim(CUSTOMER_EMAIL))  else null end as CUSTOMER_EMAIL ,
    try_to_date(NULLIF(check_in_date ,' ')) as check_in_date ,
    try_to_date(NULLIF(check_out_date ,' ')) as check_out_date ,
    room_type ,
    num_guests ,
    ABS(try_to_number(TOTAL_AMOUNT))  as TOTAL_AMOUNT,
    currency ,
    case
        when BOOKING_STATUS in ( 'Confirmeeed' ,'Confirmd' ) then 'Confirmed' else BOOKING_STATUS end as BOOKING_STATUS
    from hotel_booking_raw.BRONZE_HOTEL_BOOKING
    where 
         try_to_date(check_in_date) is not null AND
         try_to_date(CHECK_OUT_DATE) is not null AND 
         try_to_date(CHECK_OUT_DATE) >= try_to_date(CHECK_IN_DATE) ;

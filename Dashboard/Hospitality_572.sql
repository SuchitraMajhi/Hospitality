SHOW databases;
USE hospitality;
show tables;

#---------- Adding column (converted_date) in dim_date-------
# date is in text format so that is why adding date column in date Format
select date from dim_date;

set sql_safe_updates =0;

ALTER TABLE dim_date ADD COLUMN converted_date DATE;

UPDATE dim_date 
SET converted_date = STR_TO_DATE(date, '%d-%b-%y');

select converted_date from dim_date;
desc dim_date;
SELECT converted_date FROM dim_date;
SELECT MONTHNAME(converted_date) AS Month FROM dim_date
GROUP BY Month;


#-------------------Adding column (date_column) in fact_booking-----------------    

select check_in_date from fact_bookings;
set sql_safe_updates =0;
ALTER TABLE fact_bookings ADD COLUMN date_column DATE;

UPDATE fact_bookings 
SET date_column = STR_TO_DATE(check_in_date, '%Y-%m-%d');

select date_column from fact_bookings;

DESCRIBE fact_bookings;
SELECT MONTHNAME(date_column) AS Month
FROM fact_bookings group by Month;



----------# Adding column date_column) in fact_aggregated_bookings-------

SELECT check_in_date FROM fact_aggregated_bookings;

ALTER TABLE fact_aggregated_bookings ADD COLUMN date_column DATE;

UPDATE fact_aggregated_bookings 
SET date_column = STR_TO_DATE(check_in_date, '%d-%b-%y');

select date_column from fact_aggregated_bookings;

desc fact_aggregated_bookings;
SELECT date_column FROM fact_aggregated_bookings;
SELECT MONTHNAME(date_column) AS Month FROM fact_aggregated_bookingS
GROUP BY Month;

# KPI'S 1(Total Revenue)-------------------------------------------------------->
SELECT Sum(revenue_realized) As Total_Revenue
FROM fact_bookings;

SELECT CONCAT(FORMAT(SUM(revenue_realized)/1000000, 0), ' M') AS Total_Revenue
FROM fact_bookings;

# KPI'S 2(Occupancy)------------------------------------------------------------->
SELECT sum(successful_bookings)/sum(capacity)AS Occupancy
FROM fact_aggregated_bookings;

SELECT Concat(FORMAT((SUM(successful_bookings)/sum(capacity))* 100,2), "%") AS Occupancy
FROM fact_aggregated_bookings;


# KPI's 3(Cancellation Rate)------------------------------------------------------>
SELECT Concat(Format((SUM( CASE 
WHEN booking_status = "Cancelled" THEN 1 ELSE 0
END )/COUNT(booking_id))*100, 2), "%") AS Cancellation_Rate
FROM fact_bookings;

SELECT 
    dr.room_class AS Room_Class,
    CONCAT(FORMAT((SUM(CASE 
        WHEN fb.booking_status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(fb.booking_id)) * 100, 2), '%') AS Cancellation_Rate
FROM 
    dim_rooms dr
JOIN 
    fact_bookings fb ON dr.room_id = fb.room_category
GROUP BY 
    dr.room_class;
    
    # KPI's 4(Total Booking)---------------------------------------------------------------->
SELECT COUNT(booking_id) AS Total_Booking 
 FROM fact_bookings;
 
 # KPI's 5(UtilizeD capacity)---------------------------------------------------------->	
 SELECT SUM( CASE 
 WHEN booking_status = "Checked Out" THEN  1 ELSE 0 END) AS Utilized_Capacity
 FROM fact_bookings;
 
 
  # KPI's 6(Trend Analysis- Montly Booking and Occupancy)------------------------------------------>
 SELECT 
    monthname(date_column) AS Month,
    SUM(successful_bookings) AS Booking, 
    CONCAT(FORMAT((SUM(successful_bookings) / SUM(capacity)) * 100, 2), '%') AS Occupancy
FROM 
    fact_aggregated_bookings
GROUP BY Month;


# KPI's 7(Weekday  & Weekend  Revenue and Booking)---------------------------------------->
    SELECT dd.day_type AS Day_Type,COUNT(fb.booking_id) AS Booking,
    SUM(fb.revenue_realized) AS Revenue
    FROM fact_bookings fb
    JOIN dim_date dd
    ON  dd.converted_date = fb.date_column
    GROUP BY dd.day_type;
    
    SELECT dd.day_type AS Day_Type,COUNT(fb.booking_id) AS Booking,
    CONCAT(FORMAT(SUM(fb.revenue_realized)/1000000, 0), ' M') AS Total_Revenue
    FROM fact_bookings fb
    JOIN dim_date dd
    ON  dd.converted_date = fb.date_column
    GROUP BY dd.day_type;
    
    # KPI's 8(Revenue by City & hotel)-------------------------------------------------->
SELECT dh.city As City,dh.property_name AS Hotel,
sum(revenue_realized) AS Revenue
FROM dim_hotels  dh
JOIN fact_bookings fb
ON dh.property_id = fb.property_id
GROUP BY 
dh.city,
dh.property_name;

SELECT dh.city As City,dh.property_name AS Hotel,
CONCAT(FORMAT(SUM(fb.revenue_realized)/1000000, 0), ' M') AS Revenue
FROM dim_hotels  dh
JOIN fact_bookings fb
ON dh.property_id = fb.property_id
GROUP BY 
dh.city,
dh.property_name;

SELECT dh.city As City,
CONCAT(FORMAT(SUM(fb.revenue_realized)/1000000, 0), ' M') AS Revenue
FROM dim_hotels  dh
JOIN fact_bookings fb
ON dh.property_id = fb.property_id
GROUP BY 
dh.city;


SELECT dh.property_name As Hotel,
CONCAT(FORMAT(SUM(fb.revenue_realized)/1000000, 0), ' M') AS Revenue
FROM dim_hotels  dh
JOIN fact_bookings fb
ON dh.property_id = fb.property_id
GROUP BY 
dh.property_name
LIMIT 5;


# KPI's 9(Class Wise Revenue)----------------------------------------------------------->
SELECT dr.room_class As Room_Class,
CONCAT(FORMAT(SUM(fb.revenue_realized)/1000000, 0), ' M') AS Revenue
FROM dim_rooms dr
JOIN fact_bookings fb
ON dr.room_id = fb.room_category
GROUP BY  dr.room_class;

# KPI's 10(Checked out cancel No show)--------------------------------------------------->
SELECT booking_status,
COUNT(booking_id) AS Booking
FROM fact_bookings
GROUP BY booking_status;

# KPIs 11(Weekly trend Key trend (Revenue, Total booking, Occupancy)

SELECT 
    dd.`week no` AS Week_No,
    COUNT(fb.booking_id) AS Booking,
    SUM( CASE 
 WHEN fb.booking_status = "Checked Out" THEN  1 ELSE 0 END) AS Utilized_Capacity,
    CONCAT(FORMAT(SUM(fb.revenue_realized) / 1000000, 0), ' M') AS Revenue
FROM 
    dim_date dd
JOIN fact_bookings fb
ON dd.converted_date = fb.date_column
GROUP BY 
dd.`week no`;

   
 













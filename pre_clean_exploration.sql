/*
We are precleaning the data and analyzing it so we know what we need to do to clean the data before analysis.
*/

-- First we will combine the 12 months of data into a new table consisting of all bike trips in 2022. 

CREATE TABLE `divvy-app-data.bike_tripdata.combined_tripdata` AS
SELECT *
FROM (
    SELECT * FROM `divvy-app-data.bike_tripdata.jan2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.feb2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.mar2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.apr2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.may2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.june2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.jul2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.aug2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.sept2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.oct2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.nov2022_tripdata`
    UNION ALL
    SELECT * FROM `divvy-app-data.bike_tripdata.dec2022_tripdata`
);

/* NOTES:
We are looking at how many rows are returned from the new table and seeing that it matches the sum of the 12 individual tables. 
They match at 5,667,717 rows of data so we imported the table correctly. 
A UNION ALL keeps all the rows from the multiple tables specified in the UNION ALL OR appends them.
However, a UNION will remove all rows that have duplicate values in one of the table's you are unioning.

---------------Analyze all columns from left to right for cleaning----------------------------------------------

#1.ride_id:
- check length combinations for ride_id  
- and all values are unique as ride_id is a primary key
*/

SELECT *
FROM `divvy-app-data.bike_tripdata.combined_tripdata`;

SELECT LENGTH(ride_id), count(*)
FROM `divvy-app-data.bike_tripdata.combined_tripdata`
GROUP BY LENGTH(ride_id);

SELECT COUNT(DISTINCT ride_id)
FROM `divvy-app-data.bike_tripdata.combined_tripdata`;

/* NOTES:
All ride_id strings are 16 characters long and they are all distinct. 
No cleaning neccesary for column 1.
*/

--#2. check the allowable rideable_types

SELECT DISTINCT rideable_type
FROM `divvy-app-data.bike_tripdata.combined_tripdata`;


/* Notes:
There are 3 types of bikes, electric, classic, and docked.
Docked bikes is an error, as they are just classic bikes.
*/

/* #3.
Check column 3 and 4. Only pull back results longer than one minute,
but shorter than 1 day. Column 3 and 4 are timestamp types so we are
checking the difference between the two columns. 
*/

SELECT *
FROM `divvy-app-data.bike_tripdata.combined_tripdata`
WHERE TIMESTAMP_DIFF(ended_at, started_at, MINUTE) <= 1 OR
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) >= 1440;

-- There are 227,604 rides less than 1 minute or longer than 1 day.


/*
#4. Check the start/end station name/id columns for naming inconsistencies
*/

SELECT start_station_name, COUNT(*)
FROM `divvy-app-data.bike_tripdata.combined_tripdata`
GROUP BY start_station_name
ORDER BY start_station_name;

SELECT end_station_name, COUNT(*)
FROM `divvy-app-data.bike_tripdata.combined_tripdata`
GROUP BY end_station_name
ORDER BY end_station_name;

SELECT COUNT(DISTINCT(start_station_name)) AS unq_startname,
  COUNT(DISTINCT(end_station_name)) AS unq_endname,
  COUNT(DISTINCT(start_station_id)) AS unq_startid,
  COUNT(DISTINCT(end_station_id)) AS unq_endid
FROM `divvy-app-data.bike_tripdata.combined_tripdata`;

/*
Query 1 - there are 833,064 null station names. 
Query 2 - there are 892,742 null station names.
Start and end station names need to be cleaned up:
-Remove leading and traling spaces.
-Remove substrings '(Temp)' as Cyclisitc uses these substrings when repairs
are happening to a station. All station names should have the same naming conventions.
-Found starting/end_names with "DIVVY CASSETTE REPAIR MOBILE STATION", "Lyft Driver Center Private Rack",
"351", "Base - 2132 W Hubbard Warehouse", Hubbard Bike-checking (LBS-WH-TEST), "WEST CHI-WATSON".
We will delete these as they are maintainence trips.
-Start and end station id columns have many naming convention errors and different string lengths.
As they do not offer any use to the analysis and there is no benefit to cleaning them, they will be ignored.
*/

#5. Check NULLS in start and end station name columns

SELECT rideable_type, COUNT(*) AS num_of_rides
FROM `divvy-app-data.bike_tripdata.combined_tripdata`
WHERE start_station_name IS NULL AND start_station_id IS NULL OR
    end_station_name IS NULL AND end_station_id IS NULL 
GROUP BY rideable_type;

/*
Classic_bikes/docked_bikes will always start and end their trip locked in a docking station,
but electric bikes have more versatility. Electric bikes can be locked up using their bike lock
in the general vicinity of a docking station; thus, trips do not have to start or end at a station.
As such we will do the following:
- remove classic/docked bike trips that do not have a start or end station name and have no start/end station id to use to fill in the null.
- change the null station names to 'On Bike Lock' for electric bikes
*/

--#6. Check rows were latitude and longitude are null

SELECT *
FROM `divvy-app-data.bike_tripdata.combined_tripdata`
WHERE start_lat IS NULL OR
 start_lng IS NULL OR
 end_lat IS NULL OR
 end_lng IS NULL;

-- NOTE: we will remove these rows as all rows should have location points

#7. Confirm that there are only 2 member types in the member_casual column:

SELECT DISTINCT member_casual
FROM `divvy-app-data.bike_tripdata.combined_tripdata`

--NOTE: Yes the only values in this field are 'member' or 'casual'

--Now we are ready to clean the data and then analyze it.
--Go to the data_cleaning_analysis.sql file to see that query.

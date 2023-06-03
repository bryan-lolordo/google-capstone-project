/*
First we will combine the 12 months of data into a new table consisting of all bike trips in 2022. 
*/

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

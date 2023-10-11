

CREATE TABLE opensky (
     origin_country VARCHAR,
     callsign VARCHAR,
     on_ground BOOLEAN,
     ts TIMESTAMP(3) WITH LOCAL TIME ZONE METADATA FROM 'timestamp',
     proctime AS PROCTIME(),
     WATERMARK FOR ts AS ts - INTERVAL '5' SECOND
   ) WITH (
     'connector'                    = 'kafka',
     'topic'                        = 'flight_information',
     'properties.bootstrap.servers' = 'redpanda-1:9092',
     'scan.startup.mode' = 'earliest-offset',
     'format'                       = 'json'
 );


# Show count of event records for United flights by Window
SELECT window_time, origin_country, COUNT(*) as Number
FROM TABLE(
     TUMBLE(TABLE opensky, DESCRIPTOR(ts), INTERVAL '30' MINUTES))
WHERE callsign like 'UAL%'
GROUP BY window_time, origin_country;


# How many United Airlines planes were reported in the past 30 minutes?
# Note that there many be many events for the same callsign.  So first
# need to get a distinc list of flights.

select count(*)
from (
     select DISTINCT callsign
     from  opensky
     where ts > now() - interval '30' minutes
     AND   callsign like 'BAW%');

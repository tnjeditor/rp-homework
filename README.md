# rp-homework

Here are my results of working on the homework project for RP.  This is configured as a simple playground/development environment using docker and docker-compose.

## Getting it going
The following steps will start all the components and the opensky data collector.  Note that the collector will eventually die on its own when it exhausts the rate limits of the Opensky API.

1. Build the opensky collector container:
   `docker-compose build`
2. Start the system:
   `docker-compose up -d`

To verify that everything is working run `docker-compose ps` - the sql-client will have stopped, this is ok.

## Accessing the UI
Redpanda Console:  http://localhost:8180
Apache Flink UI:  http://localhost:8081

## Check the opensky stream.
In the Redpanda Console navigate to Topics -> flight_information.  There should be some messages there.  Add a filter using the example from [Console-Filter.txt](https://github.com/tnjeditor/rp-homework/blob/master/Console-Filter.txt).  The 2 examples there should be pretty easy to understand and choose from.

## Flink SQL Examples
From the command line in the same directory where the docker-compose.yml file is, run `docker-compose run sql-client` to get to the SQL prompt.  In the [statements.sql](https://github.com/tnjeditor/rp-homework/blob/master/statements.sql) file there are a few SQL statements to use.
1. Run the CREATE statement to connect a Flink table to the Redpanda/flight_information stream.
2. The other 2 statements are simple examples of how to answer a could basic questions given the data stream.  Note that the count of United Airlines flights in the last 30 minutes might need to be changed to use a hard coded date if the data stream has reached its data cap for the day.

### Technical Details / Comments
The docker-compose.yml file includes services for redpanda, the redpanda-console and the various services for Flink.  There is also an opensky service which is build from the python connector in the opensky directory.

In this example I chose to use a python data collector as that was far more straightforwad than using the [kafka-connect-opensky](https://github.com/nbuesing/kafka-connect-opensky) project which doesn't seem to have been updated in a long time and could use some updates to make it work/build cleanly again.  There is a fork that someone made recently which works better, but still seems like alot of effort for a simple excercise like this.

Some of the examples for how to stand up redpanda with docker-compose did not make clear that the console not only gets its configuration from a local config file, but also uses the advertised values from repanda itself.  This led to frequent crashes until I realized what the logs were trying to tell me.  The docker-compose file was tuned to fix this issue using a private network with named services (ie. redpanda-1 ).

The Flink jobmanager and Redpanda have a default conflict on port 8081.  In this example I changed the redpanda schema port to 8083 - the console seems fine with that change.  It might be a good idea to change this so others don't stumble on it when hosting both in the same environment.

The docker-compose schema version in many of the examples is set to 3.7.  However version 3.3 seems to work just fine, nothing really requires 3.7 from what I can tell.

I set this up a couple times to make the setup easier.  In one of my earlier tests I used a script similar to opensky.py to injest tcpdump output.  That worked quite well however it quickly overloaded the system.  That said, the idea of using this setup to get some basic network data was pretty interesting.  I may try again at some point with some better filtering with tcpdump (such as monitoring DHCP requests & respones).

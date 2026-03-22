CREATE SUBSCRIPTION events_sub
CONNECTION 'host=pg_pub port=5432 dbname=app user=postgres password=postgres'
PUBLICATION events_pub;

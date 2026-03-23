### Overview

This project demonstrates **logical replication in PostgreSQL** using:

- a partitioned table, indexes, constraints
- background jobs via `pg_cron`
- test data generation
- materialized views and triggers
- Docker Compose for deployment

### Features Implemented

- **Partitioned table**
    - `RANGE` partitioning by date (`REP_DATE`)
    - Predefined monthly partitions

- **Logical replication**
    - Publisher / Subscriber setup
    - `PUBLICATION` and `SUBSCRIPTION` configuration

- **Background jobs (pg_cron)**
    - Periodic data insertion
    - Scheduled status updates

- **Data generation**
    - Initial dataset via `generate_events_for_period()`

- **Materialized View**
    - Aggregated data (`events_client_type_totals`)
    - Automatic refresh via trigger

- **Docker-based setup**
    - Multi-service orchestration with Docker Compose
    - Isolated publisher and subscriber environments

---

### Getting Started

**1. Cleanup (if previously started)**

```bash
docker-compose down -v
```

**2. Build the image (publisher with pg_cron)**
```bash
docker-compose build
```

**3. Start the services**
```bash
docker-compose up -d
```

---

### Verification

**Publisher**

Run the following commands to connect to the database

```bash
docker exec -it pg_pub psql -U postgres -d app
```

Data check
```sql
-- data check
select count(1) from events;

-- cron jobs
select * from cron.job;

-- materialized view
select count(1), sum(total_amount) from events_client_type_totals limit 10;
```
**Subscriber**

Commands to connect to the database
```bash
docker exec -it pg_sub psql -U postgres -d app
```

**Data check**
```sql
-- replication check
select count(1) from events;
```

---
create materialized view events_client_type_totals as
select (MESSAGE ->> 'client_id')::bigint   as CLIENT_ID,
       lower(MESSAGE ->> 'operation_type') as OPERATION_TYPE,
       sum(AMOUNT)::numeric(18,2)          as TOTAL_AMOUNT
  from EVENTS
 where STATUS = 1
group by CLIENT_ID, OPERATION_TYPE;

-- drop materialized view events_client_type_totals;

create unique index IDX_EVENTS_MV_UNIQUE on events_client_type_totals (CLIENT_ID, OPERATION_TYPE);


-- drop trigger if exists trg_refresh_events_client_type_totals on EVENTS;

create trigger trg_refresh_events_client_type_totals
after update on EVENTS
referencing old table as OLD_TABLE new table as NEW_TABLE
for each statement
execute function refresh_events_client_type_totals();

commit;
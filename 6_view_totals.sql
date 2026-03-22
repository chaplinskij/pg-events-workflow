create materialized view events_client_type_totals as
select (MESSAGE ->> 'client_id')::bigint   as CLIENT_ID,
       lower(MESSAGE ->> 'operation_type') as OPERATION_TYPE,
       sum(AMOUNT)::numeric(18,2)          as TOTAL_AMOUNT
  from EVENTS
 where STATUS = 1
group by CLIENT_ID, OPERATION_TYPE;

-- drop materialized view events_client_type_totals;

create unique index IDX_EVENTS_MV_UNIQUE on events_client_type_totals (CLIENT_ID, OPERATION_TYPE);

create or replace function refresh_events_client_type_totals()
returns trigger
language plpgsql as
$$
declare
    v_rows_changed int;
begin
    select count(1) into v_rows_changed
      from OLD_TABLE as t1
      join NEW_TABLE as t2 on t2.ID = t1.ID
     where t1.STATUS = 0
       and t2.STATUS = 1;
    if v_rows_changed > 0 then
       refresh materialized view concurrently events_client_type_totals;
    end if;

    return NULL;
end;
$$;

-- drop trigger if exists trg_refresh_events_client_type_totals on EVENTS;

create trigger trg_refresh_events_client_type_totals
after update on EVENTS
referencing old table as OLD_TABLE new table as NEW_TABLE
for each statement
execute function refresh_events_client_type_totals();

commit;
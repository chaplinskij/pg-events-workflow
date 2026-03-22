----------------------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------------------
create or replace procedure generate_events_for_period(
    ip_start      date,
    ip_end        date,
    ip_rows_count int default null
)
language plpgsql as
$$
declare
    v_days_count int;
    v_target_rows int;
begin
    v_days_count := ip_end - ip_start + 1;
    v_target_rows := coalesce(ip_rows_count, greatest(100000, v_days_count * 1200));

--     select public.ensure_events_month_partitions(p_start, p_end);

    insert into EVENTS (REP_DATE,
                        AMOUNT,
                        STATUS,
                        REFERENCE,
                        MESSAGE)
    select ip_start + (i % v_days_count),
           round((random() * 10000)::numeric, 2),
           0,
           gen_random_uuid(),
           jsonb_build_object(
               'client_id', CLIENT_ID,
               'account_number', (26000000000000 + CLIENT_ID),  -- 2600 + нулі + client_id (всього 14 символів)
               'operation_type', case when random() < 0.5 then 'online' else 'offline' end
           )
      from (select i,
                   floor(random() * 100000) + 1 as CLIENT_ID
              from generate_series(0, v_target_rows - 1) as g(i)) as t1;
end;
$$;
commit;


----------------------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------------------
create or replace procedure insert_event()
    language plpgsql as
$$
begin
    insert into EVENTS (REP_DATE,
                        AMOUNT,
                        STATUS,
                        REFERENCE,
                        MESSAGE)
    select CURRENT_DATE,
           round((10 + random() * 990)::numeric, 2),
           0,
           gen_random_uuid(),
           jsonb_build_object(
                   'client_id', CLIENT_ID,
                   'account_number', (26000000000000 + CLIENT_ID),  -- "2600 + нулі + client_id" (всього 14 символів)
                   'operation_type', case when random() < 0.5 then 'online' else 'offline' end
           )
    from (select floor(random() * 100000) + 1 as CLIENT_ID) as t1;
end;
$$;


----------------------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------------------
create or replace procedure update_events_status()
    language plpgsql as
$$
declare
    v_second integer;
begin
    v_second := extract(second from clock_timestamp())::integer;

    update EVENTS
    set STATUS = 1
    where STATUS = 0
      and (ID % 2) = v_second % 2;
end;
$$;


----------------------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------------------
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

commit;

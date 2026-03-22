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

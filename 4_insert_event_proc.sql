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

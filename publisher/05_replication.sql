do
$$
begin
    if not exists (
        select 1 from pg_publication where pubname = 'events_pub'
    ) then
        create publication events_pub for table events;
    end if;
end
$$;
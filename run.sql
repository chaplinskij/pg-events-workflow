create extension if not exists pg_cron;

call generate_events_for_period('2026-01-01'::date, '2026-03-31'::date, 300000);

select cron.schedule(
               'insert_event_5_sec',
               '5 seconds',
               'call public.insert_event();'
);
-- select cron.unschedule('insert_event_5_sec');

select cron.schedule(
               'update_events_status_3_sec',
               '3 seconds',
               'call public.update_events_status();'
       );
-- select cron.unschedule('update_events_status_3_sec');
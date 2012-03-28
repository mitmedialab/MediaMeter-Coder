select pub_date, count(*), source from articles group by pub_date, source;
select created_at, pub_date from articles GROUP BY pub_date ORDER BY created_at ASC;

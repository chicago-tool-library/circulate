WITH dates AS
         (SELECT min(date_trunc('month', created_at)) AS startm,
                 max(date_trunc('month', created_at)) AS endm
          FROM members),
     months AS (SELECT generate_series(startm, endm, '1 month') AS month FROM dates)
SELECT extract(YEAR FROM months.month) ::integer AS year,
       extract(MONTH FROM months.month)::integer                      AS month,
       count(DISTINCT m.id) filter (WHERE m.status = 0)               AS pending_members_count,
       count(DISTINCT m.id) filter (WHERE m.status = 1)               AS new_members_count
FROM months LEFT JOIN members m ON date_trunc('month', m.created_at) = months.month
GROUP BY months.month
ORDER BY months.month;

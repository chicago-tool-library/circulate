WITH dates AS
         (SELECT min(date_trunc('month', starts_at)) AS startm,
                 max(date_trunc('month', starts_at)) AS endm
          FROM appointments),
     months AS (SELECT generate_series(startm, endm, '1 month') AS month FROM dates)
SELECT extract(YEAR FROM months.month) ::integer                      AS year,
       extract(MONTH FROM months.month)::integer                      AS month,
       count(DISTINCT a.id)                                           AS appointments_count,
       count(DISTINCT a.id) filter (WHERE a.completed_at IS NOT NULL) AS completed_appointments_count
FROM months
         LEFT JOIN appointments a ON date_trunc('month', a.starts_at) = months.month
GROUP BY months.month
ORDER BY months.month;

WITH dates AS
         (SELECT min(date_trunc('month', created_at)) AS startm,
                 max(date_trunc('month', created_at)) AS endm
          FROM loans),
     months AS
             (SELECT generate_series(startm, endm, '1 month') AS month FROM dates)
SELECT extract(YEAR FROM months.month)::integer                       AS year,
       extract(MONTH FROM months.month)::integer                      AS month,
       count(DISTINCT l.id)                                           AS loans_count,
       count(DISTINCT l.member_id)                                    AS active_members_count,
       count(DISTINCT m.id) filter (WHERE m.status = 0)               AS pending_members_count,
       count(DISTINCT m.id) filter (WHERE m.status = 1)               AS new_members_count,
       count(DISTINCT a.id)                                           AS appointments_count,
       count(DISTINCT a.id) filter (WHERE a.completed_at IS NOT NULL) AS completed_appointments_count
FROM months
         LEFT OUTER JOIN loans l ON date_trunc('month', l.created_at) = months.month
         LEFT JOIN members m ON date_trunc('month', m.created_at) = months.month
         LEFT JOIN appointments a ON date_trunc('month', a.starts_at) = months.month
GROUP BY months.month
ORDER BY months.month ASC;

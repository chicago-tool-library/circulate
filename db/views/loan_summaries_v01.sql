SELECT
  loans.item_id,
  loans.member_id, 
  COALESCE(loans.initial_loan_id, loans.id) as initial_loan_id,
  MIN(loans.created_at) as created_at,
  MIN(loans.due_at) as due_at,
  CASE
    WHEN count(ended_at) = count(id)
    THEN max(ended_at)
    ELSE NULL
  END as ended_at,
  MAX(renewal_count) as renewal_count
FROM loans
GROUP BY item_id, member_id, COALESCE(initial_loan_id, id)
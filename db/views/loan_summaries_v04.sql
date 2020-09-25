SELECT
  loans.library_id,
  loans.item_id,
  loans.member_id,
  COALESCE(loans.initial_loan_id, loans.id) as initial_loan_id,
  MAX(loans.id) as latest_loan_id,
  MIN(loans.created_at) as created_at,
  MAX(loans.due_at) as due_at,
  CASE
    WHEN COUNT(ended_at) = COUNT(id)
    THEN MAX(ended_at)
    ELSE NULL
  END as ended_at,
  MAX(renewal_count) as renewal_count
FROM loans
GROUP BY library_id, item_id, member_id, COALESCE(initial_loan_id, id)

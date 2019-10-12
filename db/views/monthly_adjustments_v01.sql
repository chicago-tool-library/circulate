select
    extract(year from created_at)::integer as year,
  	extract(month from created_at)::integer as month,
  	count(*) FILTER (WHERE kind = 'membership') as membership_count,
  	count(*) FILTER (WHERE kind = 'fine') as fine_count,
    sum(-amount_cents) FILTER (WHERE kind = 'fine') as fine_total_cents,
  	sum(-amount_cents) FILTER (WHERE kind = 'membership') as membership_total_cents,  	
  	sum(amount_cents) FILTER (WHERE kind = 'payment') as payment_total_cents,
  	sum(amount_cents) FILTER (WHERE kind = 'payment' AND payment_source = 'square') as square_total_cents,
  	sum(amount_cents) FILTER (WHERE kind = 'payment' AND payment_source = 'cash') as cash_total_cents,
  	sum(amount_cents) FILTER (WHERE kind = 'payment' AND payment_source = 'forgiveness') as forgiveness_total_cents
  from adjustments
  group by year, month;
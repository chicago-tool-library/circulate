
select
    extract(year from created_at)::integer as year,
  	extract(month from created_at)::integer as month,
    
  	count(*) FILTER (WHERE kind = 'membership'AND adjustable_id = first_memberships.first_membership_id) as new_membership_count,
    sum(-amount_cents) FILTER (WHERE kind = 'membership'AND adjustable_id = first_memberships.first_membership_id) as new_membership_total_cents,  	

  	count(*) FILTER (WHERE kind = 'membership' AND adjustable_id != first_memberships.first_membership_id) as renewal_membership_count,
		sum(-amount_cents) FILTER (WHERE kind = 'membership' AND adjustable_id != first_memberships.first_membership_id) as renewal_membership_total_cents,  	

  	COALESCE(sum(amount_cents) FILTER (WHERE kind = 'payment'), 0) as payment_total_cents,
  	COALESCE(sum(amount_cents) FILTER (WHERE kind = 'payment' AND payment_source = 'square'), 0) as square_total_cents,
  	COALESCE(sum(amount_cents) FILTER (WHERE kind = 'payment' AND payment_source = 'cash'), 0) as cash_total_cents

  from adjustments
  	LEFT JOIN (  
			SELECT
				members.id as member_id,
				min(memberships.id) as first_membership_id
			FROM members
			LEFT JOIN memberships on members.id = memberships.member_id
			GROUP BY members.id
		) as first_memberships ON first_memberships.member_id = adjustments.member_id

  group by year, month
  order by year, month;
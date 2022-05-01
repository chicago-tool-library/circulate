WITH RECURSIVE search_tree(id, library_id, name, slug, parent_id, path_names, path_ids) AS (

  SELECT id, library_id, name, slug, parent_id, ARRAY[name], ARRAY[id]
    FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
    SELECT categories.id, categories.library_id, categories.name, categories.slug, 
            categories.parent_id, path_names || categories.name, path_ids || categories.id
    FROM search_tree
    JOIN categories ON categories.parent_id = search_tree.id
    WHERE NOT categories.id = ANY(path_ids)
  ),
  
  tree_nodes AS (
	    SELECT *,
	    lower(array_to_string(path_names, ' ')) as sort_name,
	    (SELECT array_agg(st.id) FROM search_tree AS st WHERE search_tree.id = ANY(st.path_ids)) AS tree_ids
	  FROM search_tree ORDER BY sort_name ASC
  )
  
  SELECT *,
    (SELECT json_build_object(
	      'active', COUNT(DISTINCT categorizations.item_id) FILTER (WHERE items.status = 'active'),
	      'retired', COUNT(DISTINCT categorizations.item_id) FILTER (WHERE items.status = 'pending'),
	      'maintenance', COUNT(DISTINCT categorizations.item_id) FILTER (WHERE items.status = 'maintenance'),
	      'pending', COUNT(DISTINCT categorizations.item_id) FILTER (WHERE items.status = 'retired')
	    ) 
  		FROM categorizations LEFT JOIN items ON categorizations.item_id = items.id
  		WHERE categorizations.category_id = ANY(tree_ids)
    ) AS tree_item_counts
  
  from tree_nodes;
WITH RECURSIVE search_tree(id, library_id, name, slug, item_counts, parent_id, path_names, path_ids) AS (

  SELECT id, library_id, name, slug, item_counts, parent_id, ARRAY[name], ARRAY[id]
    FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
    SELECT categories.id, categories.library_id, categories.name, categories.slug, categories.item_counts, 
            categories.parent_id, path_names || categories.name, path_ids || categories.id
    FROM search_tree
    JOIN categories ON categories.parent_id = search_tree.id
    WHERE NOT categories.id = ANY(path_ids)
  )
  
  SELECT *,
    lower(array_to_string(path_names, ' ')) as sort_name,
    (SELECT json_build_object(
      'active', COALESCE(SUM((st.item_counts->'active')::int), 0),
      'retired', COALESCE(SUM((st.item_counts->'retired')::int), 0),
      'maintenance', COALESCE(SUM((st.item_counts->'maintenance')::int), 0),
      'pending', COALESCE(SUM((st.item_counts->'pending')::int), 0)
    ) FROM search_tree AS st WHERE search_tree.id = ANY(st.path_ids)) AS tree_item_counts,
    (SELECT array_agg(st.id) FROM search_tree AS st WHERE search_tree.id = ANY(st.path_ids)) AS tree_ids
  FROM search_tree ORDER BY sort_name ASC;
  WITH RECURSIVE search_tree(id, library_id, name, slug, categorizations_count, parent_id, path_names, path_ids) AS (
        SELECT id, library_id, name, slug, categorizations_count, parent_id, ARRAY[name], ARRAY[id]
        FROM categories
      WHERE parent_id IS NULL
      UNION ALL
        SELECT categories.id, categories.library_id, categories.name, categories.slug, categories.categorizations_count,
               categories.parent_id, path_names || categories.name, path_ids || categories.id
        FROM search_tree
        JOIN categories ON categories.parent_id = search_tree.id
        WHERE NOT categories.id = ANY(path_ids)
      )
      SELECT *,
        (SELECT SUM(st.categorizations_count) from search_tree as st WHERE search_tree.id = ANY(st.path_ids)) as tree_categorizations_count,
        (SELECT array_agg(st.id) from search_tree as st WHERE search_tree.id = ANY(st.path_ids)) as tree_ids
      FROM search_tree ORDER BY path_names;

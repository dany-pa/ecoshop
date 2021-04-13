--DROP FUNCTION "get_products_with_paginaion_and_filters"(integer,integer,integer, integer);
CREATE OR REPLACE FUNCTION "get_products_with_paginaion_and_filters"(
    per_page INTEGER,
    page INTEGER,
    filter_type INTEGER[],
    filter_material INTEGER[]
) 
RETURNS TABLE(
	original_name text,
	name text,
	link citext,
	img text,
	shop integer,
	original_material text,
	material text,
	original_price text,
	price text,
	id integer,
	type integer,
	materials_ids integer[],
	types_ids integer[],
	page_count bigint
)
language plpgsql
AS $$
	DECLARE
        offset_from INTEGER;
		page_count BIGINT;
		products_count BIGINT;
		select_sql TEXT;
		sql_condition TEXT[];
    BEGIN
		DROP TABLE IF EXISTS temp_products;
		CREATE TEMP TABLE IF NOT EXISTS temp_products  (
			original_name text,
			name text,
			link citext,
			img text,
			shop integer,
			original_material text,
			material text,
			original_price text,
			price text,
			id integer,
			type integer,
			materials_ids integer[],
			types_ids integer[]
		);
		select_sql := '
			INSERT INTO temp_products
			SELECT
				p.original_name,
				p.name,
				p.link,
				p.img,
				p.shop,
				p.original_material,
				p.material,
				p.original_price,
				p.price, 
				p.id,
				p.type,
				array_agg(pm.material_id),
				array_agg(pt.type_id)
			FROM
				(
					SELECT 
						* 
					FROM 
						public.products
					WHERE 
						products.is_approved = TRUE
				) as p
			LEFT JOIN products_materials AS pm
			ON p.id = pm.product_id
			LEFT JOIN products_types AS pt
			ON p.id = pt.product_id
			GROUP BY 
				p.original_name,
				p.name,
				p.link,
				p.img,
				p.shop,
				p.original_material,
				p.material,
				p.original_price,
				p.price, 
				p.id,
				p.type
		';
		
		IF filter_type IS NOT NULL THEN
			sql_condition := array_append(sql_condition,  FORMAT('%L && array_agg(pt.type_id)', filter_type));
		END IF;

		IF filter_material IS NOT NULL THEN
			sql_condition := array_append(sql_condition,  FORMAT('%L && array_agg(pm.material_id)', filter_material));
		END IF;

		IF array_length(sql_condition, 1) > 0 THEN
			select_sql := CONCAT(select_sql, ' HAVING ');
		END IF;

		select_sql := CONCAT(select_sql, array_to_string(sql_condition, ' AND '));

		EXECUTE select_sql;
		
		products_count := (SELECT COUNT(*) FROM temp_products);
		page_count := ROUND(products_count / per_page::NUMERIC, 0);
		
		IF products_count > 0 AND page_count = 0 THEN
			page_count := 1;
		END IF;
        offset_from := per_page * (page - 1);
	RETURN QUERY
		SELECT 
			*,
			page_count
		FROM 
			temp_products
		LIMIT
			per_page
		OFFSET
			offset_from
	;
    END;
$$
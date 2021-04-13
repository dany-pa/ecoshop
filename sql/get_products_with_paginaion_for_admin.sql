--DROP FUNCTION "get_products_with_paginaion_for_admin"(integer,integer);
CREATE OR REPLACE FUNCTION "get_products_with_paginaion_for_admin"(
    per_page INTEGER,
    page INTEGER
) 
RETURNS TABLE(
	link citext,
	name text,
	original_name text,
	material text,
	original_material text,
	price text,
	original_price text,
	id integer,
    is_approved BOOLEAN,
    is_checked_name BOOLEAN,
    is_checked_material BOOLEAN,
    is_checked_price BOOLEAN,
	page_count bigint
)
language plpgsql
AS $$
    DECLARE
        offset_from INTEGER;
		page_count BIGINT;
		products_count BIGINT;
    BEGIN		
		products_count := (SELECT count(*) FROM public.products);
		page_count := ROUND(products_count / per_page::NUMERIC, 0);
		
		IF products_count > 0 AND page_count = 0 THEN
            page_count := 1;
		END IF;
		
        offset_from := per_page * (page - 1);
		
	 RETURN QUERY
            SELECT 
                products.link,
                products.name,
                products.original_name,
                products.material,
                products.original_material,
                products.price,
                products.original_price,
                products.id,
                products.is_approved,
                products.is_checked_name,
                products.is_checked_material,
                products.is_checked_price,
                page_count 
            FROM 
                public.products
            ORDER BY 
                products.is_approved DESC, id ASC
            LIMIT
                per_page 
            OFFSET 
                offset_from
		;
    END;
$$
--DROP FUNCTION "set_product_field"(integer,text,text);
CREATE OR REPLACE FUNCTION set_product_field(
    product_id INTEGER,
    field TEXT,
    val TEXT,
	is_update  OUT BOOLEAN
) 
RETURNS BOOLEAN
language plpgsql
AS $$
	DECLARE
		update_sql TEXT;
		update_id INTEGER;
    BEGIN
        IF (
            SELECT 
                COUNT(*)
            FROM 
                INFORMATION_SCHEMA.COLUMNS
            WHERE 
                table_name = 'products'
                AND table_schema = 'public'
                AND column_name = field
        ) THEN
            update_sql := FORMAT('UPDATE public.products SET %s = %L WHERE products.id = %s RETURNING products.id;', field, val, product_id);
            EXECUTE update_sql INTO update_id;
        END IF;
		
		is_update := (update_id IS NOT NULL);
	 RETURN;
    END;
$$
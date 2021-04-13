--DROP FUNCTION "add_product"(text,text,integer,text,text,text);
CREATE OR REPLACE FUNCTION "add_product"(
    product_link CITEXT,
    img TEXT,
    shop INTEGER,
    original_name TEXT,
    original_material TEXT,
    original_price TEXT
) 
RETURNS VOID
language plpgsql
AS $$
    DECLARE
		update_sql TEXT;
	BEGIN
		CREATE TEMP TABLE IF NOT EXISTS product (
			link CITEXT,
			original_name TEXT,
			original_material TEXT,
			original_price TEXT
		);

		INSERT INTO 
			product 
		SELECT 
			"link",
			products."original_name",
			products."original_material",
			products."original_price"
		FROM
			public.products
		WHERE
			products.link = product_link;
			
		UPDATE
			public.products
		SET
			check_dt = NOW()
		WHERE
			products.link = product_link;
		
		IF (SELECT COUNT(*) FROM product) = 0 THEN
			INSERT INTO public.products (
				"link",
				"shop",
				"img",
				"original_name",
				"name",
				"original_material",
				"material",
				"original_price",
				"price"
			)
			VALUES(
				product_link,
				shop,
				img,
				original_name,
				name,
				original_material,
				material,
				original_price,
				price
			);
		ELSE
			IF (SELECT products.original_name FROM product) <> original_name THEN
				update_sql = CONCAT(update_sql, FORMAT(' products.original_name = %L ', original_name));
				update_sql = CONCAT(update_sql, ', products.is_checked_name = true');
			END IF;

			IF (SELECT products.original_material FROM product) <> original_material THEN
				IF update_sql <> '' THEN
					update_sql = CONCAT(update_sql, ' , ');
				END IF;
				
				update_sql = CONCAT(update_sql, FORMAT(' products.original_material = %L ', original_material));
				update_sql = CONCAT(update_sql, ', products.is_checked_material = true');
			END IF;

			IF (SELECT products.original_price FROM product) <> original_price THEN
				IF update_sql <> '' THEN
					update_sql = CONCAT(update_sql, ' , ');
				END IF;

				update_sql = CONCAT(update_sql, FORMAT(' products.original_price = %L ', original_price));
				update_sql = CONCAT(update_sql, ', products.is_checked_price = true');
			END IF;

			IF update_sql <> '' THEN
				update_sql = CONCAT('UPDATE public.products SET ', update_sql);
				update_sql = CONCAT(update_sql, ', products.update_dt = NOW()');
				update_sql = CONCAT(update_sql, FORMAT(' WHERE products.link = %L', product_link));
				EXECUTE update_sql;
			END IF;

		END IF;
		
		DROP TABLE product;
    END;
$$
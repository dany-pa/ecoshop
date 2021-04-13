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
		8::BIGINT
	FROM
		(
            SELECT 
                * 
            FROM 
                public.products
            WHERE 
                products.is_approved = TRUE
            LIMIT 
                2 
            OFFSET 
                0
		) AS p 
		LEFT JOIN products_materials AS pm
		ON p.id = pm.product_id
	
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

/*
FROM 
    public.products  WHERE products.is_approved = TRUE  LIMIT 2 OFFSET 0
	*/
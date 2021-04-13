INSERT INTO public.products_types(
	product_id, 
	type_id
)
VALUES (155, 1);



INSERT INTO public.materials(
	name
)
	VALUES ('Тест');

SELECT * FROM public.materials;

INSERT INTO public.item_types(
	name
)
	VALUES ('Тест');

SELECT * FROM public.item_types;

/*
INSERT INTO public.shops(
	name
)
VALUES ('Botanita');
*/


INSERT INTO public.products_materials(
	product_id, 
	material_id
)
VALUES (152, 2);
SELECT * FROM public.products_materials;


--CREATE EXTENSION IF NOT EXISTS citext; 
--ALTER TABLE public.products ALTER COLUMN link TYPE citext;  
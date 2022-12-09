-- 2. Escreva uma consulta MySQL para:
-- - Contar o número de imóveis que tiveram aumento de preço em 2016 e o aumento médio do percentual de preço/m² desses imóveis;
-- - Contar o número de imóveis que tiveram um decréscimo de preço em 2016 e a diminuição média da percentagem de preço/m2 desses imóveis;

-- Exibe tabela original com variações de preços

SELECT * FROM price_changes;

-- Notar que muitos imóveis mudaram de preço mais de uma vez ao longo de 2016

select count, COUNT(b.count) FROM (
	SELECT listing_id,COUNT(listing_id) as count 
	FROM price_changes
	WHERE YEAR(change_date) = 2016
	GROUP BY listing_id 
	ORDER BY count DESC) b
GROUP BY b.count
ORDER BY b.count DESC;

-- cria tabela auxiliar contendo o último preço de 2016 para cada imóvel (com mudança de preço em 2016)

CREATE TABLE price_changes_2016_max_aux
AS
SELECT a.listing_id, a.new_price as last_price
FROM price_changes a
        INNER JOIN 
        (
            SELECT listing_id, MAX(change_date) max_date
            FROM price_changes
            WHERE YEAR(change_date) = 2016
            GROUP BY listing_id
        ) b ON a.listing_id = b.listing_id
                AND a.change_date = b.max_date
;

select * from price_changes_2016_max_aux;

-- cria tabela auxiliar contendo o primeiro preço de 2016 para cada imóvel (com mudança de preço em 2016)

CREATE TABLE price_changes_2016_min_aux
AS
SELECT a.listing_id, a.old_price as first_price
FROM price_changes a
        INNER JOIN 
        (
            SELECT listing_id, MIN(change_date) min_date
            FROM price_changes
            WHERE YEAR(change_date) = 2016
            GROUP BY listing_id
        ) b ON a.listing_id = b.listing_id
                AND a.change_date = b.min_date
;

-- cria tabela auxiliar unindo as duas criadas anteriormentes

CREATE TABLE price_changes_2016_aux
AS
SELECT pmax.listing_id, pmin.first_price, pmax.last_price 
FROM price_changes_2016_max_aux pmax
JOIN price_changes_2016_min_aux pmin ON pmax.listing_id = pmin.listing_id;

-- Exibe tabela auxiliar

SELECT * FROM price_changes_2016_aux;

-- Deleta linhas nas quais o preço inicial é zero
SELECT * FROM price_changes_2016_aux WHERE first_price = 0;
DELETE FROM price_changes_2016_aux WHERE first_price = 0;

-- Preços por metro quadrado

CREATE TABLE price_changes_2016_aux_by_m2
AS
SELECT 
	p.*, 
    f.fixed_built_area, 
	TRUNCATE((p.first_price/f.fixed_built_area), 2) as 'first_price_by_m2', 
	TRUNCATE((p.last_price/f.fixed_built_area), 2) as 'last_price_by_m2' 
FROM price_changes_2016_aux p
JOIN fixed_built_area f ON p.listing_id=f.listing_id;

SELECT * FROM price_changes_2016_aux_by_m2;

-- Contar o número de imóveis que tiveram aumento de preço em 2016 e o aumento médio do percentual de preço/m² desses imóveis
-- Contar o número de imóveis que tiveram um decréscimo de preço em 2016 e a diminuição média da percentagem de preço/m2 desses imóveis;

SELECT p_inc.count AS 'Número de imóveis com aumento de preço em 2016', 
	   p_inc.delta AS 'Percentual médio de aumento de preço/m² desses imóveis',
	   p_dec.count AS 'Número de imóveis com redução de preço em 2016',
	   p_dec.delta AS 'Percentual médio de redução de preço/m² desses imóveis'
FROM (	
	SELECT 
		COUNT(listing_id) AS count,
		AVG(((last_price_by_m2/first_price_by_m2)-1)*100) AS delta
	FROM price_changes_2016_aux_by_m2
	WHERE last_price > first_price
) p_inc, 
(
	SELECT 
		COUNT(listing_id) AS count,
		ABS(AVG(((last_price_by_m2/first_price_by_m2)-1)*100)) AS delta
	FROM price_changes_2016_aux_by_m2
	WHERE last_price < first_price
) p_dec
;

-- Dados "incoerentes": imóveis com aumento de 1000%

SELECT * FROM price_changes_2016_aux_by_m2
WHERE ((last_price_by_m2/first_price_by_m2)-1)*100 > 1000;

-- Exemplo de dados "incoerentes" mostrados diretamente na tabela original

SELECT * FROM price_changes
WHERE listing_id IN (350789, 363170);

-- Drop das tabelas auxiliares

DROP TABLE price_changes_2016_max_aux;
DROP TABLE price_changes_2016_min_aux;
DROP TABLE price_changes_2016_aux;
DROP TABLE price_changes_2016_aux_by_m2;
DROP TABLE fixed_built_area;
-- ...
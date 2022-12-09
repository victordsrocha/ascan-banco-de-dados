-- 1. Escreva uma consulta MySQL para calcular o preço médio do metro quadrado dos imóveis com aumento de preço em 2016 que tenham 
--    uma área do metro quadrado > 200 (área construída ou usada).

-- Exibe tabela de áreas original
SELECT * FROM built_used_area;

-- Cria tabela auxiliar preenchendo os valores nulos (ou zero) de área construída com o valor de área usada (pois a area construída é sempre maior ou igual à área usada)
-- caso ambos sejam nulos, a linha é deletada

CREATE TABLE fixed_built_area
AS
SELECT listing_id, fixed_built_area FROM (
	SELECT listing_id, built_area, used_area,
		CASE built_area
		WHEN NULL THEN used_area
		WHEN 0 THEN used_area
		ELSE built_area
		END AS fixed_built_area
	FROM built_used_area) temp
WHERE fixed_built_area>0 AND fixed_built_area IS NOT NULL;

-- Insere um índice na tabela auxiliar

ALTER TABLE fixed_built_area ADD COLUMN id INT PRIMARY KEY AUTO_INCREMENT FIRST;

SELECT * FROM fixed_built_area;

-- Notar que existem imóveis repetidos!

SELECT 
    listing_id, 
    COUNT(listing_id)
FROM
    fixed_built_area
GROUP BY listing_id
HAVING COUNT(listing_id) > 1;

-- isto ocorre na tabela original
-- - Exemplo:
select * from built_used_area where listing_id = 290406;
select * from built_used_area where listing_id = 279299;

-- Optei por não alterar a tabela original e fazer o tratamento de linhas duplicadas somente na tabela auxiliar!

-- Deleta linhas duplicadas da tabela auxiliar
--  Se um mesmo imóvel possui duas linhas com tamanhos diferentes, podemos interpretar que o imóvel passou por uma mudança
--  Se as duas linhas são completamente iguais, manterei somente uma

DELETE t1 FROM fixed_built_area t1
INNER JOIN fixed_built_area t2
WHERE
    t1.id < t2.id AND
    t1.listing_id = t2.listing_id AND
    t1.fixed_built_area = t2.fixed_built_area;

-- Exibe tabela auxiliar

SELECT * FROM fixed_built_area;

-- Consulta MySQL para calcular o preço médio do metro quadrado dos imóveis com aumento de preço em 2016 que tenham 
-- uma área do metro quadrado > 200 (área construída ou usada)

-- Cada imóvel pode contar mais de uma vez se sofreu mais de uma alteração de preço em 2016

SELECT AVG(p.new_price/f.fixed_built_area) as 'Preço médio do metro quadrado' FROM price_changes p
JOIN fixed_built_area f ON p.listing_id = f.listing_id
WHERE YEAR(change_date) = 2016
AND f.fixed_built_area > 200;

-- Drop da coluna auxiliar

-- DROP TABLE fixed_built_area;
-- Não executar o drop! A tabela fixed_built_area será reutilizada na questão 02!

-- ...
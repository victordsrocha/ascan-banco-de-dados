-- show global variables like 'local_infile';
-- set global local_infile=true;

-- Criação do banco de dados

DROP DATABASE desafio;

CREATE DATABASE desafio;
USE desafio;

-- Criação da tabela built_used_area

CREATE TABLE built_used_area (
	id int NOT NULL AUTO_INCREMENT,
	listing_id int NOT NULL,
    built_area int,
    used_area int,
    PRIMARY KEY (id));

load data local infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Built_used_area.csv' 
into table built_used_area 
fields terminated by ';'
lines terminated by '\r\n'
IGNORE 1 LINES
	(listing_id, @built_area, @used_area)
SET
	built_area = nullif(@built_area,'NULL'),
    used_area = nullif(@used_area,'NULL');

select * from built_used_area;

-- Criação da tabela price_changes

CREATE TABLE price_changes (
	id INT NOT NULL AUTO_INCREMENT,
	listing_id INT NOT NULL,
    old_price INT,
    new_price INT,
    change_date DATE,
    details VARCHAR(2000),
    PRIMARY KEY (id));
    
load data local infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Price_changes.csv' 
into table price_changes 
fields terminated by '\t'
lines terminated by '\n'
IGNORE 1 LINES
(listing_id, @old_price, new_price, change_date, details)
SET
old_price = nullif(@old_price,'');

select * from price_changes;
select * from price_changes where old_price IS NULL; -- old price pode ser nulo
select * from price_changes where old_price = 0; -- old price pode ser zero

-- Criação da tabela details

-- Foi necessário alterar o arquivo original pois o separador ";" ocorria em alguns valores da coluna "Details"
-- Solução: substituir a primeira ocorrência de ";" por "\t".

CREATE TABLE details (
	id INT NOT NULL AUTO_INCREMENT,
	listing_id INT NOT NULL,
    Details VARCHAR(2000),
    PRIMARY KEY (id));

load data local infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\new_details.csv' 
into table details 
fields terminated by '\t'
lines terminated by '\n'
IGNORE 1 LINES
(listing_id, Details);

select * from details;
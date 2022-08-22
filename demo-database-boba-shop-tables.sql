/*
 "Teava Boba Shop" Demo Database for Github SQL Portfolio
 Created by Elyzza Bobadilla in MySQL
 **table creation queries not in order**
*/

/* Creating a Menu Table */
CREATE TABLE IF NOT EXISTS practice_db.BobaShopMenu ( # 'if not exists' is a failsafe practice
product_id int AUTO_INCREMENT PRIMARY KEY,
drink_title varchar(255) NOT NULL,
drink_type varchar(10) NOT NULL,
price decimal(2,2),
addon tinytext,
sizes varchar(3),
season tinytext,
dairy enum('yes','no','varies')
);

ALTER TABLE bobashopmenu
MODIFY price decimal(6,4); # change the decimal type to accurately encompass price


/* Inserting Data into the Menu Table */
INSERT INTO bobashopmenu (
drink_title, drink_type, price, addon, sizes, season, dairy
)
VALUES (
('brown sugar milk tea','iced','04.00','black boba','SML','all','no'),
('green milk tea','iced','4.00','crystal boba','SML','all','no'),
('thai tea','iced','4.00','black boba','SML','all','varies')
);

INSERT INTO bobashopmenu # be mindful when inserting without specifying columns, need to account for primary key
VALUES (
('4','lemonade','iced','3.5','cherry pops','SML','all','no'),
('5','hot cocoa','hot','3.5','marshmallows','SM','fall, winter','yes'),
('6','passionfruit green tea','iced','3.5','mango pops','SML','all','no'),
('7','pumpkin spiced chai','hot','4.25','whipped cream','SM','fall, winter','yes')
);

INSERT INTO bobashopmenu (drink_title, drink_type, price, sizes, season, dairy)
VALUES (
('citrus dream','frozen','4.5','M','summer','yes'),
('yakult crush','frozen','4.75','M','spring, summer','yes'),
('strawberry mango smoothie','frozen','4.75','ML','summer','varies')
);


/* Creating a New Table for Customer Information */
CREATE TABLE IF NOT EXISTS practice_db.customer (
customer_id int AUTO_INCREMENT PRIMARY KEY,
first_name varchar(45),
last_name varchar(45),
phone_number varchar(20),
email varchar(50),
first_visit date, -- 'yyyy-mm-dd'
first_vist_year year
);

-- rename a misspelled column name
ALTER TABLE customer
RENAME COLUMN first_vist_year TO first_visit_year;

-- slight change to primary key (removed auto increment due to data insertion queries throwing errors)
ALTER TABLE customer
MODIFY customer_id int;

-- add another column to Customer table for location
ALTER TABLE customer
ADD COLUMN location_id varchar(10);

/* Creating the Second Location Customer Table */
CREATE TABLE IF NOT EXISTS practice_db.customer2 (
customer_id int PRIMARY KEY,
first_name varchar(45),
last_name varchar(45),
phone_number varchar(20),
email varchar(50),
first_visit date, -- 'yyyy-mm-dd'
first_vist_year year,
location_id varchar(10)
);

/* Inserting Customer Data */
-- insert first row of data
INSERT INTO customer # this query took a while to pass with auto increment
VALUES
('1','Wendy','Park','310-551-1555','wendyp@hotmail.com','2020-07-01','2020');

-- insert more customer data
INSERT INTO customer # this one also took a while so I removed 1) parenthesis encompassing all values and 2) specific column names being inserted into
VALUES
('2','Sophia','Cortez','424-144-4441','scortez@gmail.com','2020-07-05','2020'),
('3','Victor','Vaughn','310-331-1334','victor.vaughn@gmail.com','2021-05-10','2021'),
('4','Kent','Bradshaw','424-122-2221','kbradshaw1@outlook.com','2022-02-14','2022')
;

-- insert data into location_id for customer table
UPDATE customer
SET location_id = 'A'
WHERE customer_id = 4;

-- insert data into the second customer table
INSERT INTO customer2
VALUES ('1','Melissa','Alvarez','310-133-3331','wendyp@hotmail.com','2020-07-13','2020','B'),
('2','James','Tran','424-441-1444','scortez@gmail.com','2021-08-01','2021','B'),
('3','Kailey','Leighton','310-522-2255','victor.vaughn@gmail.com','2022-05-14','2022','B'),
('4','Rhys','Norton','424-355-1278','kbradshaw1@outlook.com','2022-06-23','2022','B');


/* Creating a New Table for Order Information */
CREATE TABLE IF NOT EXISTS practice_db.orders (
order_item_id int PRIMARY KEY,
customer_id int,
product_id int,
FOREIGN KEY (customer_id) REFERENCES customer(customer_id), # points to where the foreign key lives, also works as customer.customer_id instead of parenthesis
FOREIGN KEY (product_id) REFERENCES bobashopmenu(product_id)
);

-- add new column for date/time
ALTER table orders
ADD COLUMN order_date datetime;

-- rename misspelled column
ALTER table customer2
RENAME COLUMN first_vist_year TO first_visit_year;

-- add foreign key to existing tables
ALTER table customer2
ADD FOREIGN KEY (location_id) REFERENCES shoplocations(location_id);

/* Inserting Order Data */
INSERT INTO orders # prior to adding order_date column
VALUES
('1','2','1'),
('2','3','2'),
('3','3','7'),
('4','4','9'),
('5','1','4')
;

-- update the table to add datetime data
UPDATE orders
SET order_date = '2022-08-01 11:11:05'
WHERE order_item_id = 1;

UPDATE orders
SET order_date = '2022-08-03 15:15:25'
WHERE order_item_id = 2;

UPDATE orders
SET order_date = '2022-08-03 18:01:27'
WHERE order_item_id = 3;

UPDATE orders
SET order_date = '2022-08-21 13:30:00'
WHERE order_item_id = 4;

UPDATE orders
SET order_date = '2022-08-21 17:05:03'
WHERE order_item_id = 5;

-- add location data
UPDATE orders
SET location_id = 'A'
WHERE order_item_id IN ('1','2','3','4','5');

-- add more order data
INSERT INTO orders
VALUES
('6','1','3','2022-08-22 11:15:00','B'),
('7','2','5','2022-08-22 11:18:30','B'),
('8','3','2','2022-08-22 12:30:30','B'),
('9','4','8','2022-08-22 14:20:22','B'),
('10','1','7','2022-08-22 16:30:01','B')
;


/* Creating a New Table for Shop Locations */
CREATE TABLE IF NOT EXISTS practice_db.ShopLocations (
location_id varchar(10),
shop_title varchar(50),
address varchar(50),
city varchar(50),
state varchar(50),
zipcode varchar(10),
phone_number varchar(20)
);

-- make location_id a primary key
ALTER table shoplocations
MODIFY location_id varchar(10) PRIMARY KEY;


/* Inserting Data into the Shop Locations table */
INSERT INTO shoplocations
VALUES
('A','Teava On Main','2612 Main St','Santa Monica','CA','90405','310-100-1100'),
('B','Teava On Arizona','1925 Arizona Ave','Santa Monica','CA','90404','424-100-1000');

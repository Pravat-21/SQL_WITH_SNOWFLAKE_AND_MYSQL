USE DATABASE PP_PRACTICE;
-----------------------------------------------------------------------------
CREATE OR REPLACE TABLE production.categories (
	category_id INT IDENTITY(1,1)  PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);

CREATE OR REPLACE TABLE production.brands (
	brand_id INT IDENTITY(1,1) PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);
CREATE OR REPLACE  TABLE production.products (
	product_id INT IDENTITY(1,1) PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES production.categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES production.brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE OR REPLACE TABLE sales.customers (
	customer_id INT IDENTITY(1,1) PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5)
);

CREATE OR REPLACE TABLE sales.stores (
	store_id INT IDENTITY(1,1) PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5)
);
CREATE OR REPLACE  TABLE sales.staffs (
	staff_id INT IDENTITY(1,1) PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE OR REPLACE TABLE sales.orders (
	order_id INT IDENTITY(1,1) PRIMARY KEY,
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES sales.customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (staff_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE OR REPLACE  TABLE sales.order_items (
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (order_id, item_id),
	FOREIGN KEY (order_id) REFERENCES sales.orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE OR REPLACE TABLE production.stocks (
	store_id INT,
	product_id INT,
	quantity INT,
	PRIMARY KEY (store_id, product_id),
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);


SELECT COUNT(*) FROM PP_PRACTICE.SALES.CUSTOMERS;-- 1445
SELECT COUNT(*) FROM PP_PRACTICE.SALES.order_items; -- 4722 
SELECT COUNT(*) FROM PP_PRACTICE.SALES.orders; -- 1615 
SELECT COUNT(*) FROM PP_PRACTICE.SALES.staffs; -- 10
SELECT COUNT(*) FROM PP_PRACTICE.SALES.stores;-- 3

SELECT COUNT(*) FROM PP_PRACTICE.PRODUCTION.brands;-- 9
SELECT COUNT(*) FROM PP_PRACTICE.PRODUCTION.categories;-- 7
SELECT COUNT(*) FROM PP_PRACTICE.PRODUCTION.products;-- 321 
SELECT COUNT(*) FROM PP_PRACTICE.PRODUCTION.stocks; -- 939

---------------------------MASTER TABLE CREATION OF BIKESTORE------------------------------------
CREATE OR REPLACE TABLE PP_MASTER_BIKESTORE AS 
SELECT DISTINCT CUS.customer_id,O.order_id,CUS.first_name,CUS.last_name,CUS.phone,CUS.email,CUS.street,CUS.city,CUS.state,CUS.zip_code,
PRO.product_name,PRO.model_year,O.order_status,O.order_date,O.required_date,O.shipped_date,
ST.store_name,OI.quantity,OI.list_price,OI.discount
FROM PP_PRACTICE.SALES.order_items OI
LEFT OUTER JOIN PP_PRACTICE.SALES.orders O ON OI.ORDER_ID=O.ORDER_ID
LEFT OUTER JOIN PP_PRACTICE.SALES.CUSTOMERS CUS ON O.CUSTOMER_ID=CUS.CUSTOMER_ID
LEFT OUTER JOIN PP_PRACTICE.PRODUCTION.products PRO ON OI.PRODUCT_ID=PRO.PRODUCT_ID
LEFT OUTER JOIN PP_PRACTICE.SALES.stores ST ON O.STORE_ID=ST.STORE_ID
LEFT OUTER JOIN PP_PRACTICE.PRODUCTION.stocks STO ON ST.STORE_ID=STO.STORE_ID AND PRO.PRODUCT_ID=STO.PRODUCT_ID
LEFT OUTER JOIN PP_PRACTICE.SALES.staffs STA ON O.STAFF_ID=STA.STAFF_ID
LEFT OUTER JOIN PP_PRACTICE.PRODUCTION.brands BR ON PRO.BRAND_ID=BR.BRAND_ID
LEFT OUTER JOIN PP_PRACTICE.PRODUCTION.categories CAT ON PRO.CATEGORY_ID=CAT.CATEGORY_ID;

SELECT DISTINCT * FROM PP_MASTER_BIKESTORE; --PP_PRACTICE.PUBLIC.PP_MASTER_BIKESTORE
---------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE PP_MASTER_BIKESTORE_COPY AS 
SELECT * FROM PP_MASTER_BIKESTORE;

SELECT * FROM PP_MASTER_BIKESTORE_COPY;

UPDATE PP_MASTER_BIKESTORE_COPY
SET PHONE = NULL WHERE PHONE='NULL';

SELECT PRODUCT_NAME,REPLACE(PRODUCT_NAME,'_','-') AS PEPLACED_PRODUCT_NAME FROM PP_MASTER_BIKESTORE_COPY;


UPDATE PP_MASTER_BIKESTORE_COPY
SET PRODUCT_NAME = REPLACE(PRODUCT_NAME,'_','-');
SELECT * FROM PP_MASTER_BIKESTORE_COPY;

SELECT *,ROUND((LIST_PRICE-(LIST_PRICE*DISCOUNT))*QUANTITY,2) AS TOTAL_AMOUNT_PAID FROM PP_MASTER_BIKESTORE_COPY;

ALTER TABLE PP_MASTER_BIKESTORE_COPY
ADD COLUMN TOTAL_AMOUNT_PAID DECIMAL(10,3);

UPDATE PP_MASTER_BIKESTORE_COPY
SET TOTAL_AMOUNT_PAID=ROUND((LIST_PRICE-(LIST_PRICE*DISCOUNT))*QUANTITY,2);
------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT * FROM PP_PRACTICE.PUBLIC.PP_CUST_SALES_ORDER_MASTER;

-- TOTAL ORDERS YEAR WISE
SELECT DISTINCT YEAR(ORDER_DATE) FROM PP_PRACTICE.PUBLIC.PP_CUST_SALES_ORDER_MASTER;
SELECT YEAR(ORDER_DATE) AS YEAR_NO ,COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDER FROM PP_CUST_SALES_ORDER_MASTER
GROUP BY YEAR_NO;

-- HOW MANY ORDERS EACH CUSTOMER HAS PLACED?
SELECT DISTINCT CUSTOMER_ID ,CONCAT(FIRST_NAME,' ',LAST_NAME)AS CUSTOMER_NAME, COUNT(ORDER_ID) AS TOTAL_ORDER FROM PP_CUST_SALES_ORDER_MASTER
GROUP BY 1,2;

--WHICH IS THE HIGHEST/TOP 3 SELLING  PRODUCT
SELECT * FROM PP_CUST_SALES_ORDER_MASTER;

SELECT DISTINCT(PRODUCT_NAME) AS PRODUCT_NAME,COUNT(QUANTITY) AS TOTAL_NO_ORDERS FROM PP_CUST_SALES_ORDER_MASTER
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

/*SELECT product_name,COUNT(DISTINCT ORDER_ID) AS TOT_ORDERS
FROM  PP_CUST_SALES_ORDER_MASTER
GROUP BY product_name
ORDER BY TOT_ORDERS DESC
LIMIT 3;*/
-- LAST 3 ORDERS DETAILS FROM EVERY CUSTOMER
-- CANT BNE DONE --USING WINDOW FUNCTONS ???.
SELECT A.* FROM
(SELECT DISTINCT(CUSTOMER_ID) AS CUSTOMER_ID,CONCAT(FIRST_NAME,' ',LAST_NAME)AS CUS_FULL_NAME,
ORDER_ID,ORDER_STATUS,ORDER_DATE,SHIPPED_DATE,QUANTITY,LIST_PRICE , ROW_NUMBER()OVER(PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE DESC) AS ROW_NO FROM PP_CUST_SALES_ORDER_MASTER)A WHERE A.ROW_NO<=3;

--FOR EVERY CUSTOMER , TELL THE CHEAPEST PRODUCT AND THE COSTLIEST PRODUCT HE/SHE HAS BOUGHT

SELECT DISTINCT(CUSTOMER_ID) AS CUSTOMER_ID,CONCAT(FIRST_NAME,' ',LAST_NAME)AS CUS_FULL_NAME,
MAX(LIST_PRICE) AS COSTLIEST_PRICE,
MIN(LIST_PRICE) AS CHEAPEST_PRICE FROM PP_CUST_SALES_ORDER_MASTER
GROUP BY 1,2
ORDER BY 1,2
;

/*SELECT CUSTOMER_ID,FIRST_NAME,LAST_NAME,PRODUCT_NAME,
MIN(LIST_PRICE)OVER(PARTITION BY CUSTOMER_ID ORDER BY CUSTOMER_ID) AS RN FROM PP_CUST_SALES_ORDER_MASTER ORDER BY CUSTOMER_ID;*/

-- TOTAL ORDERS PRODUCT WISE WHOSE ORDERS IS MORE THAN 200
SELECT * FROM PP_CUST_SALES_ORDER_MASTER;

SELECT DISTINCT (PRODUCT_NAME) AS PRODUCT_NAME, COUNT(ORDER_ID) AS ORDER_COUNT FROM PP_CUST_SALES_ORDER_MASTER
GROUP BY 1
HAVING ORDER_COUNT>150
ORDER BY ORDER_COUNT DESC
;

-- STORE WISE ORDERS
SELECT DISTINCT(STORE_NAME) AS STORE_NAME , COUNT(ORDER_ID) AS ORDER_NO
FROM PP_CUST_SALES_ORDER_MASTER GROUP BY 1 ORDER BY 2;

-- TO FIND TOTAL PRICE FOR EVERY CUSTOMER





-- LETS DECIDE THE TOTAL_PRICE BUCKET
-- LOW_PRICE 0 -5000
-- MEDIUM_PRICE 5000 - 15000
-- HIGH_PRICE > 15000

SELECT DISTINCT(CUSTOMER_ID) AS CUSTOMER_ID,FIRST_NAME,LAST_NAME,LIST_PRICE,
CASE
    WHEN LIST_PRICE<=5000 THEN 'LOW PRICE'
    WHEN LIST_PRICE>5000 AND LIST_PRICE<=15000 THEN 'MEDIUM PRICE'
    ELSE 'HIGH PRICE'
END AS PRICE_BUCKET
FROM PP_CUST_SALES_ORDER_MASTER ORDER BY CUSTOMER_ID;














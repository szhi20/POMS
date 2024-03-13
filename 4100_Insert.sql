select * from cut_data
select count(*) from cut_data

-- Country Table -- DONE
drop sequence seq_cut_country
Create sequence seq_cut_country

INSERT INTO cut_country (country_pk, country_name)
    SELECT seq_cut_country.NEXTVAL,
    country
from (
    select country
        from (select 'United States' country from dual
                )
                minus
                select country_name from cut_country
    )
    
select * from cut_country
    
-- Region Table DONE

drop sequence seq_cut_region
Create sequence seq_cut_region

INSERT INTO cut_region (region_pk, region_name, country_fk)
    SELECT seq_cut_region.NEXTVAL AS region_id, region, 1
    FROM (
        SELECT DISTINCT region AS region
        FROM cut_stage
        MINUS
        SELECT region_name
        from cut_region
    )

select * from cut_region


-- State Table  -- DONE
DROP SEQUENCE seq_cut_state;
CREATE SEQUENCE seq_cut_state;

INSERT INTO cut_state (state_pk, state_name, region_fk)
    SELECT seq_cut_state.NEXTVAL AS state_pk, stt.state, reg.region_pk
    FROM (
        SELECT DISTINCT state, region
        FROM cut_stage
        MINUS
        SELECT state_name, region_name
        FROM cut_state
        JOIN cut_region ON cut_state.region_fk = cut_region.region_pk
    ) stt
    JOIN cut_region reg ON stt.region = reg.region_name;

select * from cut_state


-- Segment table DONE
drop SEQUENCE seq_cut_segment;
CREATE SEQUENCE seq_cut_segment;
delete from cut_segment

INSERT INTO cut_segment (segment_pk, segment)
    SELECT seq_cut_segment.NEXTVAL AS segment_pk, seg.segment
    FROM (
        SELECT DISTINCT segment
        FROM cut_stage
        MINUS
        SELECT segment
        FROM cut_segment
    ) seg;

select * from cut_segment
  


-- Customer Table  -- DONE
DELETE FROM cut_customer;
DROP SEQUENCE seq_cut_customer;
CREATE SEQUENCE seq_cut_customer;

INSERT INTO cut_customer (customer_pk, customer_id, first_name, last_name, segment_fk)
    SELECT seq_cut_customer.NEXTVAL AS customer_pk, 
           cust.customer_id as customer_id, 
           INITCAP(TRIM(SUBSTR(cust.customer_name, 1, INSTR(cust.customer_name, ' ') - 1))) AS first_name,
           INITCAP(TRIM(SUBSTR(cust.customer_name, INSTR(cust.customer_name, ' ') + 1))) AS last_name,
           seg.segment_pk
    FROM (
        SELECT DISTINCT customer_id, customer_name, segment
        FROM cut_stage
        MINUS
        SELECT customer_id, first_name || ' ' || last_name AS customer_name, seg.segment
        FROM cut_customer
        JOIN cut_segment seg ON cut_customer.segment_fk = seg.segment_pk
    ) cust
    JOIN cut_segment seg ON cust.segment = seg.segment;

-- Review the inserted data
SELECT * FROM cut_customer;

select count(*) from cut_customer --793
select * from cut_customer --793

select distinct count(customer_id) from cut_stage
select distinct customer_id from cut_stage --793



-- Address Table   -- DONE
delete from cut_address; 
DROP SEQUENCE seq_cut_address;
CREATE SEQUENCE seq_cut_address START WITH 1;


INSERT INTO cut_address (addrecut_pk, city, postal_code, state_fk, customer_fk)
SELECT seq_cut_address.NEXTVAL AS addrecut_pk, 
       ad.city, 
       ad.postal_code, 
       stt.state_pk, 
       cust.customer_pk
FROM (
    SELECT DISTINCT stage.city, stage.postal_code, stage.state, stage.customer_id
    FROM cut_stage stage
    MINUS
    SELECT addr.city, addr.postal_code, stt.state_name, cust.customer_id
    FROM cut_address addr
    JOIN cut_state stt ON addr.state_fk = stt.state_pk
    JOIN cut_customer cust ON addr.customer_fk = cust.customer_pk
) ad
JOIN cut_state stt ON ad.state = stt.state_name
JOIN cut_customer cust ON ad.customer_id = cust.customer_id; --4910



select * from cut_stage
select * from cut_address
order by addrecut_pk desc
select count(*) from cut_address -- 4910


-- order table -- DONE
DELETE FROM cut_order;
DROP SEQUENCE seq_cut_order;

CREATE SEQUENCE seq_cut_order START WITH 1;


INSERT INTO cut_order (order_pk, order_id, order_date, customer_fk)
SELECT seq_cut_order.NEXTVAL AS order_pk, 
       ord.order_id, 
       ord.order_date, 
       cust.customer_pk
FROM (
    SELECT DISTINCT order_id, order_date, customer_id
    FROM cut_stage
    MINUS
    SELECT ord.order_id, ord.order_date, cust.customer_id
    FROM cut_order ord
    JOIN cut_customer cust ON ord.customer_fk = cust.customer_pk
) ord
JOIN cut_customer cust ON ord.customer_id = cust.customer_id;


select count(distinct order_id) from cut_stage --5009
select * from cut_order
ORDER BY order_pk desc
select count(*) from cut_order -- 5009

-- shipmode table DONE
delete from cut_shipmode;

DROP SEQUENCE seq_cut_shipmode;
CREATE SEQUENCE seq_cut_shipmode;

INSERT INTO cut_shipmode (shipmode_pk, shipmode)
    SELECT seq_cut_shipmode.NEXTVAL AS shipmode_pk, sm.shipmode
    FROM (
        SELECT DISTINCT Ship_Mode AS shipmode
        FROM cut_stage
        MINUS
        SELECT shipmode
        FROM cut_shipmode
    ) sm; -- 4

select * from cut_shipmode
select count(distinct ship_mode) from cut_stage -- 4

-- shipment table  -- DONE
DELETE FROM cut_shipment;
DROP SEQUENCE seq_cut_shipment;
CREATE SEQUENCE seq_cut_shipment START WITH 1;



INSERT INTO cut_shipment (shipment_pk, shipdate, order_fk, shipmode_fk)
    SELECT seq_cut_shipment.NEXTVAL AS shipment_pk,
           sh.ship_date AS shipdate,
           ord.order_pk AS order_fk,
           sm.shipmode_pk AS shipmode_fk
    FROM (
        SELECT DISTINCT ship_date, order_id, ship_mode
        FROM cut_stage
        MINUS
        SELECT ship.shipdate, 
               ord.order_id,
               sm.shipmode
        FROM cut_shipment ship
        JOIN cut_order ord ON ship.order_fk = ord.order_pk
        JOIN cut_shipmode sm ON ship.shipmode_fk = sm.shipmode_pk
    ) sh
    JOIN cut_order ord ON sh.order_id = ord.order_id
    JOIN cut_shipmode sm ON sh.ship_mode = sm.shipmode;


--5009  -- equal to 5009 distinct order_id rows

select * from cut_shipment



-- category table DONE
delete from cut_category;
DROP SEQUENCE seq_cut_category;
CREATE SEQUENCE seq_cut_category;

-- Step 1: Insert main categories
INSERT INTO cut_category (category_pk, category_name)
    SELECT seq_cut_category.NEXTVAL AS category_pk, cate.category_name
    FROM (
        SELECT DISTINCT category AS category_name
        FROM cut_stage
        MINUS
        SELECT category_name
        FROM cut_category
        WHERE category_rid IS NULL
    ) cate; -- 3

-- Step 2: Insert sub-categories -- Use the code from General Help Discussion

insert into cut_category(category_pk, category_name, category_rid)

select seq_cut_category.nextval, sub_category category, category_rid
from (
    select  sub_category, category_pk category_rid
    from cut_stage
       join
         cut_category
    on( cut_stage.category = cut_category.category_name)
    where cut_category.category_rid is null --top category 3
      minus
    select category_name,category_rid
    from cut_category
    where category_rid is not null --sub category 17
    )


select * from cut_category







-- 10_31 Ignore the product id test



-- product table
delete from cut_product;
DROP SEQUENCE seq_cut_product;
CREATE SEQUENCE seq_cut_product START WITH 1;


INSERT INTO cut_product (product_pk, product_name, category_fk)
SELECT seq_cut_product.NEXTVAL AS product_pk, 
       --prod.product_id, 
       prod.product_name, 
       cat.category_pk
FROM (
    SELECT DISTINCT product_name, Category
    FROM cut_stage
    MINUS
    SELECT product_name, cat.category_name
    FROM cut_product prd
    JOIN cut_category cat ON prd.category_fk = cat.category_pk
) prod
JOIN cut_category cat ON prod.Category = cat.category_name; -- 1894 --1842 without product id

/*
INSERT INTO cut_product (product_pk, product_id, product_name, category_fk)
SELECT seq_cut_product.NEXTVAL AS product_pk, 
       prod.product_id, 
       prod.product_name,
       cat.category_pk
FROM (
    SELECT product_id, MIN(product_name) AS product_name, Category
    FROM cut_stage
    GROUP BY product_id, Category
    MINUS
    SELECT prd.product_id, prd.product_name, cat.category_name
    FROM cut_product prd
    JOIN cut_category cat ON prd.category_fk = cat.category_pk
) prod
JOIN cut_category cat ON prod.Category = cat.category_name; -- 1862!!!




select * from cut_product order by product_pk desc

SELECT product_id, 
       COUNT(*) AS occurrences,
       LISTAGG(product_name, ', ') WITHIN GROUP (ORDER BY product_name) AS product_names
FROM cut_product
GROUP BY product_id
HAVING COUNT(*) > 1; -- 32 product_id has duplicate product_name

select * from cut_product where product_id = 'FUR-BO-10002213' -- 2 products appear

select * from cut_stage where product_id = 'OFF-PA-10002377' 

*/



-- order_product table
delete from cut_order_prod;
DROP SEQUENCE seq_cut_order_prod;
CREATE SEQUENCE seq_cut_order_prod START WITH 1;

INSERT INTO cut_order_prod (order_prod_pk, order_fk, product_fk, sales, quantity, discount, profit)
    SELECT seq_cut_order_prod.NEXTVAL AS order_prod_pk, 
           ord.order_pk AS order_fk, 
           prod.product_pk AS product_fk,
           stg.Sales,
           stg.Quantity,
           stg.Discount,
           stg.Profit
    FROM (
        SELECT DISTINCT order_id, product_name, Sales, Quantity, Discount, Profit
        FROM cut_stage
        MINUS
        SELECT ord.order_id, prd.product_name, op.sales, op.quantity, op.discount, op.profit
        FROM cut_order_prod op
        JOIN cut_order ord ON op.order_fk = ord.order_pk
        JOIN cut_product prd ON op.product_fk = prd.product_pk
    ) stg
    JOIN cut_order ord ON stg.order_id = ord.order_id
    JOIN cut_product prod ON stg.product_name = prod.product_name;-- 9993<9994  -- 10220 without product id

/*    
SELECT stg.*
FROM cut_stage stg
LEFT JOIN cut_order_prod op ON stg.row_id = op.order_prod_pk
WHERE op.order_prod_pk IS NULL; -- 1 row appear

INSERT INTO cut_order_prod (order_prod_pk, order_fk, product_fk, sales, quantity, discount, profit)
SELECT seq_cut_order_prod.NEXTVAL AS order_prod_pk, 
       ord.order_pk AS order_fk,
       prod.product_pk AS product_fk,
       stg.Sales,
       stg.Quantity,
       stg.Discount,
       stg.Profit
FROM (
    SELECT stg.*
    FROM cut_stage stg
    LEFT JOIN cut_order_prod op ON stg.row_id = op.order_prod_pk
    WHERE op.order_prod_pk IS NULL
) stg
JOIN cut_order ord ON stg.order_id = ord.order_id
JOIN cut_product prod ON stg.product_id = prod.product_id; -- inserted 1 last row
*/



select * from cut_order_prod order by order_prod_pk desc
select count(*) from cut_order_prod 



SELECT DISTINCT
    ord.order_id,
    cust.customer_id,
    cust.first_name || ' ' || cust.last_name AS customer_name,
    seg.segment,
    addr.city,
    stt.state_name AS state,
    reg.region_name AS region,
    cntry.country_name AS country,
    addr.postal_code,
    prod.product_id,
    prod.product_name,
    cat.category_name AS category,
    subcat.category_name AS sub_category,
    op.sales,
    op.quantity,
    op.discount,
    op.profit,
    shp.shipdate,
    sm.shipmode
FROM cut_order_prod op
JOIN cut_order ord ON op.order_fk = ord.order_pk
JOIN cut_customer cust ON ord.customer_fk = cust.customer_pk
JOIN cut_segment seg ON cust.segment_fk = seg.segment_pk
JOIN cut_address addr ON cust.customer_pk = addr.customer_fk
JOIN cut_state stt ON addr.state_fk = stt.state_pk
JOIN cut_region reg ON stt.region_fk = reg.region_pk
JOIN cut_country cntry ON reg.country_fk = cntry.country_pk
JOIN cut_product prod ON op.product_fk = prod.product_pk
LEFT JOIN cut_category cat ON prod.category_fk = cat.category_pk AND cat.category_rid IS NULL
LEFT JOIN cut_category subcat ON cat.category_pk = subcat.category_rid
LEFT JOIN cut_shipment shp ON shp.order_fk = ord.order_pk
LEFT JOIN cut_shipmode sm ON shp.shipmode_fk = sm.shipmode_pk;

-- Incremental ETL for cut_category
INSERT INTO cut_category (category_id, c_name)
SELECT * FROM
  (SELECT category_id, c_name FROM cut_PROJECT.cut_category 
  WHERE TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) AS dt
ON DUPLICATE KEY UPDATE c_name=dt.c_name;

-- Incremental ETL for cut_customer
INSERT INTO cut_customer (customer_id, c_fname, c_lname, c_city, c_state, c_country, c_pincode, c_segment, region_id)
SELECT * FROM
  (SELECT customer_id, c_fname, c_lname, c_city, c_state, c_country, c_pincode, c_segment, region_id 
  FROM cut_PROJECT.cut_customer
  WHERE TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) AS dt
ON DUPLICATE KEY UPDATE 
    c_fname=dt.c_fname, 
    c_lname=dt.c_lname, 
    c_city=dt.c_city, 
    c_state=dt.c_state, 
    c_country=dt.c_country, 
    c_pincode=dt.c_pincode, 
    c_segment=dt.c_segment, 
    region_id=dt.region_id;


-- INCREMENTAL ETL for cut_market
INSERT INTO cut_market (market_id, m_name)
SELECT * FROM
  (SELECT market_id, m_name FROM cut_PROJECT.cut_market 
  WHERE TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) AS dt
ON DUPLICATE KEY UPDATE m_name=dt.m_name;

-- INCREMENTAL ETL for cut_product
INSERT INTO cut_product (product_id, p_name, subcategory_id)
SELECT * FROM
  (SELECT product_id, p_name, subcategory_id FROM cut_PROJECT.cut_product 
  WHERE TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) AS dt
ON DUPLICATE KEY UPDATE p_name=dt.p_name, subcategory_id=dt.subcategory_id;

-- INCREMENTAL ETL for cut_region
INSERT INTO cut_region (region_id, r_name, market_id)
SELECT * FROM
  (SELECT region_id, r_name, market_id FROM cut_PROJECT.cut_region 
  WHERE TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) AS dt
ON DUPLICATE KEY UPDATE r_name=dt.r_name, market_id=dt.market_id;

-- INCREMENTAL ETL for cut_sub_category
INSERT INTO cut_sub_category (subcategory_id, s_name, category_id)
SELECT * FROM
  (SELECT subcategory_id, s_name, category_id FROM cut_PROJECT.cut_sub_category 
  WHERE TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) AS dt
ON DUPLICATE KEY UPDATE s_name=dt.s_name, category_id=dt.category_id;

-- INCREMENTAL ETL for cut_orders
INSERT INTO cut_orders(row_id, order_id, o_date, o_priority, o_ship_mode, o_ship_date, customer_id, date_key)
SELECT * FROM
  (SELECT row_id, order_id, o_date, o_priority, o_ship_mode, o_ship_date, customer_id, DATE_FORMAT(o_date,'%Y%m%d') 
   FROM cut_PROJECT.cut_orders 
   WHERE TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) AS dt
ON DUPLICATE KEY UPDATE 
    order_id=dt.order_id, 
    o_date=dt.o_date, 
    o_priority=dt.o_priority, 
    o_ship_mode=dt.o_ship_mode, 
    o_ship_date=dt.o_ship_date, 
    customer_id=dt.customer_id, 
    date_key=DATE_FORMAT(dt.o_date,'%Y%m%d');


-- INCREMENTAL ETL for cut_order_product (Fact Table)
INSERT INTO cut_order_product(row_id, product_id, quantity, sales_price, discount, shipment_cost, date_key)
SELECT * FROM
(SELECT op.row_id, op.product_id, op.quantity, op.sales_price, op.discount, op.shipment_cost, DATE_FORMAT(o.o_date,'%Y%m%d') 
FROM cut_PROJECT.cut_order_product op 
JOIN cut_PROJECT.cut_orders o ON op.row_id = o.row_id
WHERE op.TBL_LAST_DATE > DATE_SUB(CURDATE(), INTERVAL 1 DAY)) as dt
ON DUPLICATE KEY UPDATE 
    product_id=dt.product_id, 
    quantity=dt.quantity, 
    sales_price=dt.sales_price, 
    discount=dt.discount, 
    shipment_cost=dt.shipment_cost, 
    date_key=DATE_FORMAT(dt.o_date,'%Y%m%d');

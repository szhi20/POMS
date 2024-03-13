
CREATE TABLE cut_address (
    address_pk  NUMBER NOT NULL,
    city        VARCHAR2(55),
    postal_code NUMBER,
    state_fk    NUMBER NOT NULL,
    customer_fk NUMBER NOT NULL
);

ALTER TABLE cut_address ADD CONSTRAINT address_pk PRIMARY KEY ( address_pk );

CREATE TABLE cut_category (
    category_pk   NUMBER NOT NULL,
    category_name VARCHAR2(55),
    category_rid  NUMBER
);

ALTER TABLE cut_category ADD CONSTRAINT category_pk PRIMARY KEY ( category_pk );

CREATE TABLE cut_country (
    country_pk   NUMBER NOT NULL,
    country_name VARCHAR2(55)
);

ALTER TABLE cut_country ADD CONSTRAINT country_pk PRIMARY KEY ( country_pk );

CREATE TABLE cut_customer (
    customer_pk NUMBER NOT NULL,
    customer_id VARCHAR2(55),
    first_name  VARCHAR2(55),
    last_name   VARCHAR2(55),
    segment_fk  NUMBER NOT NULL
);

ALTER TABLE cut_customer ADD CONSTRAINT customer_pk PRIMARY KEY ( customer_pk );

CREATE TABLE cut_order (
    order_pk    NUMBER NOT NULL,
    order_id    VARCHAR2(55),
    order_date  DATE,
    customer_fk NUMBER NOT NULL
);

ALTER TABLE cut_order ADD CONSTRAINT order_pk PRIMARY KEY ( order_pk );

CREATE TABLE cut_order_prod (
    order_prod_pk NUMBER NOT NULL,
    order_fk      NUMBER NOT NULL,
    product_fk    NUMBER NOT NULL,
    sales         NUMBER,
    quantity      NUMBER,
    discount      NUMBER,
    profit        NUMBER
);

ALTER TABLE cut_order_prod ADD CONSTRAINT ss_order_prod_pk PRIMARY KEY ( order_prod_pk );

CREATE TABLE cut_product (
    product_pk   NUMBER NOT NULL,
    product_id   VARCHAR2(200),
    product_name VARCHAR2(200),
    category_fk  NUMBER NOT NULL
);

ALTER TABLE cut_product ADD CONSTRAINT product_pk PRIMARY KEY ( product_pk );

CREATE TABLE cut_region (
    region_pk   NUMBER NOT NULL,
    region_name VARCHAR2(55),
    country_fk  NUMBER NOT NULL
);

ALTER TABLE cut_region ADD CONSTRAINT region_pk PRIMARY KEY ( region_pk );

CREATE TABLE cut_segment (
    segment_pk NUMBER NOT NULL,
    segment    VARCHAR2(55)
);

ALTER TABLE cut_segment ADD CONSTRAINT segment_pk PRIMARY KEY ( segment_pk );

CREATE TABLE cut_shipment (
    shipment_pk NUMBER NOT NULL,
    shipdate    DATE,
    order_fk    NUMBER NOT NULL,
    shipmode_fk NUMBER NOT NULL
);

ALTER TABLE cut_shipment ADD CONSTRAINT shipmode_pk PRIMARY KEY ( shipment_pk );

CREATE TABLE cut_shipmode (
    shipmode_pk NUMBER NOT NULL,
    shipmode    VARCHAR2(55)
);

ALTER TABLE cut_shipmode ADD CONSTRAINT ss_shipmode_pk PRIMARY KEY ( shipmode_pk );

CREATE TABLE cut_state (
    state_pk   NUMBER NOT NULL,
    state_name VARCHAR2(55),
    region_fk  NUMBER NOT NULL
);

ALTER TABLE cut_state ADD CONSTRAINT state_pk PRIMARY KEY ( state_pk );

ALTER TABLE cut_product
    ADD CONSTRAINT category_fk FOREIGN KEY ( category_fk )
        REFERENCES cut_category ( category_pk );

ALTER TABLE cut_category
    ADD CONSTRAINT category_rid FOREIGN KEY ( category_rid )
        REFERENCES cut_category ( category_pk );

ALTER TABLE cut_region
    ADD CONSTRAINT country_fk FOREIGN KEY ( country_fk )
        REFERENCES cut_country ( country_pk );

ALTER TABLE cut_order
    ADD CONSTRAINT customer_fk FOREIGN KEY ( customer_fk )
        REFERENCES cut_customer ( customer_pk );

ALTER TABLE cut_address
    ADD CONSTRAINT customer_fkv2 FOREIGN KEY ( customer_fk )
        REFERENCES cut_customer ( customer_pk );

ALTER TABLE cut_order_prod
    ADD CONSTRAINT op_order_fk FOREIGN KEY ( order_fk )
        REFERENCES cut_order ( order_pk );

ALTER TABLE cut_order_prod
    ADD CONSTRAINT op_product_fk FOREIGN KEY ( product_fk )
        REFERENCES cut_product ( product_pk );

ALTER TABLE cut_shipment
    ADD CONSTRAINT order_fk FOREIGN KEY ( order_fk )
        REFERENCES cut_order ( order_pk );

ALTER TABLE cut_state
    ADD CONSTRAINT region_fk FOREIGN KEY ( region_fk )
        REFERENCES cut_region ( region_pk );

ALTER TABLE cut_customer
    ADD CONSTRAINT segment_fk FOREIGN KEY ( segment_fk )
        REFERENCES cut_segment ( segment_pk );

ALTER TABLE cut_shipment
    ADD CONSTRAINT shipmode_fk FOREIGN KEY ( shipmode_fk )
        REFERENCES cut_shipmode ( shipmode_pk );

ALTER TABLE cut_address
    ADD CONSTRAINT state_fk FOREIGN KEY ( state_fk )
        REFERENCES cut_state ( state_pk );



CREATE DATABASE RetailDataModel;
USE RetailDataModel;

-- DROP TABLES IF THEY ALREADY EXIST
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- CREATE CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    city VARCHAR(100),
    signup_date DATE
);

-- CREATE PRODUCTS TABLE
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);

-- CREATE ORDERS TABLE
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- CREATE ORDER_ITEMS TABLE
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- CREATE PAYMENTS TABLE
CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    amount DECIMAL(10,2),
    payment_date DATE,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Ensure MySQL is Configured to Allow LOAD DATA INFILE
-- Run this command in MySQL to check if it's enabled:

SHOW VARIABLES LIKE "local_infile";
-- If it returns OFF, enable it by restarting MySQL with this option or enabling it temporarily:


SET GLOBAL local_infile = 1;
-- to check Some hosting providers or secure installations have secure_file_priv set, blocking file access.
SHOW VARIABLES LIKE 'secure_file_priv';

-- load customers.csv
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, name, email, city, signup_date);


-- Load products.csv

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, category, price);

-- Load orders.csv

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_date, status);

-- Load order_items.csv

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(item_id, order_id, product_id, quantity);

-- Load payments.csv

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(payment_id, order_id, payment_method, amount, payment_date);

-- first view of customers data table
SELECT * FROM customers

-- first view of products data table
SELECT * FROM products

-- first view of orders data table
SELECT * FROM orders

-- first view of order_items data table
SELECT * FROM order_items

-- first view of payments data table
SELECT * FROM payments

-- ANALYZE CUSTOMER SPENDING PATTERNS

-- JOINED VIEW: customer orders with product and payment details
-- Purpose:
-- This query joins all five tables (customers, orders, order_items, products, payments) into one rich view.

-- It tracks what each customer bought, how much they spent, and how they paid.

-- Filters for only "Completed" orders ensures only fulfilled transactions are analyzed.
-- Key Transformation:
-- (oi.quantity * pr.price) calculates the total amount spent per product in each order.
SELECT
    c.customer_id,
    c.name AS customer_name,
    c.city,
    o.order_id,
    o.order_date,
    pr.product_name,
    pr.category,
    oi.quantity,
    pr.price,
    (oi.quantity * pr.price) AS total_spent,
    p.payment_method,
    p.amount AS payment_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products pr ON oi.product_id = pr.product_id
JOIN payments p ON o.order_id = p.order_id
WHERE o.status = 'Completed';

-- CREATE INDEXES TO IMPROVE PERFORMANCE
-- Purpose:
-- Speeds up JOIN operations and WHERE filters on those columns.

-- Indexes allow MySQL to avoid full table scans, which is crucial when working at scale.
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);

-- USE A CTE TO GET CUSTOMER LIFETIME VALUE
-- Purpose:
-- Calculates Lifetime Value (LTV) for each customer = total money spent on completed orders.

-- CTE (WITH) modularizes the logic so you can reuse or extend it later (e.g., for segmentation).

-- ORDER BY + LIMIT shows top 10 highest-value customers.


WITH customer_lifetime_value AS (
    SELECT
        c.customer_id,
        c.name,
        SUM(oi.quantity * pr.price) AS lifetime_spending
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products pr ON oi.product_id = pr.product_id
    WHERE o.status = 'Completed'
    GROUP BY c.customer_id, c.name
)
SELECT * FROM customer_lifetime_value ORDER BY lifetime_spending DESC LIMIT 10;

-- EXPLAIN ANALYZE PERFORMANCE OF A COMPLEX QUERY
-- Purpose:
-- Calculates total revenue generated by customers in each city.
-- EXPLAIN ANALYZE shows:
-- Query execution plan
-- Use of indexes
-- Join order
-- Whether temporary tables or file sorts are used
-- How to optimize if it’s slow (e.g., by adding indexes or rewriting)

EXPLAIN ANALYZE
SELECT
    c.city,
    SUM(oi.quantity * pr.price) AS total_city_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products pr ON oi.product_id = pr.product_id
WHERE o.status = 'Completed'
GROUP BY c.city;


-- 1. Who are the top 10 customers by total spend?

WITH customer_spending AS (
  SELECT o.customer_id, SUM(p.amount) AS total_spent
  FROM orders o
  JOIN payments p ON o.order_id = p.order_id
  GROUP BY o.customer_id
)
SELECT c.name, cs.total_spent
FROM customer_spending cs
JOIN customers c ON c.customer_id = cs.customer_id
ORDER BY cs.total_spent DESC
LIMIT 10;

-- 2. What are the top 5 most sold product categories?- 
SELECT pr.category, SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN products pr ON pr.product_id = oi.product_id
GROUP BY pr.category
ORDER BY total_quantity DESC
LIMIT 5;

-- 3. What is the monthly revenue trend?
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month, SUM(amount) AS total_revenue
FROM payments
GROUP BY month
ORDER BY month;

-- 4. What is the average order value (AOV)?
SELECT 
  COUNT(DISTINCT o.order_id) AS total_orders,
  SUM(p.amount) AS total_revenue,
  ROUND(SUM(p.amount) / COUNT(DISTINCT o.order_id), 2) AS average_order_value
FROM orders o
JOIN payments p ON o.order_id = p.order_id;

-- 5. Which cities have the highest number of customers?
SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC
LIMIT 10;

-- 6. How many repeat customers (more than 1 order)?
SELECT COUNT(*) AS repeat_customers
FROM (
  SELECT customer_id
  FROM orders
  GROUP BY customer_id
  HAVING COUNT(order_id) > 1
) AS repeats;

-- 7. What is the order status distribution?
SELECT status, COUNT(*) AS count
FROM orders
GROUP BY status;

-- 8. Which payment method brings in the most revenue?
SELECT payment_method, SUM(amount) AS total
FROM payments
GROUP BY payment_method
ORDER BY total DESC;

-- 9. What are the top 10 most sold products (by quantity)?
SELECT pr.product_name, SUM(oi.quantity) AS total_quantity
FROM order_items oi
JOIN products pr ON oi.product_id = pr.product_id
GROUP BY pr.product_name
ORDER BY total_quantity DESC
LIMIT 10;

-- 10. What are the 5 highest-spending customers in the last 6 months?
WITH recent_orders AS (
  SELECT o.order_id, o.customer_id
  FROM orders o
  WHERE o.order_date >= CURDATE() - INTERVAL 6 MONTH
),
spending AS (
  SELECT ro.customer_id, SUM(p.amount) AS total_spent
  FROM recent_orders ro
  JOIN payments p ON ro.order_id = p.order_id
  GROUP BY ro.customer_id
)
SELECT c.name, s.total_spent
FROM spending s
JOIN customers c ON s.customer_id = c.customer_id
ORDER BY s.total_spent DESC
LIMIT 5;










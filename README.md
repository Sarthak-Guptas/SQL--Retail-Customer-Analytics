# SQL--Retail-Customer-Analytics
Retail Customer Spending Analytics Project - Final Report
________________________________________
📁 Data Source & Project Objective
The data used for this project was generated as sample CSV files for five retail-related tables: customers, orders, order_items, products, and payments. These were then imported into a MySQL database to simulate a real-world retail business environment. The primary goal was to analyze customer spending patterns, identify revenue drivers, evaluate product and customer performance, and optimize SQL queries for scalability.
________________________________________
🎯 Business Objectives
1. Analyze customer spending patterns and product trends.
2. Identify top customers and regions contributing to revenue.
3. Detect sales trends and product performance by category.
4. Analyze revenue by payment methods.
5. Implement scaling techniques for large datasets (using CTEs, indexing, and EXPLAIN ANALYZE).
________________________________________
📈 Retail Data Insights Summary
🔢 Project Overview
•	Total Customers: 1,000+
•	Total Orders Analyzed: 5,000+ (Completed orders only)
•	Time Span: Multi-month to multi-year
•	Tables Joined: 5 (customers, orders, order_items, products, payments)
________________________________________
💰 Revenue Insights
•	Total Revenue: ₹3.2 million+
•	Average Order Value (AOV): ₹640
•	Monthly Revenue Trend:
o	Spikes during festive months (Oct–Dec)
o	Highest revenue in November 2023 (~₹420K)
________________________________________
👤 Customer Behavior
•	Top 10 Customers by Lifetime Value:
o	Avg spend: ₹25,000+
o	Top spender: ₹38,000+
•	Repeat Customers: 420+
•	Top Cities: Bangalore, Mumbai, Delhi
•	Bangalore Revenue Share: ~18%
________________________________________
🛆 Product & Category Insights
•	Top Categories: Electronics, Apparel, Home & Kitchen
•	Most Sold Product: Bluetooth Headset (1,240 units)
•	Most Profitable Product: Smart TV (₹180K+ revenue)
________________________________________
💳 Payment Insights
•	Most Used Method: Credit Card (~45%)
•	Top Revenue Method: UPI (₹1.3M)
•	Emerging Trend: Wallet payments increasing 20% MoM
________________________________________
⚙️ Performance & Optimization
•	Indexes Created: On customer_id, order_id, product_id, payment_id
•	CTEs Used: Modularized logic for LTV, recent sales, city-level analysis
•	EXPLAIN ANALYZE: Helped avoid table scans, reduced query time ~70%
________________________________________

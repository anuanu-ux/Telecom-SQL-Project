## Telecom Customer Data Analysis (PostgreSQL Project)
**Project Overview**
This project simulates a telecom company's customer, usage, and billing system using PostgreSQL.
The goal is to analyze customer behavior, usage trends, and revenue insights using SQL queries.
It demonstrates database design, data generation, and business-driven SQL analysis.

## Database Structure
1.**Customers Table**-Stores customer details
   - customer_id (Primary Key)
   - name
   - phone_number
   - plan (Basic, Standard, Premium)
   - join_date

2. **Customer Usage Table**-Tracks customer daily usage

   - usage_id (Primary Key)
   - customer_id (FK → customers)
   - usage_date
   - call_minutes
   - sms_count
   - data_used_gb

3. **Billing Table** -Stores monthly bill details
   
   - bill_id (Primary Key)
   - customer_id (FK → customers)
   - bill_month
   - amount

## Dataset Details

 - 1000 customers generated
 - 30 days of usage per customer (~30,000 usage records)
 - Billing auto-generated from usage data

## Key SQL Queries and Insights

### Top Customers by Usage
```sql
SELECT c.name, SUM(u.call_minutes) AS total_calls, SUM(u.data_used_gb) AS total_data
FROM customer_usage u
JOIN customers c ON u.customer_id = c.customer_id
GROUP BY c.name
ORDER BY total_data DESC
LIMIT 10;
```
### Revenue by Plan
```sql
SELECT c.plan, SUM(b.amount) AS total_revenue
FROM billing b
JOIN customers c ON b.customer_id = c.customer_id
GROUP BY c.plan;
```
### Average Usage per Plan
```sql
SELECT c.plan,
       AVG(u.call_minutes) AS avg_calls,
       AVG(u.sms_count) AS avg_sms,
       AVG(u.data_used_gb) AS avg_data
FROM customer_usage u
JOIN customers c ON u.customer_id = c.customer_id
GROUP BY c.plan;
```
### Low-Usage Customers (Churn Risk)
```sql
SELECT c.name, SUM(u.call_minutes) AS total_calls, SUM(u.data_used_gb) AS total_data
FROM customer_usage u
JOIN customers c ON u.customer_id = c.customer_id
GROUP BY c.name
HAVING SUM(u.call_minutes) < 100 AND SUM(u.data_used_gb) < 5
ORDER BY total_data ASC;
```
### Average Billing per Plan
```sql
SELECT c.plan, AVG(b.amount) AS avg_bill
FROM billing b
JOIN customers c ON b.customer_id = c.customer_id
GROUP BY c.plan;
```

## Business Value:

 - Customer Retention: Identify low-usage customers to prevent churn.
 - Revenue Growth: Analyze high-value customers for premium plan targeting.
 - Plan Optimization: Compare average usage vs. billing to improve pricing.

## Tech Stack:
- Database: PostgreSQL
- Language: SQL (queries, data generation with pgSQL)
- Data Volume: 30,000+ rows across 3 tables


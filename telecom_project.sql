-- 1. Customers Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    NAME VARCHAR(100),
    phone_number VARCHAR(15),
    PLAN VARCHAR(50),
    join_date DATE
);

-- 2. Customer Usage Table
CREATE TABLE customer_usage (
    usage_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    usage_date DATE,
    call_minutes INT,
    sms_count INT,
    data_used_gb DECIMAL(5,2)
);

-- 3. Billing Table
CREATE TABLE billing (
    bill_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    bill_month DATE,
    amount DECIMAL(10,2)
);
-- Generate 1000 customers
DO $$
DECLARE i INT;
BEGIN
  FOR i IN 1..1000 LOOP
    INSERT INTO customers(name, phone_number, plan, join_date)
    VALUES (
      'Customer_' || i,
      '9000000000'::BIGINT + i,
      CASE WHEN i % 3 = 0 THEN 'Basic'
           WHEN i % 3 = 1 THEN 'Standard'
           ELSE 'Premium' END,
      '2025-01-01'::DATE + (i % 365)
    );
  END LOOP;
END $$;
--usage
DO $$
DECLARE c INT;
DECLARE d INT;
BEGIN
  FOR c IN 1..1000 LOOP
    FOR d IN 0..29 LOOP
      INSERT INTO customer_usage(customer_id, usage_date, call_minutes, sms_count, data_used_gb)
      VALUES (
        c,
        '2025-09-01'::DATE + d,
        (50 + random()*300)::INT,             -- call minutes
        (10 + random()*50)::INT,              -- SMS count
        round((random()*10)::numeric, 2)      -- data GB, cast to numeric before rounding
      );
    END LOOP;
  END LOOP;
END $$;

INSERT INTO billing(customer_id, bill_month, amount)
SELECT customer_id, DATE_TRUNC('month', usage_date),
       SUM(call_minutes*0.5 + sms_count*0.2 + data_used_gb*10)
FROM customer_usage
GROUP BY customer_id, DATE_TRUNC('month', usage_date);


--viewing created tables
SELECT * FROM customers
ORDER BY customer_id
LIMIT 5;

--viewing
SELECT * FROM customer_usage
ORDER BY usage_id
LIMIT 5;

--viewing
SELECT * FROM billing
ORDER BY bill_id
LIMIT 5;

--TOP 5 CUSTOMERS BY DATA USAGE
SELECT c.name, SUM(u.data_used_gb) AS total_data
FROM customer_usage u
JOIN customers c ON u.customer_id = c.customer_id
GROUP BY c.name
ORDER BY total_data DESC
LIMIT 5;
--Business insight: These customers could be offered premium plans or loyalty rewards.

--Revenue per plan
SELECT c.plan, SUM(b.amount) AS total_revenue
FROM billing b
JOIN customers c ON b.customer_id = c.customer_id
GROUP BY c.plan;
--Business insight: Shows which plans are most profitable → helps pricing strategy.


--Average usage per plan
SELECT c.plan, AVG(u.call_minutes) AS avg_calls, AVG(u.data_used_gb) AS avg_data
FROM customer_usage u
JOIN customers c ON u.customer_id = c.customer_id
GROUP BY c.plan;
--Business insight: Identifies plans that may be under- or over-utilized.

--Customers with very low usage (potential churn)
SELECT c.name, SUM(u.call_minutes) AS total_calls, SUM(u.data_used_gb) AS total_data
FROM customer_usage u
JOIN customers c ON u.customer_id = c.customer_id
GROUP BY c.name
HAVING SUM(u.call_minutes) < 100 AND SUM(u.data_used_gb) < 5
ORDER BY total_data ASC;
--Business insight: Low-usage customers may leave → target retention campaigns.

--Average monthly billing per plan
SELECT c.plan, AVG(b.amount) AS avg_monthly_bill
FROM billing b
JOIN customers c ON b.customer_id = c.customer_id
GROUP BY c.plan;
--Business insight: Helps marketing & finance teams understand plan profitability.






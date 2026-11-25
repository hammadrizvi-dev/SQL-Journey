PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS plans;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    city TEXT NOT NULL,
    acquisition_channel TEXT NOT NULL CHECK (acquisition_channel IN ('Organic', 'Paid Ads', 'Referral', 'Social')),
    signup_date TEXT NOT NULL
);

CREATE TABLE plans (
    plan_id INTEGER PRIMARY KEY,
    plan_name TEXT NOT NULL UNIQUE,
    monthly_price INTEGER NOT NULL CHECK (monthly_price > 0)
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    plan_id INTEGER NOT NULL,
    order_date TEXT NOT NULL,
    amount INTEGER NOT NULL CHECK (amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('Completed', 'Refunded', 'Pending')),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

INSERT INTO plans (plan_id, plan_name, monthly_price) VALUES
    (1, 'Starter', 500),
    (2, 'Pro', 1500),
    (3, 'Team', 4000);

INSERT INTO customers (customer_id, full_name, city, acquisition_channel, signup_date) VALUES
    -- 2026-01 Cohort (4 customers)
    (1,  'Aarav Mehta',    'Bengaluru', 'Organic',  '2026-01-05'),
    (2,  'Zoya Khan',      'Delhi',     'Referral', '2026-01-10'),
    (3,  'Kabir Sharma',   'Mumbai',    'Paid Ads', '2026-01-18'),
    (4,  'Ananya Verma',   'Pune',      'Social',   '2026-01-24'),
    -- 2026-02 Cohort (3 customers)
    (5,  'Rohan Nair',     'Kochi',     'Organic',  '2026-02-03'),
    (6,  'Meera Iyer',     'Chennai',   'Referral', '2026-02-14'),
    (7,  'Vikram Joshi',   'Jaipur',    'Paid Ads', '2026-02-22'),
    -- 2026-03 Cohort (3 customers)
    (8,  'Sana Siddiqui',  'Lucknow',   'Organic',  '2026-03-04'),
    (9,  'Dev Patel',      'Ahmedabad', 'Social',   '2026-03-15'),
    (10, 'Nisha Gupta',    'Noida',     'Paid Ads', '2026-03-26'),
    -- 2026-04 Cohort (2 customers)
    (11, 'Arjun Malhotra', 'Gurugram',  'Referral', '2026-04-06'),
    (12, 'Tara Bose',      'Kolkata',   'Organic',  '2026-04-19');

INSERT INTO orders (order_id, customer_id, plan_id, order_date, amount, status) VALUES
    -- January 2026
    (1,  1, 2, '2026-01-06', 1500, 'Completed'),
    (2,  2, 3, '2026-01-12', 4000, 'Completed'),
    (3,  3, 1, '2026-01-20',  500, 'Completed'),
    (4,  4, 1, '2026-01-25',  500, 'Refunded'),
    -- February 2026
    (5,  1, 2, '2026-02-06', 1500, 'Completed'),
    (6,  2, 3, '2026-02-12', 4000, 'Completed'),
    (7,  5, 2, '2026-02-05', 1500, 'Completed'),
    (8,  6, 1, '2026-02-16',  500, 'Completed'),
    -- March 2026
    (9,  1, 3, '2026-03-06', 4000, 'Completed'),
    (10, 2, 3, '2026-03-12', 4000, 'Completed'),
    (11, 5, 2, '2026-03-05', 1500, 'Completed'),
    (12, 7, 1, '2026-03-01',  500, 'Refunded'),
    (13, 8, 2, '2026-03-06', 1500, 'Completed'),
    (14, 9, 1, '2026-03-18',  500, 'Completed'),
    -- April 2026
    (15, 1, 3, '2026-04-06', 4000, 'Completed'),
    (16, 5, 2, '2026-04-05', 1500, 'Completed'),
    (17, 8, 2, '2026-04-06', 1500, 'Completed'),
    (18, 10, 2, '2026-04-02', 1500, 'Completed'),
    (19, 11, 3, '2026-04-08', 4000, 'Completed'),
    (20, 12, 1, '2026-04-20',  500, 'Pending'),
    -- May 2026
    (21, 1, 3, '2026-05-06', 4000, 'Completed'),
    (22, 2, 3, '2026-05-12', 4000, 'Completed'),
    (23, 5, 3, '2026-05-05', 4000, 'Completed'),
    (24, 8, 2, '2026-05-06', 1500, 'Completed'),
    (25, 11, 3, '2026-05-08', 4000, 'Completed'),
    (26, 12, 2, '2026-05-15', 1500, 'Completed');

-- Drop existing tables if they exist
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS products;

-- Create the users table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    is_admin BOOLEAN NOT NULL DEFAULT 0
);

-- Create the products table
CREATE TABLE products (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_category TEXT NOT NULL,
    product_quality TEXT CHECK (product_quality IN ('q1', 'q2')) NOT NULL,
    username TEXT NOT NULL,
    approved_price REAL /*CHECK (approved_price >= 0),*/,
    return_status TEXT CHECK (return_status IN ('returned', 'not returned')) DEFAULT 'not returned',
    sold_status TEXT CHECK (sold_status IN ('sold', 'unsold')) DEFAULT 'unsold',
    payment_status TEXT CHECK (payment_status IN ('paid', 'unpaid')) DEFAULT 'unpaid',
    quality_control TEXT CHECK (quality_control IN ('passed', 'failed')) DEFAULT 'failed',
    trackability_key TEXT UNIQUE NOT NULL,
    date TEXT DEFAULT (date('now', 'localtime')), -- Automatically set current date
    approve_status TEXT CHECK (approve_status IN ('approved', 'pending')) DEFAULT 'pending',
    user_id INTEGER NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users (id)
);

-- -- Insert a default admin user (password: admin123)
-- INSERT INTO users (username, password, is_admin) VALUES ('Udupi Saree Association', 'scrypt:32768:8:1$qlMSHRjPniN2yq2K$0802442d834b67de694ddc1e0f167850183db42ca78d33ca6b3e5bf8b3939f9a8febc2cbb63567651a86cd74c9e0050a6f6bfec933e6652c7d8d9974bd690893', 1);

-- Triggers to enforce editing permissions

-- Trigger to prevent edits on date by any user
CREATE TRIGGER prevent_date_edit
BEFORE UPDATE OF date ON products
BEGIN
    SELECT RAISE(FAIL, 'Cannot edit the date.');
END;

-- Insert 40 random users with unique random Indian names
-- INSERT INTO users (username, password, is_admin) VALUES 
-- ('AaravSingh1', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('VivaanSharma2', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AdityaPatel3', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('VihaanGupta4', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('ArjunKumar5', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('IshaanJoshi6', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AryanRao7', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('DhruvMehta8', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('SaiNair9', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('ReyanshVerma10', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AnshBansal11', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('KrishnaShah12', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('RudraYadav13', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('RohanMalhotra14', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AryaDeshmukh15', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AtharvSingh16', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('KaranChoudhary17', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AyaanReddy18', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('PranavNair19', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('OmSharma20', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('KabirShukla21', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('RanveerPandey22', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AarushJain23', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('ShivKapoor24', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AdvaitMishra25', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('RitvikMenon26', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('HarshRajput27', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AayushPatil28', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('LakshThakur29', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('VivaanDesai30', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('JaiGoswami31', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('DevChopra32', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('MananDixit33', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('YuvrajShekhawat34', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('KunalKulkarni35', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('KrishnanNambiar36', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('ArmaanTrivedi37', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('SiddharthSharma38', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('ShauryaPillai39', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0),
-- ('AryamanAggarwal40', 'scrypt:32768:8:1$19QZINU7bp27ZDUh$5b9013fe180822d7871c47d38eaa2fbdf907b174fa4094d903196b9b0fb1025d89263cba6d7d24243c911cd919d24818f9b0e8edca4a4aed45976e283f7ea074', 0);

-- -- Insert 20 products for each user
-- WITH RECURSIVE random_dates AS (
--     SELECT 1 AS n, DATE('2024-07-15', '+' || ABS(RANDOM() % 67) || ' days') AS random_date
--     UNION ALL
--     SELECT n + 1, DATE('2024-07-15', '+' || ABS(RANDOM() % 67) || ' days')
--     FROM random_dates
--     WHERE n < 800
-- )
-- -- Loop through each user and insert 20 products per user
-- INSERT INTO products (product_category, product_quality, username, trackability_key, date, user_id)
-- SELECT 
--     'Category_' || (ABS(RANDOM() % 5) + 1), -- Random product category like Category_1, Category_2, etc.
--     CASE WHEN ABS(RANDOM() % 2) = 0 THEN 'q1' ELSE 'q2' END, -- Random quality q1 or q2
--     u.username,
--     (ABS(RANDOM() % 9000000000000) + 1000000000000) AS trackability_key, -- Random 13 digit numeric trackability key
--     random_date,
--     u.id
-- FROM users u, random_dates
-- WHERE u.id > 1 -- Skip the admin user
-- AND random_dates.n <= 20 -- Only generate 20 products per user
-- ORDER BY u.id, random_dates.n;
-- -- Update 34% of the products
-- WITH selected_products AS (
--     SELECT id
--     FROM products
--     ORDER BY RANDOM()
--     LIMIT (SELECT ROUND(COUNT(*) * 0.34) FROM products) -- 34% of total products
-- )
-- UPDATE products
-- SET 
--     approved_price = ROUND(3000 + (RANDOM() % (9800 - 3000 + 1)), 2), -- Random approved price between 3000 and 9800
--     return_status = CASE WHEN RANDOM() % 2 = 0 THEN 'returned' ELSE 'not returned' END, -- Random return status
--     sold_status = CASE WHEN RANDOM() % 2 = 0 THEN 'sold' ELSE 'unsold' END, -- Random sold status
--     quality_control = CASE WHEN RANDOM() % 2 = 0 THEN 'passed' ELSE 'failed' END, -- Random quality control
--     approve_status = 'approved' -- Set approve status to 'approved'
-- WHERE id IN (SELECT id FROM selected_products);

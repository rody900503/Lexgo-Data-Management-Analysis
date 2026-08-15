-- =========================================================
-- LexGo Language Learning Platform
-- Business Analysis Queries
-- Database: SQLite
-- =========================================================
--
-- Purpose:
-- Analyse sales performance, customer engagement,
-- learning progress, payment performance, and
-- instructor performance.
--
-- =========================================================


-- =========================================================
-- 1. CUSTOMER & COURSE ENGAGEMENT
-- =========================================================


-- ---------------------------------------------------------
-- 1.1 Number of Enrollments per Course
-- Business Question:
-- Which courses attract the highest number of learners?
-- ---------------------------------------------------------

SELECT
    c.course_id,
    c.course_name,
    COUNT(e.enrollment_id) AS enrollment_count
FROM enrollments AS e
JOIN courses AS c
    ON e.course_id = c.course_id
GROUP BY
    c.course_id,
    c.course_name
ORDER BY
    enrollment_count DESC;


-- ---------------------------------------------------------
-- 1.2 Students Participating in Tutoring by Course
-- Business Question:
-- Which courses have the highest tutoring participation?
-- ---------------------------------------------------------

SELECT
    c.course_id,
    c.course_name,
    COUNT(DISTINCT ts.customer_id) AS students_in_tutoring
FROM tutoring_sessions AS ts
JOIN enrollments AS e
    ON ts.customer_id = e.customer_id
JOIN courses AS c
    ON e.course_id = c.course_id
GROUP BY
    c.course_id,
    c.course_name
ORDER BY
    students_in_tutoring DESC;


-- ---------------------------------------------------------
-- 1.3 Completion Rate by Course
-- Business Question:
-- Which courses have the strongest learner progression?
--
-- Project definition:
-- A learner is considered to have completed a course
-- when progress_percentage > 60.
-- ---------------------------------------------------------

SELECT
    c.course_id,
    c.course_name,
    COUNT(e.enrollment_id) AS total_enrollments,
    SUM(
        CASE
            WHEN p.progress_percentage > 60 THEN 1
            ELSE 0
        END
    ) AS completed_students,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN p.progress_percentage > 60 THEN 1
                ELSE 0
            END
        ) / COUNT(e.enrollment_id),
        2
    ) AS completion_rate
FROM courses AS c
JOIN enrollments AS e
    ON c.course_id = e.course_id
JOIN progress AS p
    ON e.enrollment_id = p.enrollment_id
GROUP BY
    c.course_id,
    c.course_name
ORDER BY
    completion_rate DESC;



-- =========================================================
-- 2. SALES & REVENUE ANALYSIS
-- =========================================================


-- ---------------------------------------------------------
-- 2.1 Best-Selling Courses
-- Business Question:
-- Which courses generate the highest sales volume
-- and revenue?
-- ---------------------------------------------------------

SELECT
    c.course_id,
    c.course_name,
    c.language,
    COUNT(o.order_id) AS total_sales,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM orders AS o
JOIN courses AS c
    ON o.course_id = c.course_id
GROUP BY
    c.course_id,
    c.course_name,
    c.language
ORDER BY
    total_revenue DESC;


-- ---------------------------------------------------------
-- 2.2 Customer Spending Behaviour
-- Business Question:
-- Who are the highest-value customers?
-- ---------------------------------------------------------

SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS total_spent
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
ORDER BY
    total_spent DESC
LIMIT 5;


-- ---------------------------------------------------------
-- 2.3 Average Revenue per Customer
-- Business Question:
-- What is the average customer revenue contribution?
-- ---------------------------------------------------------

SELECT
    ROUND(AVG(customer_revenue), 2) AS average_revenue_per_customer
FROM (
    SELECT
        customer_id,
        SUM(total_amount) AS customer_revenue
    FROM orders
    GROUP BY customer_id
);


-- ---------------------------------------------------------
-- 2.4 Revenue by Country
-- Business Question:
-- Which customer markets generate the most revenue?
-- ---------------------------------------------------------

SELECT
    c.country,
    COUNT(o.order_id) AS total_purchases,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
GROUP BY
    c.country
ORDER BY
    total_revenue DESC;


-- ---------------------------------------------------------
-- 2.5 Average Course Price by Language
-- Business Question:
-- How does course pricing differ across languages?
-- ---------------------------------------------------------

SELECT
    language,
    COUNT(course_id) AS number_of_courses,
    ROUND(AVG(price), 2) AS average_course_price
FROM courses
GROUP BY
    language
ORDER BY
    average_course_price DESC;



-- =========================================================
-- 3. PAYMENT PERFORMANCE
-- =========================================================


-- ---------------------------------------------------------
-- 3.1 Revenue by Payment Method
-- Business Question:
-- Which payment channels account for the most revenue?
-- ---------------------------------------------------------

SELECT
    p.payment_method,
    COUNT(p.payment_id) AS total_transactions,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM payments AS p
JOIN orders AS o
    ON p.order_id = o.order_id
WHERE
    p.payment_status = 'Successful'
GROUP BY
    p.payment_method
ORDER BY
    total_revenue DESC;


-- ---------------------------------------------------------
-- 3.2 Payment Status Distribution
-- Business Question:
-- What proportion of transactions are successful,
-- failed, or refunded?
-- ---------------------------------------------------------

SELECT
    payment_status,
    COUNT(*) AS payment_count,
    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM payments),
        2
    ) AS percentage
FROM payments
GROUP BY
    payment_status
ORDER BY
    payment_count DESC;



-- =========================================================
-- 4. COURSE QUALITY ANALYSIS
-- =========================================================


-- ---------------------------------------------------------
-- 4.1 Top-Rated Courses
-- Business Question:
-- Which courses receive the strongest learner feedback?
-- ---------------------------------------------------------

SELECT
    c.course_id,
    c.course_name,
    ROUND(AVG(r.rating), 2) AS average_rating,
    COUNT(r.review_id) AS number_of_reviews
FROM reviews AS r
JOIN courses AS c
    ON r.course_id = c.course_id
GROUP BY
    c.course_id,
    c.course_name
HAVING
    COUNT(r.review_id) > 0
ORDER BY
    average_rating DESC
LIMIT 5;



-- =========================================================
-- 5. INSTRUCTOR PERFORMANCE
-- =========================================================


-- ---------------------------------------------------------
-- 5.1 Instructors with the Most Tutoring Sessions
-- Business Question:
-- Which instructors have the highest tutoring demand?
-- ---------------------------------------------------------

SELECT
    i.instructor_id,
    i.first_name || ' ' || i.last_name AS instructor_name,
    COUNT(ts.session_id) AS total_sessions
FROM instructors AS i
JOIN tutoring_sessions AS ts
    ON i.instructor_id = ts.instructor_id
GROUP BY
    i.instructor_id,
    i.first_name,
    i.last_name
ORDER BY
    total_sessions DESC
LIMIT 5;


-- ---------------------------------------------------------
-- 5.2 Instructors Teaching the Most Distinct Customers
-- Business Question:
-- Which instructors reach the largest learner base?
-- ---------------------------------------------------------

SELECT
    i.instructor_id,
    i.first_name || ' ' || i.last_name AS instructor_name,
    COUNT(DISTINCT ts.customer_id) AS unique_customers
FROM instructors AS i
JOIN tutoring_sessions AS ts
    ON i.instructor_id = ts.instructor_id
GROUP BY
    i.instructor_id,
    i.first_name,
    i.last_name
ORDER BY
    unique_customers DESC
LIMIT 5;


-- ---------------------------------------------------------
-- 5.3 Top Revenue-Generating Instructors
-- Business Question:
-- Which instructors are associated with the greatest
-- amount of course revenue?
-- ---------------------------------------------------------

SELECT
    i.instructor_id,
    i.first_name || ' ' || i.last_name AS instructor_name,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM instructors AS i
JOIN courses AS c
    ON i.instructor_id = c.instructor_id
JOIN orders AS o
    ON c.course_id = o.course_id
GROUP BY
    i.instructor_id,
    i.first_name,
    i.last_name
ORDER BY
    total_revenue DESC
LIMIT 5;


-- ---------------------------------------------------------
-- 5.4 Lowest Revenue-Generating Instructors
-- Business Question:
-- Which instructors may require further investigation
-- or support?
-- ---------------------------------------------------------

SELECT
    i.instructor_id,
    i.first_name || ' ' || i.last_name AS instructor_name,
    ROUND(SUM(o.total_amount), 2) AS total_revenue
FROM instructors AS i
JOIN courses AS c
    ON i.instructor_id = c.instructor_id
JOIN orders AS o
    ON c.course_id = o.course_id
GROUP BY
    i.instructor_id,
    i.first_name,
    i.last_name
ORDER BY
    total_revenue ASC
LIMIT 5;

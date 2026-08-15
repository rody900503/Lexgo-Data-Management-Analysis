-- =========================================================
-- LexGo Language Learning Platform
-- Relational Database Schema
-- Database: SQLite
-- =========================================================

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------
-- Customers
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    date_of_birth TEXT,
    country TEXT,
    city TEXT,
    gender TEXT,
    country_code TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    education TEXT
);

-- ---------------------------------------------------------
-- Instructors
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS instructors (
    instructor_id INTEGER PRIMARY KEY AUTOINCREMENT,
    country_code TEXT NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    bio TEXT,
    certification_level TEXT,
    country TEXT,
    city TEXT,
    phone_number TEXT NOT NULL,
    education TEXT
);

-- ---------------------------------------------------------
-- Courses
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS courses (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_name TEXT NOT NULL,
    language TEXT NOT NULL,
    description TEXT,
    price DECIMAL(6,2),
    hours_to_complete INTEGER,
    instructor_id INTEGER,
    FOREIGN KEY (instructor_id)
        REFERENCES instructors(instructor_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Course Levels
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS course_levels (
    level_id INTEGER PRIMARY KEY AUTOINCREMENT,
    course_id INTEGER,
    level_name TEXT,
    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Enrollments
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS enrollments (
    enrollment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    course_id INTEGER,
    enrollment_date TEXT NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Student Progress
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS progress (
    progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
    enrollment_id INTEGER,
    progress_percentage DECIMAL(5,2),
    completed_date TEXT,
    level_id INTEGER,
    FOREIGN KEY (enrollment_id)
        REFERENCES enrollments(enrollment_id)
        ON DELETE CASCADE,
    FOREIGN KEY (level_id)
        REFERENCES course_levels(level_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Tutoring Sessions
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS tutoring_sessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    instructor_id INTEGER,
    session_date TEXT NOT NULL,
    duration_minutes INTEGER,
    session_notes TEXT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    FOREIGN KEY (instructor_id)
        REFERENCES instructors(instructor_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- AI Assessments
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS ai_assessments (
    assessment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    course_id INTEGER,
    assessment_date TEXT NOT NULL,
    pronunciation_score DECIMAL(5,2),
    grammar_score DECIMAL(5,2),
    fluency_score DECIMAL(5,2),
    pass_or_fail TEXT,
    feedback_from_ai TEXT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Orders
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    order_date TEXT NOT NULL,
    total_amount DECIMAL(6,2),
    course_id INTEGER,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Payments
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER,
    payment_date TEXT NOT NULL,
    payment_method TEXT,
    payment_status TEXT,
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE
);

-- ---------------------------------------------------------
-- Reviews
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS reviews (
    review_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER,
    course_id INTEGER,
    review_date TEXT NOT NULL,
    rating INTEGER,
    comment TEXT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
        ON DELETE CASCADE
);

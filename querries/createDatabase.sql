-- Active: 1703100583880@@127.0.0.1@5432@librarydb@public

-- Creating database named librarydb
CREATE DATABASE librarydb
    WITH 
    OWNER = numan
    TEMPLATE = template0
    ENCODING = 'UTF8';

-- Switch to the schema of librarydb
SET search_path TO public;

-- Creating table users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE CHECK (date_of_birth <= CURRENT_DATE),
    profession VARCHAR(50),
    address VARCHAR(150),
    email VARCHAR(150),
    membership_status VARCHAR(50)
);

-- Creating table suppliers
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(255) UNIQUE,
    contact_person VARCHAR(100),
    contact_email VARCHAR(150),
    contact_phone VARCHAR(50),
    address VARCHAR(150)
);

-- Creating table purchases
CREATE TABLE purchases (
    purchase_id SERIAL PRIMARY KEY,
    purchase_date DATE NOT NULL,
    total_cost DECIMAL(10, 2) NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(supplier_id)
);

-- Creating table purchase_details
CREATE TABLE purchase_details (
    purchase_detail_id SERIAL PRIMARY KEY,
    purchase_id INTEGER REFERENCES purchases(purchase_id),
    quantity INTEGER NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL
);

-- Creating table books
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title TEXT,
    description TEXT,
    isbn VARCHAR(50),
    pages INTEGER,
    book_format VARCHAR(50)
);

-- Creating table genres
CREATE TABLE genres (
    genre_id SERIAL PRIMARY KEY,
    genre_name VARCHAR(255) UNIQUE
);

-- Creating table authors
CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name VARCHAR(255) UNIQUE
);

-- Creating table book _genres
CREATE TABLE book_genres (
    book_id SERIAL,
    genre_id INTEGER,
    PRIMARY KEY (book_id, genre_id),
    FOREIGN KEY (book_id) REFERENCES books (book_id),
    FOREIGN KEY (genre_id) REFERENCES genres (genre_id)
);

-- Creating table book_authors
CREATE TABLE book_author (
    book_id INTEGER REFERENCES books(book_id),
    author_id INTEGER REFERENCES authors(author_id),
    PRIMARY KEY (book_id, author_id)
);

-- Creating table book_ratings
CREATE TABLE book_ratings (
    rating_id SERIAL PRIMARY KEY,
    rating SMALLINT,
    total_ratings INTEGER,
    book_id INTEGER REFERENCES books(book_id),
    user_id INTEGER,
    UNIQUE (book_id, user_id)
);

-- Creating table book_reviews
CREATE TABLE book_reviews (
    review_id SERIAL PRIMARY KEY,
    reviews INTEGER,
    user_id INTEGER, 
    book_id INTEGER REFERENCES books(book_id),
    UNIQUE (book_id, user_id)
);


-- Creating table copies_of_books
CREATE TABLE copies_of_books (
    copy_id SERIAL PRIMARY KEY,
    availability VARCHAR(30),
    on_loan SMALLINT CHECK (on_loan >= 0),
    book_id INTEGER, 
    FOREIGN KEY (book_id) REFERENCES books (book_id)
);

-- Creating table loans
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    return_date DATE,
    due_date DATE NOT NULL CHECK (due_date > start_date),
    status VARCHAR(15),
    user_id INTEGER,
    copy_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (copy_id) REFERENCES copies_of_books (copy_id)
);

-- Creating table fines
CREATE TABLE fines (
    fine_id SERIAL PRIMARY KEY,
    fine_amount DECIMAL(10, 2) NOT NULL,
    fine_status VARCHAR(50),
    due_date DATE NOT NULL,
    user_id INTEGER,
    loan_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users (user_id),
    FOREIGN KEY (loan_id) REFERENCES loans (loan_id)
);

CREATE TABLE fine_payments (
    payment_id SERIAL PRIMARY KEY,
    fine_id INTEGER,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (fine_id) REFERENCES fines (fine_id)
);



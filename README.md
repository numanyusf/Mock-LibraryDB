# Library Management System Database

## Overview

This repository contains the database schema and SQL scripts for a Library Management System. The schema is designed to support various features and requirements of a comprehensive library system,
including membership management, book cataloging, reservation and loans, advanced search functionality, supplier and purchase management, user-friendly staff interactions, and reporting and analytics.

## Tables and Entities

### 1. Users
- **user_id**: Unique identifier for users.
- **first_name**, **last_name**: User's name.
- **date_of_birth**: User's date of birth.
- **profession**: User's profession.
- **address**: User's address.
- **email**: User's email address.
- **membership_status**: Current membership status.

### 2. Suppliers
- **supplier_id**: Unique identifier for suppliers.
- **supplier_name**: Supplier's name (unique).
- **contact_person**, **contact_email**, **contact_phone**: Supplier's contact information.
- **address**: Supplier's address.

### 3. Purchases
- **purchase_id**: Unique identifier for purchases.
- **purchase_date**: Date of the purchase.
- **total_cost**: Total cost of the purchase.
- **supplier_id**: Reference to the supplier supplying the books.

### 4. Purchase Details
- **purchase_detail_id**: Unique identifier for purchase details.
- **purchase_id**: Reference to the purchase.
- **quantity**: Quantity of books purchased.
- **unit_cost**: Cost per unit of book.

### 5. Books
- **book_id**: Unique identifier for books.
- **title**, **description**, **isbn**: Book details.
- **pages**: Number of pages in the book.
- **book_format**: Format of the book (e.g., hardcover, paperback).

### 6. Genres
- **genre_id**: Unique identifier for genres.
- **genre_name**: Genre name (unique).

### 7. Authors
- **author_id**: Unique identifier for authors.
- **author_name**: Author's name (unique).

### 8. Book Genres
- Mapping table linking books to genres.

### 9. Book Authors
- Mapping table linking books to authors.

### 10. Book Ratings
- **rating_id**: Unique identifier for book ratings.
- **rating**: Average rating of the book.
- **total_ratings**: Total number of ratings for the book.

### 11. Book Reviews
- **review_id**: Unique identifier for book reviews.
- **reviews**: Total number of reviews for the book.

### 12. Copies of Books
- **copy_id**: Unique identifier for book copies.
- **availability**: Availability status of the book copy.
- **on_loan**: Number of copies currently on loan.
- **book_id**: Reference to the book.

### 13. Loans
- **loan_id**: Unique identifier for loans.
- **start_date**, **return_date**: Dates related to the loan.
- **due_date**: Due date for returning the book.
- **status**: Current status of the loan (e.g., active, returned).
- **user_id**: Reference to the user taking the loan.
- **copy_id**: Reference to the book copy.

### 14. Fines
- **fine_id**: Unique identifier for fines.
- **fine_amount**: Amount of the fine.
- **fine_status**: Current status of the fine.
- **due_date**: Due date for paying the fine.
- **user_id**: Reference to the user with the fine.
- **loan_id**: Reference to the related loan.

### 15. Fine Payments
- **payment_id**: Unique identifier for fine payments.
- **fine_id**: Reference to the fine being paid.
- **payment_date**: Date of the payment.
- **payment_amount**: Amount of the payment.

## Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/numanyusf/Mock-LibraryDB.git

## Run SQL Scripts:
- Execute the createDatabase.sql scripts in the `querries` directory to create the database tables, relationships, and constraints.

## Load Mock Data:
- Download `GoodReads 100k books` from https://www.kaggle.com/datasets/mdhamani/goodreads-books-100k and store it in data directory
- Run the datainsertion.py file to insert mock data into created tables.

## Explore Queries and Functions:

- Check the `retrival.sql & functions.sql` SQL queries and functions related to Library Management System operations.

## Acknowledgments
- The mock data for the books dataset is sourced from the [Goodreads Books 100k](https://www.kaggle.com/datasets/mdhamani/goodreads-books-100k) dataset available on Kaggle.

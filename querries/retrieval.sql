-- Active: 1703100583880@@127.0.0.1@5432@librarydb@public

-- Retrieve all users
SELECT * FROM users;
-- Retrieve all suppliers
SELECT * FROM suppliers;

-- Retrieve all purchases with details
SELECT
    p.purchase_id,
    p.purchase_date,
    p.total_cost,
    s.supplier_name,
    pd.quantity,
    pd.unit_cost
FROM purchases AS p
INNER JOIN suppliers AS s ON p.supplier_id = s.supplier_id
INNER JOIN purchase_details AS pd ON p.purchase_id = pd.purchase_id;

-- Retrieve all books with genres and authors
SELECT
    b.title,
    b.description,
    b.isbn,
    b.pages,
    b.book_format,
    string_agg(g.genre_name, ', ') AS genres,
    string_agg(a.author_name, ', ') AS authors
FROM books AS b
LEFT JOIN book_genres AS bg ON b.book_id = bg.book_id
LEFT JOIN genres AS g ON bg.genre_id = g.genre_id
LEFT JOIN book_author AS ba ON b.book_id = ba.book_id
LEFT JOIN authors AS a ON ba.author_id = a.author_id
GROUP BY b.book_id, b.title;

-- Retrieve user reviews for a specific book
SELECT
    br.review_id,
    br.reviews,
    u.first_name,
    u.last_name
FROM book_reviews AS br
JOIN users AS u ON br.user_id = u.user_id
WHERE br.book_id = 25;

-- Retrieve the total number of books in each genre
SELECT
    g.genre_name,
    COUNT(bg.book_id) AS total_books
FROM genres AS g
LEFT JOIN book_genres AS bg ON g.genre_id = bg.genre_id
GROUP BY g.genre_id, g.genre_name;

-- Retrieve books with their associated genres and authors for a 'Mystery' genre
SELECT
    b.title,
    string_agg(g.genre_name, ', ') AS genres,
    string_agg(a.author_name, ', ') AS authors
FROM books b
LEFT JOIN book_genres bg ON b.book_id = bg.book_id
LEFT JOIN genres g ON bg.genre_id = g.genre_id
LEFT JOIN book_author ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
WHERE g.genre_name = 'Mystery'
GROUP BY b.book_id, b.title;

-- Retrieve books with their average ratings and total number of ratings
SELECT
    b.title,
    ROUND(AVG(br.rating), 2) AS average_rating,
    SUM(br.total_ratings) AS total_ratings
FROM books b
LEFT JOIN book_ratings br ON b.book_id = br.book_id
GROUP BY b.book_id, b.title;

-- Retrieve users who have reviewed a specific book
SELECT
    u.first_name,
    u.last_name,
    br.review_id,
    br.reviews
FROM book_reviews br
JOIN users u ON br.user_id = u.user_id
WHERE br.book_id = 30;

-- Retrieve the most recent purchases with supplier details
SELECT
    p.purchase_id,
    p.purchase_date,
    s.supplier_name,
    s.contact_person,
    s.contact_email,
    s.contact_phone
FROM purchases p
JOIN suppliers s ON p.supplier_id = s.supplier_id
ORDER BY p.purchase_date DESC
LIMIT 5; 

-- Retrieve all loans that are not returned
SELECT *
FROM loans
WHERE status = 'Not Returned';

-- Retrieve all loans with user information
SELECT l.*, u.first_name, u.last_name
FROM loans l
JOIN users u ON l.user_id = u.user_id;

-- Retrieve fines with user information for unpaid fines
SELECT f.*, u.first_name, u.last_name
FROM fines f
JOIN users u ON f.user_id = u.user_id
WHERE f.fine_status = 'Unpaid';

-- Retrieve the total amount of unpaid fines per user
SELECT u.user_id, u.first_name, u.last_name, SUM(f.fine_amount) AS total_unpaid_fines
FROM users u
LEFT JOIN fines f ON u.user_id = f.user_id AND f.fine_status = 'Unpaid'
GROUP BY u.user_id, u.first_name, u.last_name;

-- Retrieve the average fine amount for paid fines
SELECT ROUND(AVG(f.fine_amount), 2) AS average_paid_fine
FROM fines f
WHERE f.fine_status = 'Paid';


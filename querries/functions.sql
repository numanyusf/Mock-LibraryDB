-- Active: 1703100583880@@127.0.0.1@5432@librarydb@public

-- Function for updating records into loans, copies_of_books, fines based on loan status 
CREATE OR REPLACE FUNCTION update_loan_status(
    p_loan_id INT,
    p_return_date DATE
) RETURNS VOID AS $$
DECLARE
    v_due_date DATE;
    v_days_late INT;
    v_fine_amount INT;
BEGIN
    -- Check if the loan exists
    IF NOT EXISTS (SELECT 1 FROM loans WHERE loan_id = p_loan_id) THEN
        RAISE EXCEPTION 'Loan with ID % does not exist', p_loan_id;
    END IF;

    -- Get the due date for the loan
    SELECT due_date INTO v_due_date FROM loans WHERE loan_id = p_loan_id;

    -- Update the return_date and status in the loans table
    UPDATE loans
    SET return_date = p_return_date,
        status = 'Returned'
    WHERE loan_id = p_loan_id;

    -- Update the record in copies_of_books table
    UPDATE copies_of_books c
    SET on_loan = GREATEST(c.on_loan - 1, 0),
        availability = CASE
            WHEN c.availability = 'Not Available' AND (c.on_loan - 1) = 0 THEN 'Available'
            ELSE c.availability
        END
    FROM loans l
    WHERE l.copy_id = c.copy_id AND l.loan_id = p_loan_id;

    -- If return_date is later than due_date, insert record into fines table
    IF p_return_date > v_due_date THEN
        -- Calculate the number of days the book is returned late
        v_days_late := p_return_date - v_due_date;

        -- Calculate the fine amount
        v_fine_amount := v_days_late * 5; 

        -- Insert data into the fines table
        INSERT INTO fines (fine_amount, fine_status, due_date, user_id, loan_id)
        VALUES (v_fine_amount, 'Unpaid', v_due_date, (SELECT user_id FROM loans WHERE loan_id = p_loan_id), p_loan_id);
    END IF;

END;
$$ LANGUAGE plpgsql;

-- -- Testing of the function update_loan_status 
SELECT * FROM loans WHERE loan_id BETWEEN 1 AND 10;
SELECT *
FROM copies_of_books
INNER JOIN loans ON copies_of_books.copy_id = loans.copy_id
WHERE loan_id BETWEEN 1 AND 10;  
SELECT update_loan_status(6, '2024-01-01');
SELECT update_loan_status(7, '2024-01-15');
SELECT update_loan_status(8, '2023-12-25');
SELECT update_loan_status(4, '2023-12-31');
SELECT update_loan_status(5, '2023-12-10');
SELECT * FROM loans WHERE loan_id BETWEEN 1 AND 10;
SELECT * FROM fines;

-- Function for updating due date in loans table
CREATE OR REPLACE FUNCTION extend_due_date(
    p_loan_id INT,
    p_extension_days INT
) RETURNS VOID AS $$
DECLARE
    v_current_due_date DATE;
    v_book_status VARCHAR(15);
    v_new_due_date DATE;
BEGIN
    -- Check if the loan exists
    IF NOT EXISTS (SELECT 1 FROM loans WHERE loan_id = p_loan_id) THEN
        RAISE EXCEPTION 'Loan with ID % does not exist', p_loan_id;
    END IF;

    -- Get the current due date and book status for the loan
    SELECT due_date, status INTO v_current_due_date, v_book_status
    FROM loans
    WHERE loan_id = p_loan_id;

    -- Check if the book is already returned
    IF v_book_status = 'Returned' THEN
        RAISE EXCEPTION 'Cannot extend due date for a returned book (Loan ID: %)', p_loan_id;
    END IF;

    -- Calculate the new due date after extension
    v_new_due_date := v_current_due_date + p_extension_days;

    -- Update the due_date in the loans table
    UPDATE loans
    SET due_date = v_new_due_date
    WHERE loan_id = p_loan_id;

END;
$$ LANGUAGE plpgsql;

-- Testing of the function extend_due_date
SELECT * FROM loans WHERE loan_id BETWEEN 1 AND 10;
SELECT extend_due_date(9, 5);
SELECT extend_due_date(10, 10);
SELECT extend_due_date(7, 10);
SELECT * FROM loans WHERE loan_id BETWEEN 1 AND 10;


-- Function to update user membership status to inactive based on fines non payment
CREATE OR REPLACE FUNCTION update_membership_status()
RETURNS VOID AS
$$
BEGIN
    -- Update membership status based on unpaid fines after 15 days
    UPDATE users
    SET membership_status = 'Inactive'
    WHERE user_id IN (
        SELECT u.user_id
        FROM users u
        JOIN fines f ON u.user_id = f.user_id
        WHERE f.due_date + INTERVAL '15 days' < CURRENT_DATE
        AND f.fine_status = 'Unpaid'
    );
END;
$$
LANGUAGE plpgsql;

-- Testing of the function update_membership_status
SELECT * from fines;
 SELECT update_membership_status();
 SELECT * from users WHERE user_id = 206;


CREATE OR REPLACE FUNCTION update_fine_payment(
    p_fine_id INT,
    p_payment_date DATE,
    p_payment_amount DECIMAL(10, 2)
) RETURNS VOID AS $$
DECLARE
    v_total_fine_amount DECIMAL(10, 2);
    v_total_paid_amount DECIMAL(10, 2);
    v_remaining_amount DECIMAL(10, 2);
BEGIN
    -- Get the total fine amount
    SELECT fine_amount INTO v_total_fine_amount
    FROM fines AS f
    WHERE f.fine_id = p_fine_id;

    -- Check if v_total_fine_amount is NULL
    IF v_total_fine_amount IS NULL THEN
        RAISE EXCEPTION 'Fine with ID % does not exist', p_fine_id;
    END IF;

    -- Get the total amount paid for the fine
    SELECT COALESCE(SUM(fp.payment_amount), 0) INTO v_total_paid_amount
    FROM fine_payments AS fp
    WHERE fp.fine_id = p_fine_id;

    -- Calculate the remaining amount to be paid
    v_remaining_amount := v_total_fine_amount - v_total_paid_amount;

    -- Insert payment record
    INSERT INTO fine_payments (fine_id, payment_date, payment_amount)
    VALUES (p_fine_id, p_payment_date, p_payment_amount);

    -- Update fine record with remaining amount if not fully paid
    IF v_remaining_amount > 0 THEN
        UPDATE fines AS f
        SET fine_status = 'Partial',
            fine_amount = v_remaining_amount
        WHERE f.fine_id = p_fine_id;
    ELSE
        -- Update fine_status to mark the fine as paid
        UPDATE fines AS f
        SET fine_status = 'Paid'
        WHERE f.fine_id = p_fine_id;
    END IF;
END;
$$ LANGUAGE plpgsql;



SELECT update_fine_payments(1, '2023-12-03', 25.00);

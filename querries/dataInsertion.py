import json
from random import random, choice, uniform, randint
import psycopg2
from faker import Faker
from datetime import timedelta
import pandas as pd

# Read configuration from JSON file
config = json.load(open("config.json"))[0]

# Set up a connection to your PostgreSQL database using the configuration
connection = psycopg2.connect(
    host=config["DB_HOST"],
    user=config["DB_USER"],
    password=config["DB_PASSWORD"],
    database=config["DB_DATABASE"]
)

# Create a cursor object
cursor = connection.cursor()

fake = Faker()

def generate_user_data():
    return {
        'first_name': fake.first_name(),
        'last_name': fake.last_name(),
        'date_of_birth': fake.date_of_birth(minimum_age=18, maximum_age=80),
        'profession': choice(['Researcher', 'Journalist', 'Historian', 'Teacher', 'Student', 'Scholar', 'Novelist', 'Translator', 'Academic Advisor', 'Architect', 'Literary Scholar', 'Cultural Anthropologist', 'Book Collector', 'Language Specialist', 'Community Organizer']),
        'address': fake.address(),
        'email': fake.email(),
        'membership_status': choice(['Active', 'Inactive'])
    }
# Function to generate fake data for suppliers table
def generate_supplier_data():
    return {
        'supplier_name': fake.unique.company(),
        'contact_person': fake.name(),
        'contact_email': fake.email(),
        'contact_phone': fake.phone_number(),
        'address': fake.address()
    }

# Function to generate fake data for purchases table
def generate_purchase_data(supplier_id):
    return {
        'purchase_date': fake.date_between(start_date='-365d', end_date='today'),
        'total_cost': round(uniform(100, 10000), 2),
        'supplier_id': supplier_id
    }

# Function to generate fake data for purchase_details table
def generate_purchase_detail_data(purchase_id):
    return {
        'purchase_id': purchase_id,
        'quantity': randint(1, 10),
        'unit_cost': round(uniform(5, 50), 2)
    }

# Insert data into the users, suppliers, purchases, and purchase_details tables
for _ in range(1000):
    # Insert data into the users table
    query = """
            INSERT INTO users (first_name, last_name, date_of_birth, profession, address, email, membership_status)
            VALUES (%(first_name)s, %(last_name)s, %(date_of_birth)s, %(profession)s, %(address)s, %(email)s, %(membership_status)s)
            RETURNING user_id;
            """
    cursor.execute(query, generate_user_data())
   
    # Insert data into the suppliers table
    query = """
            INSERT INTO suppliers (supplier_name, contact_person, contact_email, contact_phone, address)
            VALUES (%(supplier_name)s, %(contact_person)s, %(contact_email)s, %(contact_phone)s, %(address)s)
            RETURNING supplier_id;
            """
    cursor.execute(query, generate_supplier_data())
    # Get the returned supplier_id
    supplier_id = cursor.fetchone()[0]
    
    # Insert data into the purchases table
    query = """
            INSERT INTO purchases (purchase_date, total_cost, supplier_id)
            VALUES (%(purchase_date)s, %(total_cost)s, %(supplier_id)s)
            RETURNING purchase_id;
            """
    cursor.execute(query, generate_purchase_data(supplier_id))
    # Get the returned purchase_id
    purchase_id = cursor.fetchone()[0]  

    # Insert data into the purchase_details table
    query = """
            INSERT INTO purchase_details (purchase_id, quantity, unit_cost)
            VALUES (%(purchase_id)s, %(quantity)s, %(unit_cost)s)
            """
    cursor.execute(query, generate_purchase_detail_data(purchase_id))
# Commit the changes to the database
connection.commit()

# Function to generate fake data for copy_of_books table
def generate_copy_data(book_id):
    copies_data = []
    # Assign copies based on total_copies
    total_copies = randint(1, 5)

    for copy_number in range(1, total_copies + 1):
        # Calculate available_copies
        available_copies = 1 if random() < 0.75 else 0
        # Assign on_loan based on availability
        on_loan = 1 if available_copies == 0 else 0
        # Assign availability based on probability
        availability = 'Available' if available_copies > 0 else 'Not Available'

        copy_data = {
            'availability': availability,
            'on_loan': on_loan,
            'book_id': book_id,
        }
        copies_data.append(copy_data)

    return copies_data

# Function to generate fake data for loans table
def generate_loan_data(user_id, copy_id):
    due_date = fake.date_between(start_date='-30d', end_date='today')
    start_date = due_date - timedelta(days=fake.random_int(min=1, max=7))
    return_date = None
    status = 'Not Returned'
    
    return {
        'start_date': start_date,
        'due_date': due_date,
        'return_date': return_date,
        'status': status,
        'user_id': user_id,
        'copy_id': copy_id
    }

# Path to GoodReads_100k_books CSV file
path = 'C:/Users/numan/Projects/Mock-LibraryDB/data/GoodReads_100k_books.csv'
df = pd.read_csv(path).drop(['img', 'isbn13', 'link'], axis=1)
book_data = df.dropna()

# Insert unique genres into genres table
unique_genres = set(genre.strip() for genres in book_data['genre'].dropna() for genre in genres.split(','))
for genre in unique_genres:
    query = """
            INSERT INTO genres (genre_name) 
            VALUES (%s) 
            ON CONFLICT (genre_name) DO NOTHING;
            """
    cursor.execute(query, (genre,))
connection.commit()

# Insert unique authors into authors table
unique_authors = set(author.strip() for authors in book_data['author'].dropna() for author in authors.split(','))
for author in unique_authors:
    query = """
            INSERT INTO authors (author_name) 
            VALUES (%s) 
            ON CONFLICT (author_name) DO NOTHING;
            """
    cursor.execute(query, (author,))
connection.commit()

# Define the SQL query to fetch user_id from users
query = """
        SELECT user_id
        FROM users;
        """
# Execute the SQL query to fetch users_ids
cursor.execute(query)
# Fetch all the selected user_ids
user_ids = cursor.fetchall() 

# Insert Books, Genres, Authors, Reviews, and Ratings
for _, row in book_data.iterrows():
    # Insert data into the books table
    query = """
            INSERT INTO books (title, description, isbn, pages, book_format) 
            VALUES (%(title)s, %(description)s, %(isbn)s, %(pages)s, %(book_format)s)
            RETURNING book_id;
            """
    cursor.execute(query, 
    {
        'title': row['title'],
        'description': row['desc'],
        'isbn': row['isbn'],
        'pages': row['pages'],
        'book_format': row['bookformat']
    })
    # Get the returned book_id
    book_id = cursor.fetchone()[0]
    
    # Insert data into the book_genres table
    if pd.notna(row['genre']):
        genres = [genre.strip() for genre in row['genre'].split(',')]
        for genre in genres:
            query = """
                    INSERT INTO book_genres (book_id, genre_id) 
                    SELECT %(book_id)s, genre_id 
                    FROM genres WHERE genre_name = %(genre_name)s 
                    ON CONFLICT (book_id, genre_id) DO NOTHING;
                    """
            cursor.execute(query, 
            {
                'book_id': book_id,
                'genre_name': genre
            })

    # Insert data into the book_author table
    if pd.notna(row['author']):
        authors = [author.strip() for author in row['author'].split(',')]
        for author in authors:
            query = """
                    INSERT INTO book_author (book_id, author_id) 
                    SELECT %(book_id)s, author_id 
                    FROM authors WHERE author_name = %(author_name)s 
                    ON CONFLICT (book_id, author_id) DO NOTHING;
                    """
            cursor.execute(query, 
            {
                'book_id': book_id,
                'author_name': author
            })
    
    # Get a random user_id from the fetched list
    user_id = choice(user_ids)[0]
    
    # Insert data into the book_reviews table
    query = """
            INSERT INTO book_reviews (reviews, user_id, book_id)
            VALUES (%(reviews)s, %(user_id)s, %(book_id)s);
            """
    cursor.execute(query, 
    {
        'reviews': row['reviews'],
        'user_id': user_id,
        'book_id': book_id
    })

    # Insert data into the book_ratings table
    query = """
            INSERT INTO book_ratings (rating, total_ratings, book_id, user_id) 
            VALUES (%(rating)s, %(total_ratings)s, %(book_id)s, %(user_id)s);
            """
    cursor.execute(query, 
    {
        'rating': row['rating'],
        'total_ratings': row['totalratings'],
        'book_id': book_id,
        'user_id': user_id
    })
    
    # Insert data into the copies_of_books table
    for copy_data in generate_copy_data(book_id):
        query = """
                INSERT INTO copies_of_books (availability, on_loan, book_id)
                VALUES (%(availability)s, %(on_loan)s, %(book_id)s)
                RETURNING copy_id, on_loan;
                """
        cursor.execute(query, copy_data)
        # Fetch the copy_id and availability of the inserted record
        copy_info = cursor.fetchone()
        copy_id, on_loan = copy_info[0], copy_info[1]

        # Check if the book copy is on loan
        if on_loan == 1:
            # Insert the copies which are on loan
            query = """
                    INSERT INTO loans (start_date, due_date, status, user_id, copy_id)
                    VALUES (%(start_date)s, %(due_date)s, %(status)s, %(user_id)s, %(copy_id)s)
                    RETURNING loan_id;
                    """
            cursor.execute(query, generate_loan_data(user_id, copy_id))
                    
    # Commit the changes to the database
    connection.commit()

# Close the cursor and connection
cursor.close()
connection.close()

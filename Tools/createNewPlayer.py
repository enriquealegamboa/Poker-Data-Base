import mysql.connector
from mysql.connector import errorcode 
import re
import maskpass

userName = input("Enter User Name: ")
pw = maskpass.askpass(mask="*")

try:
    db = mysql.connector.connect(
    host="localhost",
    user=userName,
    password= pw
    )
except mysql.connector.Error as err:
    print("Error connecting to database.")
    exit(1)

cursor = db.cursor()

try:
    cursor.execute("USE Poker;")
except mysql.connector.Error as err:
    print("Database not found:", err)
    cursor.close()
    db.close()
    exit(1)


while True:
    try:
        parts = input("Player Info (First Middle Last): ").split()
        if len(parts) != 3:
            raise ValueError("Must enter exactly 3 names (First Middle Last)")
        first, middle, last = parts

        dob_str = input("Date of Birth (yyyy-mm-dd): ")
        dob = datetime.datetime.strptime(dob_str, "%Y-%m-%d").date()
        break
    except ValueError as e:
        print(f"Invalid input")




try:
    query = """
    INSERT INTO PLAYER (First, Middle, Last, DOB)
    VALUES (%s, %s, %s, %s)
    """
    values = (first, middle, last, dob)
    cursor.execute(query, values)
    db.commit()
    print("New player created successfully!")
except mysql.connector.Error as err:
    print("Failed to insert new player:", err)
finally:
    cursor.close()
    db.close()


import mysql.connector
from mysql.connector import errorcode 
import re
import maskpass

pw = maskpass.askpass(mask="")

db = mysql.connector.connect(
  host="localhost",
  user="Quique",
  password= pw
)

cursor = db.cursor()


while True:
    try:
        first, middle, last = input("PLayer Info: First Middle Last: ").split()
        dob = input("Date of Birth - yyyy-mm-dd: ")
        break
    except ValueError:
        print("Invalid input")
cursor.execute("USE Poker;")

#New Player ID number
query = "SELECT COUNT(*) FROM PLAYER"
cursor.execute(query)
result = cursor.fetchall()
string_result = str(result[0])
match = re.search(r'\d+', string_result)
id_number = match.group(0)

try:
    query = "INSERT INTO PLAYER (Account_Number, First, Middle, Last, DOB) VALUES (%s, %s, %s, %s, %s)"
    values = (id_number, first, middle, last, dob)
    cursor.execute(query, values)
    db.commit()
    print("New User Created\n")
except mysql.connector.Error as err:
    print("Faild to insert new player.")
    print(err)
finally:
    db.close()
    cursor.close()


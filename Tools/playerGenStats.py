import mysql.connector
from mysql.connector import errorcode
import maskpass
import sys

while True:
    try:
        account = input("Account Name: ")
        pw = maskpass.askpass(mask="")

        db = mysql.connector.connect( 
            host="localhost",
            user=account,
            password= pw
        )
        cursor = db.cursor()
        print("Signed In")
        break
    except mysql.connector.Error as err:
        print("Faild to sign in.")
        print(err)
    except KeyboardInterrupt:
        print("\nProgram interrupted by user. Exiting.")
        sys.exit()

sql_file_path = 'SQL/playerStats.sql'
sql_script = ""
with open(sql_file_path, 'r') as file:
    sql_script = file.read()

cursor.execute("USE Poker;")

while True:
    try:
        account_number = input("Enter Player Account Number:")
        if account_number == 'q':
            print("Exiting.")
            sys.exit()
        account_number = (account_number,)
        cursor.execute(sql_script, account_number)
        result = cursor.fetchall()
        for row in result:
            print(row)
        print("SQL script executed successfully.")
    except mysql.connector.Error as e:
        print(f"Error executing SQL script")
        db.rollback()
    finally:
        print("done")
        #cursor.close()
        #db.close()


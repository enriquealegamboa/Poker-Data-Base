import mysql.connector

mydb = mysql.connector.connect(
  host="localhost",
  user="Quique",
  password=""
)

mycursor = mydb.cursor()
mycursor.execute("CREATE DATABASE Poker;")
mycursor.execute("USE Poker;")
# Read the SQL file
sql_file_path = 'SQL/dbTableCreation.sql'
with open(sql_file_path, 'r') as file:
    sql_script = file.read()
try:
    result = mycursor.execute(sql_script)
    print("SQL script executed successfully.")
except mysql.connector.Error as e:
    print(f"Error executing SQL script: {e}")
    mydb.rollback()
finally:
    mycursor.close()
    mydb.close()
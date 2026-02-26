import mysql.connector


mydb = mysql.connector.connect(
  host="localhost",
  user="Quique",
  password=""
)

mycursor = mydb.cursor()
mycursor.execute("DROP DATABASE Poker;")
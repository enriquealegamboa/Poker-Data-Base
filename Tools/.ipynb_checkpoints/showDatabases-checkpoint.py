import mysql.connector

mydb = mysql.connector.connect(
  host="localhost",
  user="Quique",
  password="600216"
)

mycursor = mydb.cursor()

mycursor.execute("SHOW DATABASES")

for x in mycursor:
  print(x)
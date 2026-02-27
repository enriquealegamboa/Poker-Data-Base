import mysql.connector
from mysql.connector import errorcode 
import re
import maskpass


userName = input("Enter User Name: ")
pw = maskpass.askpass(mask="*")

mydb = mysql.connector.connect(
  host="localhost",
  user=userName,
  password=pw
)

delete = input("Are sure you want to permanently delete Poker Data base? (Y/n):")
if(delete == "Y"):
  mycursor = mydb.cursor()
  mycursor.execute("DROP DATABASE Poker;")
  print("Poker Database DELETED.")
else:
  print("Poker Database NOT deleted.")
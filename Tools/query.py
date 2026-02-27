import mysql.connector
from mysql.connector import errorcode 
import maskpass
from pathlib import Path 

def get_game_with_most_rounds(cursor):
    query = """
    SELECT
    DISTINCT 
        g.Game_ID,
        g.Game_Date,
        g.Number_of_Players,
        p.First,
        p.Middle,
        p.Last
    FROM GAME g
    JOIN ROUND r 
        ON g.Game_ID = r.Game_ID
    JOIN PLAYER_ROUND pr 
        ON r.Game_ID = pr.Game_ID 
        AND r.Round_ID = pr.Round_ID
    JOIN PLAYER p 
        ON pr.Player_ID = p.Account_Number
    WHERE g.Game_ID = (
        SELECT Game_ID
        FROM ROUND
        GROUP BY Game_ID
        ORDER BY COUNT(*) DESC
        LIMIT 1
    );
    """
    cursor.execute(query)
    return cursor.fetchall()

def get_biggest_round_loss(cursor):
    query = """
    SELECT 
        pr.Game_ID,
        p.First,
        p.Last,
        pr.Profit AS Most_Money_Lost
    FROM PLAYER_ROUND pr
    JOIN PLAYER p 
        ON pr.Player_ID = p.Account_Number
    WHERE pr.Profit = (
        SELECT MIN(Profit)
        FROM PLAYER_ROUND
        HAVING MIN(Profit) < 0
    )
    ORDER BY pr.Game_ID;
    """
    cursor.execute(query)
    return cursor.fetchall()

def get_first_place_players_largest_prize(cursor):
    query = """
    SELECT 
        p.First,
        p.Middle,
        p.Last,
        MAX(g.Prize_Pool) AS Largest_Prize_Pool
    FROM GAME_RESULT gr
    JOIN PLAYER p 
        ON gr.Player_ID = p.Account_Number
    JOIN GAME g 
        ON gr.Game_ID = g.Game_ID
    WHERE gr.Placement = 1
    GROUP BY p.Account_Number, p.First, p.Middle, p.Last
    ORDER BY Largest_Prize_Pool DESC;
    """
    cursor.execute(query)
    return cursor.fetchall()

def count_players_won_without_showing(cursor):
    query = """
    SELECT 
        COUNT(DISTINCT ph.Player_ID) 
        AS Number_Of_Players_Won_No_Hand_Show
    FROM PLAYER_HAND ph
    JOIN PLAYER_ROUND pr
        ON ph.Game_ID = pr.Game_ID
        AND ph.Round_ID = pr.Round_ID
        AND ph.Player_ID = pr.Player_ID
    WHERE ph.Shown = 0
      AND pr.Won = 1;
    """
    cursor.execute(query)
    return cursor.fetchone()[0]

def get_winning_pair_hands(cursor):
    query = """
    SELECT DISTINCT 
        h1.Card_Code,
        h1.Game_ID,
        h1.Round_ID
    FROM PLAYER_HAND h1
    JOIN PLAYER_HAND h2
        ON h1.Game_ID = h2.Game_ID
        AND h1.Round_ID = h2.Round_ID
        AND h1.Player_ID = h2.Player_ID
        AND SUBSTR(h1.Card_Code, 2, 1) = SUBSTR(h2.Card_Code, 2, 1)
        AND SUBSTR(h1.Card_Code, 1, 1) <> SUBSTR(h2.Card_Code, 1, 1)
    JOIN PLAYER_ROUND pr
        ON h1.Game_ID = pr.Game_ID
        AND h1.Round_ID = pr.Round_ID
        AND h1.Player_ID = pr.Player_ID
    WHERE pr.Won = 1;
    """
    cursor.execute(query)
    return cursor.fetchall()

userName = input("Enter User Name: ")
pw = maskpass.askpass(mask="*")

try:
    mydb = mysql.connector.connect(
    host="localhost",
    user= userName,
    password=pw,
    database = "Poker"
    )
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Wrong username or password")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
    else:
        print(err)
    exit(1)


mycursor = mydb.cursor(buffered = True)
try:
    print(get_game_with_most_rounds(mycursor))
    print(get_biggest_round_loss(mycursor))
    print(get_first_place_players_largest_prize(mycursor))
    print(count_players_won_without_showing(mycursor))
    print(get_winning_pair_hands(mycursor))
except mysql.connector.Error as e:
    print(f"Error executing SQL script.")
    mydb.rollback()
finally:
    mycursor.close()
    mydb.close()

/*Give me the game ID number and date that had the most rounds played, how many players played, and the names of players.*/
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

/*Game Date will be different since inserts sets the date of the game by default to todays date*/
/*
+---------+---------------+-------------------+-------+--------+---------+
| Game_ID |   Game_Date   | Number_of_Players | First | Middle | Last    |
+---------+---------------+-------------------+-------+--------+---------+
|       0 |   2024-04-12  |                 2 | Max   | Ale    | Gambino |
|       0 |   2024-04-12  |                 2 | Lara  | Stacey | Strong  |
+---------+---------------+-------------------+-------+--------+---------+
*/

/*Give me the players first and last name that lost the most money in a round, how much they lost, and the game ID in which the round was played.*/
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
/*
+---------+-------+--------+-----------------+
| Game_ID | First | Last   | Most_Money_Lost |
+---------+-------+--------+-----------------+
|       0 | Lara  | Strong |             -15 |
+---------+-------+--------+-----------------+
*/

/*List the names of players that have at least gotten first place once and the largest prize pool that they won.*/
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
/*
+-------+-----------+------------+--------------------+
| FIRST | MIDDLE    | LAST       | Largest_Prize_Pool |
+-------+-----------+------------+--------------------+
| Moshe | Nina      | Austin     |               1000 |
| Daisy | Mccormick | Benton     |               1000 |
| Max   | Ale       | Gambino    |                900 |
| Ray   | Cole      | Santana    |                600 |
| Darcy | Kingsley  | Villarreal |                200 |
+-------+-----------+------------+--------------------+
*/

/*How many players have won a round without showing their hand cards?*/
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
/*
+------------------------------------+
| NUMBER_OF_PLAYERS_WON_NO_HAND_SHOW |
+------------------------------------+
|                                  1 |
+------------------------------------+
*/

/*List all the hand cards that are a pair and the player who was dealt those hand cards won the round*/
/*The first character is the suite and the second is the value*/
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

 /*
 +----------------+---------+--------------+
| Card_Code       | Game_ID | Round_ID     |
+-----------------+---------+--------------+
| C9              |       0 |            0 |
| D9              |       0 |            0 |
+-----------------+---------+--------------+
*/
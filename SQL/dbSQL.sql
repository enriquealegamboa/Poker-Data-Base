/*Give me the game ID number and date that had the most rounds played, how many players played, and the names of players.*/
SELECT Unique_Number AS GAME_ID, Number_of_Players, GAME_DATE, First, Middle, Last
FROM TAKES_PART_IN AS T, PLAYER, GAME
WHERE T.PTPI = PLAYER.Account_Number AND Unique_Number = GNumber AND RTPI = (SELECT MAX(RTPI) AS RTPI FROM TAKES_PART_IN GROUP BY GNumber);

/*Game Date will be different since inserts sets the date of the game by default to todays date*/
/*
+---------+-------------------+------------+-------+--------+---------+
| GAME_ID | Number_of_Players | GAME_DATE  | First | Middle | Last    |
+---------+-------------------+------------+-------+--------+---------+
|       0 |                 2 | 2024-04-12 | Max   | Ale    | Gambino |
|       0 |                 2 | 2024-04-12 | Lara  | Stacey | Strong  |
+---------+-------------------+------------+-------+--------+---------+
*/

/*Give me the players first and last name that lost the most money in a round, how much they lost, and the game ID in which the round was played.*/
SELECT DISTINCT GNumber AS GAME_ID, First, Last, Profit AS MOST_MONEY_LOST
FROM TAKES_PART_IN AS T, PLAYER, GAME
WHERE T.PTPI = PLAYER.Account_Number AND Profit = (SELECT MIN(Profit) AS Profit FROM TAKES_PART_IN GROUP BY GNumber HAVING MIN(Profit)<0)
ORDER BY GAME_ID;
/*
+---------+-------+--------+-----------------+
| GAME_ID | First | Last   | MOST_MONEY_LOST |
+---------+-------+--------+-----------------+
|       0 | Lara  | Strong |             -15 |
+---------+-------+--------+-----------------+
*/

/*List the names of players that have at least gotten first place once and the largest prize pool that they won.*/
SELECT FIRST, MIDDLE, LAST, MAX(Prize_Pool) AS PRIZE_POOL
FROM PLAYER AS P, GAME AS G, PLACES AS L
WHERE P.Account_Number = L.PAN AND G.Unique_Number = L.GUN AND L.Placement =1
GROUP BY Account_Number, FIRST, MIDDLE, LAST
ORDER BY PRIZE_POOL DESC;

/*
+-------+-----------+------------+------------+
| FIRST | MIDDLE    | LAST       | PRIZE_POOL |
+-------+-----------+------------+------------+
| Moshe | Nina      | Austin     |       1000 |
| Daisy | Mccormick | Benton     |       1000 |
| Max   | Ale       | Gambino    |        900 |
| Ray   | Cole      | Santana    |        600 |
| Darcy | Kingsley  | Villarreal |        200 |
+-------+-----------+------------+------------+
*/

/*How many players have won a round without showing their hand cards?*/
SELECT COUNT(Account_Number) AS NUMBER_OF_PLAYERS_WON_NO_HAND_SHOW
FROM PLAYER
WHERE Account_Number IN (
SELECT DISTINCT T.PTPI
FROM TAKES_PART_IN AS T, HAND AS H
WHERE T.PTPI = H.PTPI AND H.Shown = 0 AND T.Won =1);

/*
+------------------------------------+
| NUMBER_OF_PLAYERS_WON_NO_HAND_SHOW |
+------------------------------------+
|                                  1 |
+------------------------------------+
*/

/*List all the hand cards that are a pair and the player who was dealt those hand cards won the round*/
/*The first character is the suite and the second is the value*/
SELECT DISTINCT H1.Card_Identifier, H1.GNumber AS GAME_ID, H1.RTPI AS ROUND_NUMBER
FROM HAND AS H1, HAND AS H2, TAKES_PART_IN AS T
WHERE T.Won = 1 AND SUBSTR(H1.Card_Identifier, 2,1) = SUBSTR(H2.Card_Identifier, 2,1) AND
 SUBSTR(H1.Card_Identifier, 1,1) != SUBSTR(H2.Card_Identifier, 1,1) AND H1.GNumber = H2.GNumber AND H1.RTPI = H2.RTPI AND H1.PTPI = H2.PTPI;

 /*
 +-----------------+---------+--------------+
| Card_Identifier | GAME_ID | ROUND_NUMBER |
+-----------------+---------+--------------+
| C9              |       0 |            0 |
| D9              |       0 |            0 |
+-----------------+---------+--------------+
*/
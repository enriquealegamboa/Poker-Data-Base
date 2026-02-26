-- ============================================
-- PLAYER
-- ============================================

CREATE TABLE PLAYER (
    Account_Number INT PRIMARY KEY,
    First VARCHAR(15) NOT NULL,
    Middle VARCHAR(15),
    Last VARCHAR(15) NOT NULL,
    DOB DATE NOT NULL,
    Total_Profit INT NOT NULL DEFAULT 0,
    Account_Creation DATE NOT NULL DEFAULT (CURRENT_DATE)
);

DELIMITER //

CREATE TRIGGER DATE_VIOLATION
BEFORE INSERT ON PLAYER
FOR EACH ROW
BEGIN
    IF NEW.DOB > DATE_SUB(CURDATE(), INTERVAL 18 YEAR) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Must be 18 or older';
    END IF;
END//

DELIMITER ;

-- ============================================
-- GAME
-- ============================================

CREATE TABLE GAME (
    Game_ID INT PRIMARY KEY,
    Game_Date DATE NOT NULL DEFAULT (CURRENT_DATE),
    Buy_In INT NOT NULL,
    Number_of_Players INT NOT NULL,
    Prize_Pool INT NOT NULL
);

-- ============================================
-- ROUND (Each Hand)
-- ============================================

CREATE TABLE ROUND (
    Game_ID INT NOT NULL,
    Round_ID INT NOT NULL,
    Pot_Size INT NOT NULL DEFAULT 0,
    Phase_End CHAR(1) NOT NULL,

    Small_Blind_Player INT NOT NULL,
    Big_Blind_Player INT NOT NULL,
    Small_Blind_Size INT NOT NULL,
    Big_Blind_Size INT NOT NULL,

    PRIMARY KEY (Game_ID, Round_ID),

    FOREIGN KEY (Game_ID)
        REFERENCES GAME(Game_ID)
        ON DELETE CASCADE,

    FOREIGN KEY (Small_Blind_Player)
        REFERENCES PLAYER(Account_Number),

    FOREIGN KEY (Big_Blind_Player)
        REFERENCES PLAYER(Account_Number)
);

-- ============================================
-- PLAYER_ROUND (Replaces TAKES_PART_IN)
-- ============================================

CREATE TABLE PLAYER_ROUND (
    Game_ID INT NOT NULL,
    Round_ID INT NOT NULL,
    Player_ID INT NOT NULL,

    Profit INT NOT NULL DEFAULT 0,
    Won BOOLEAN NOT NULL DEFAULT 0,

    PRIMARY KEY (Game_ID, Round_ID, Player_ID),

    FOREIGN KEY (Game_ID, Round_ID)
        REFERENCES ROUND(Game_ID, Round_ID)
        ON DELETE CASCADE,

    FOREIGN KEY (Player_ID)
        REFERENCES PLAYER(Account_Number)
        ON DELETE CASCADE
);

-- ============================================
-- ACTION
-- ============================================

CREATE TABLE ACTION (
    Game_ID INT NOT NULL,
    Round_ID INT NOT NULL,
    Player_ID INT NOT NULL,

    Phase CHAR(1) NOT NULL,        -- P=Preflop, F=Flop, T=Turn, R=River
    Action_Type CHAR(2) NOT NULL,  -- F, C, R, SB, BB
    Bet_Size INT NOT NULL DEFAULT 0,
    Is_Forced BOOLEAN NOT NULL DEFAULT 0,

    Action_Order INT NOT NULL,

    PRIMARY KEY (Game_ID, Round_ID, Player_ID, Phase, Action_Order),

    FOREIGN KEY (Game_ID, Round_ID, Player_ID)
        REFERENCES PLAYER_ROUND(Game_ID, Round_ID, Player_ID)
        ON DELETE CASCADE,

    CHECK (Action_Type IN ('F','C','R','SB','BB'))
);

-- ============================================
-- CARD
-- ============================================

CREATE TABLE CARD (
    Card_Code CHAR(2) PRIMARY KEY
);

-- ============================================
-- PLAYER HAND (Hole Cards)
-- ============================================

CREATE TABLE PLAYER_HAND (
    Game_ID INT NOT NULL,
    Round_ID INT NOT NULL,
    Player_ID INT NOT NULL,
    Card_Code CHAR(2) NOT NULL,
    Shown BOOLEAN NOT NULL DEFAULT 0,

    PRIMARY KEY (Game_ID, Round_ID, Player_ID, Card_Code),

    FOREIGN KEY (Game_ID, Round_ID, Player_ID)
        REFERENCES PLAYER_ROUND(Game_ID, Round_ID, Player_ID)
        ON DELETE CASCADE,

    FOREIGN KEY (Card_Code)
        REFERENCES CARD(Card_Code)
);

-- ============================================
-- COMMUNITY CARDS
-- ============================================

CREATE TABLE COMMUNITY_CARD (
    Game_ID INT NOT NULL,
    Round_ID INT NOT NULL,
    Card_Code CHAR(2) NOT NULL,
    Phase_Revealed CHAR(1) NOT NULL,

    PRIMARY KEY (Game_ID, Round_ID, Card_Code),

    FOREIGN KEY (Game_ID, Round_ID)
        REFERENCES ROUND(Game_ID, Round_ID)
        ON DELETE CASCADE,

    FOREIGN KEY (Card_Code)
        REFERENCES CARD(Card_Code)
);

-- ============================================
-- GAME RESULT
-- ============================================

CREATE TABLE GAME_RESULT (
    Game_ID INT NOT NULL,
    Player_ID INT NOT NULL,
    Placement INT NOT NULL,

    PRIMARY KEY (Game_ID, Player_ID),

    FOREIGN KEY (Game_ID)
        REFERENCES GAME(Game_ID)
        ON DELETE CASCADE,

    FOREIGN KEY (Player_ID)
        REFERENCES PLAYER(Account_Number)
        ON DELETE CASCADE
);

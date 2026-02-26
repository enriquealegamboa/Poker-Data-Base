SELECT 
    pr.Player_ID,

    COUNT(DISTINCT CONCAT(pr.Game_ID,'-',pr.Round_ID)) AS Hands_Played,

    COUNT(DISTINCT CASE 
        WHEN a.Phase = 'P'
         AND a.Is_Forced = 0
         AND a.Action_Type IN ('C','R')
        THEN CONCAT(a.Game_ID,'-',a.Round_ID)
    END) AS Hands_VPIP,

    ROUND(
        COUNT(DISTINCT CASE 
            WHEN a.Phase = 'P'
             AND a.Is_Forced = 0
             AND a.Action_Type IN ('C','R')
            THEN CONCAT(a.Game_ID,'-',pr.Round_ID)
        END)
        /
        COUNT(DISTINCT CONCAT(pr.Game_ID,'-',pr.Round_ID))
        * 100
    , 2) AS VPIP_Percentage,

    COUNT(DISTINCT CASE 
        WHEN a.Phase = 'P'
         AND a.Action_Type = 'R'
        THEN CONCAT(a.Game_ID,'-',a.Round_ID)
    END) AS PFR_Hands,

    ROUND(
        COUNT(DISTINCT CASE 
            WHEN a.Phase = 'P'
             AND a.Action_Type = 'R'
            THEN CONCAT(a.Game_ID,'-',pr.Round_ID)
        END)
        /
        COUNT(DISTINCT CONCAT(pr.Game_ID,'-',pr.Round_ID))
        * 100
    , 2) AS PFR_Percentage

FROM PLAYER_ROUND pr
LEFT JOIN ACTION a
    ON pr.Game_ID = a.Game_ID
   AND pr.Round_ID = a.Round_ID
   AND pr.Player_ID = a.Player_ID

WHERE pr.Player_ID = %s;

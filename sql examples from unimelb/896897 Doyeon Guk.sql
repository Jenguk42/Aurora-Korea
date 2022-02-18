-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\_____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////____/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\_____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\____/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////____\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\___________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\____________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\______________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///_________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: Doyeon Guk
-- Your Student Number: 896897
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT COUNT(*) AS speciesCount
FROM Species
WHERE description LIKE '%this%';

-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2

SELECT Player.username, 
	SUM(Phonemon.power) AS totalPhonemonPower
FROM Player INNER JOIN Phonemon
	ON Player.id = Phonemon.player
WHERE Player.username = 'Cook' OR Player.username = 'Hughes'
GROUP BY Player.username;

-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3

SELECT Team.title, COUNT(*) AS numberOfPlayers
FROM Player INNER JOIN Team
	ON Player.team = Team.id
GROUP BY Team.id
ORDER BY numberOfPlayers DESC;

-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT Species.id AS idSpecies, Species.title
FROM (Species INNER JOIN Type AS Type1 ON Species.type1 = Type1.id) 
	LEFT JOIN Type AS Type2 ON Species.type2 = Type2.id
WHERE Type1.title = 'Grass' OR Type2.title = 'Grass';

-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT DISTINCT id AS idPlayer, username
FROM Player
WHERE id NOT IN
	(SELECT DISTINCT Player.id
	FROM Player INNER JOIN Purchase
		ON Player.id = Purchase.player
	WHERE Purchase.item IN (SELECT id FROM Food));

-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6

SELECT Player.level, 
	SUM(Item.price*Purchase.quantity) AS totalAmountSpentByAllPlayersAtLevel
FROM (Player INNER JOIN Purchase ON Player.id = Purchase.player)
	INNER JOIN Item ON Purchase.item = Item.id
GROUP BY Player.level
ORDER BY totalAmountSpentByAllPlayersAtLevel DESC;

-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT Item.id AS item, Item.title, SUM(Purchase.quantity) AS numTimesPurchased
FROM Purchase INNER JOIN Item 
	ON Purchase.item = Item.id
GROUP BY Item.id
HAVING numTimesPurchased =
	(SELECT MAX(numTimesPurchased)
	FROM (SELECT SUM(Purchase.quantity) AS numTimesPurchased
		FROM Purchase INNER JOIN Item ON Purchase.item = Item.id
		GROUP BY Item.id) AS T);

-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8

SELECT Player.id AS playerID, Player.username,
	COUNT(DISTINCT Purchase.item) AS numberDistinctFoodItemsPurchased 
FROM (Purchase INNER JOIN Food ON Purchase.item = Food.id) 
	INNER JOIN Player ON Purchase.player = Player.id
GROUP BY Purchase.player
HAVING numberDistinctFoodItemsPurchased = 
	(SELECT COUNT(id) FROM Food);

-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT COUNT(*) AS numberOfPhonemonPairs, distanceX
FROM (SELECT P1.id AS 1id, P2.id AS 2id, 
		ROUND( SQRT( POWER(P1.latitude - P2.latitude, 2) + 
					POWER(P1.longitude - P2.longitude, 2)) * 100, 2) AS distanceX
	FROM Phonemon AS P1 CROSS JOIN Phonemon AS P2 ON P1.id < P2.id) AS T
GROUP BY distanceX
ORDER BY distanceX
LIMIT 1;

-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

-- If number of distinct species in type A = number of distinct type A phonemon caught by B, include (B, A) in result table
SELECT username, title
FROM ((SELECT username, type AS playerPhonemonType, SUM(typeCount) AS playerPhonemonTypeCount
	FROM (SELECT username, type1 AS type, COUNT(*) AS typeCount
		FROM (SELECT DISTINCT Phonemon.species, Player.username, Species.type1
			FROM (Player INNER JOIN Phonemon ON Player.id = Phonemon.player)
				INNER JOIN Species ON Phonemon.species = Species.id
			GROUP BY Player.username, Phonemon.species) AS T1 -- T1: Distinct species in type1 caught by player
		GROUP BY username, type1
		UNION ALL
		SELECT username, type2 AS type, COUNT(*) AS typeCount
		FROM (SELECT DISTINCT Phonemon.species, Player.username, Species.type2
			FROM (Player INNER JOIN Phonemon ON Player.id = Phonemon.player)
				INNER JOIN Species ON Phonemon.species = Species.id
			GROUP BY Player.username, Phonemon.species) AS T2 -- T2: Distinct species in type2 caught by player
		GROUP BY username, type2) AS T3  -- T3: Distinct species in type1 and type2, with duplicate values
	GROUP BY username, playerPhonemonType
	HAVING playerPhonemonType IS NOT NULL) AS T4 -- T4: Number of distinct type A phonemon caught by user B
    INNER JOIN
    (SELECT type, SUM(typeCount) AS typeCount
	FROM (SELECT type1 AS type, COUNT(*) AS typeCount
		FROM Species
		GROUP BY type1
	UNION ALL
	SELECT type2 AS type, COUNT(*) AS typeCount
		FROM Species
		GROUP BY type2) AS T5 -- T5: Number of distinct species in type1 and 2, with duplicate values
	GROUP BY type
	HAVING type IS NOT NULL) AS T6 -- T6: Number of distinct species in type A
    ON T4.playerPhonemonType = T6.type)
    INNER JOIN Type ON T6.type = Type.id
WHERE T4.playerPhonemonTypeCount = T6.typeCount;

-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line
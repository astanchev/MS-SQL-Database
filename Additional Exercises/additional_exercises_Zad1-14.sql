--1
USE Diablo
GO

SELECT [Email Provider], 
       COUNT(emailProviders.ID) AS [Number Of Users]
FROM
(
    SELECT u.ID, 
           SUBSTRING(u.Email, CHARINDEX('@', u.Email) + 1, (LEN(u.Email) - CHARINDEX('@', u.Email))) AS [Email Provider]
    FROM Users u
) AS emailProviders
GROUP BY [Email Provider]
ORDER BY [Number Of Users] DESC, 
         [Email Provider];

GO

--2
USE Diablo
GO

SELECT g.Name Game, 
       gt.Name [Game Type], 
       u.Username, 
       ug.Level, 
       ug.Cash, 
       c.Name [Character]
FROM dbo.Users u
     JOIN dbo.UsersGames ug ON u.Id = ug.UserId
     JOIN dbo.Games g ON ug.GameId = g.Id
     JOIN dbo.GameTypes gt ON g.GameTypeId = gt.Id
     JOIN dbo.Characters c ON ug.CharacterId = c.Id
ORDER BY ug.Level DESC, 
         u.Username, 
         g.Name;

GO

--3
USE Diablo
GO

SELECT u.Username, 
       g.Name Game, 
       COUNT(i.Id) [Items Count], 
       SUM(i.Price) [Items Price]
FROM dbo.Users u
     JOIN dbo.UsersGames ug ON u.Id = ug.UserId
     JOIN dbo.Games g ON ug.GameId = g.Id
     JOIN dbo.UserGameItems ugi ON ug.Id = ugi.UserGameId
     JOIN dbo.Items i ON ugi.ItemId = i.Id
GROUP BY u.Username, 
         g.Name
HAVING COUNT(i.Id) >= 10
ORDER BY [Items Count] DESC, 
         [Items Price] DESC, 
         u.Username;

GO

--4
USE Diablo
GO

SELECT u.Username, 
       g.Name AS Game, 
       MAX(c.Name) AS Character, 
       SUM(iStat.Strength) + MAX(gtStat.Strength) + MAX(cStat.Strength) AS Strength, 
       SUM(iStat.Defence) + MAX(gtStat.Defence) + MAX(cStat.Defence) AS Defence, 
       SUM(iStat.Speed) + MAX(gtStat.Speed) + MAX(cStat.Speed) AS Speed, 
       SUM(iStat.Mind) + MAX(gtStat.Mind) + MAX(cStat.Mind) AS Mind, 
       SUM(iStat.Luck) + MAX(gtStat.Luck) + MAX(cStat.Luck) AS Luck
FROM Users AS u
     JOIN UsersGames AS ug ON ug.UserId = u.Id
     JOIN Games AS g ON g.Id = ug.GameId
     JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
     JOIN Items AS i ON i.Id = ugi.ItemId
     JOIN [Statistics] AS iStat ON iStat.Id = i.StatisticId
     JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
     JOIN [Statistics] AS gtStat ON gtstat.Id = gt.BonusStatsId
     JOIN Characters AS c ON c.Id = ug.CharacterId
     JOIN [Statistics] AS cStat ON cStat.Id = c.StatisticId
GROUP BY g.Name, 
         Username
ORDER BY Strength DESC, 
         Defence DESC, 
         Speed DESC, 
         Mind DESC, 
         Luck DESC;

GO

--5
USE Diablo
GO

SELECT i.[Name], 
       i.Price, 
       i.MinLevel, 
       s.Strength, 
       s.Defence, 
       s.Speed, 
       s.Luck, 
       s.Mind
FROM Items AS i
     JOIN [Statistics] AS s ON s.Id = i.StatisticId
WHERE s.Mind >
(
    SELECT AVG(Mind)
    FROM [Statistics]
)
      AND s.Luck >
(
    SELECT AVG(Luck)
    FROM [Statistics]
)
      AND s.Speed >
(
    SELECT AVG(Speed)
    FROM [Statistics]
)
ORDER BY i.[Name];

GO

DECLARE @minMind INT=
(
    SELECT AVG(Mind)
    FROM [Statistics]
);
DECLARE @minLuck INT=
(
    SELECT AVG(Luck)
    FROM [Statistics]
);
DECLARE @minSpeed INT=
(
    SELECT AVG(Speed)
    FROM [Statistics]
);

SELECT i.[Name], 
       i.Price, 
       i.MinLevel, 
       s.Strength, 
       s.Defence, 
       s.Speed, 
       s.Luck, 
       s.Mind
FROM Items AS i
     JOIN [Statistics] AS s ON s.Id = i.StatisticId
WHERE s.Mind > @minMind
      AND s.Luck > @minLuck
      AND s.Speed > @minSpeed
ORDER BY i.[Name];

GO

--6
USE Diablo
GO

SELECT i.[Name] AS Item,
       i.Price,
       i.MinLevel,
       gt.[Name] AS [Forbidden Game Type]
FROM Items AS i
     LEFT JOIN GameTypeForbiddenItems AS gtfi ON gtfi.ItemId = i.Id
     LEFT JOIN GameTypes AS gt ON gt.Id = gtfi.GameTypeId
ORDER BY [Forbidden Game Type] DESC,
         Item;

GO

--7
USE Diablo
GO

DECLARE @userId INT=(SELECT u.Id FROM dbo.Users u WHERE u.Username = 'Alex');
DECLARE @gameId INT=(SELECT g.Id FROM dbo.Games g WHERE g.Name = 'Edinburgh');
DECLARE @userCash MONEY=(SELECT ug.Cash FROM dbo.UsersGames ug WHERE ug.UserId = @userId AND ug.GameId = @gameId);

DECLARE @BlackguardPrice MONEY=(SELECT i.Price FROM dbo.Items i WHERE i.Name = 'Blackguard');
DECLARE @BlackguardID INT=(SELECT i.Id FROM dbo.Items i WHERE i.Name = 'Blackguard');

DECLARE @BottomlessPrice MONEY=(SELECT i.Price FROM dbo.Items i WHERE i.Name = 'Bottomless Potion of Amplification');
DECLARE @BottomlessID INT=(SELECT i.Id FROM dbo.Items i WHERE i.Name = 'Bottomless Potion of Amplification');

DECLARE @EyePrice MONEY=(SELECT i.Price FROM dbo.Items i WHERE i.Name = 'Eye of Etlich (Diablo III)');
DECLARE @EyeID INT=(SELECT i.Id FROM dbo.Items i WHERE i.Name = 'Eye of Etlich (Diablo III)');

DECLARE @GemPrice MONEY=(SELECT i.Price FROM dbo.Items i WHERE i.Name = 'Gem of Efficacious Toxin');
DECLARE @GemID INT=(SELECT i.Id FROM dbo.Items i WHERE i.Name = 'Gem of Efficacious Toxin');

DECLARE @GoldenPrice MONEY=(SELECT i.Price FROM dbo.Items i WHERE i.Name = 'Golden Gorget of Leoric');
DECLARE @GoldenID INT=(SELECT i.Id FROM dbo.Items i WHERE i.Name = 'Golden Gorget of Leoric');

DECLARE @HellfirePrice MONEY=(SELECT i.Price FROM dbo.Items i WHERE i.Name = 'Hellfire Amulet');
DECLARE @HellfireID INT=(SELECT i.Id FROM dbo.Items i WHERE i.Name = 'Hellfire Amulet');

BEGIN TRANSACTION;
IF(@userCash < @BlackguardPrice)
            BEGIN
                ROLLBACK;
                RAISERROR('Insuficient money!', 16, 1);
                RETURN;
        END;

UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-= @BlackguardPrice
        WHERE dbo.UsersGames.UserId = @userId
				AND dbo.UsersGames.GameId = @gameId;

INSERT INTO dbo.UserGameItems
        VALUES
        (@BlackguardID, (
						 SELECT ug.Id FROM dbo.UsersGames ug
						 WHERE ug.UserId = @userId AND ug.GameId = @gameId)
        );
COMMIT;

BEGIN TRANSACTION;
IF(@userCash < @BottomlessPrice)
            BEGIN
                ROLLBACK;
                RAISERROR('Insuficient money!', 16, 1);
                RETURN;
        END;

UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-= @BottomlessPrice
        WHERE dbo.UsersGames.UserId = @userId
				AND dbo.UsersGames.GameId = @gameId;

INSERT INTO dbo.UserGameItems
        VALUES
        (@BottomlessID, (
						 SELECT ug.Id FROM dbo.UsersGames ug
						 WHERE ug.UserId = @userId AND ug.GameId = @gameId)
        );
COMMIT;

BEGIN TRANSACTION;
IF(@userCash < @EyePrice)
            BEGIN
                ROLLBACK;
                RAISERROR('Insuficient money!', 16, 1);
                RETURN;
        END;

UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-= @EyePrice
        WHERE dbo.UsersGames.UserId = @userId
				AND dbo.UsersGames.GameId = @gameId;

INSERT INTO dbo.UserGameItems
        VALUES
        (@EyeID, (
						 SELECT ug.Id FROM dbo.UsersGames ug
						 WHERE ug.UserId = @userId AND ug.GameId = @gameId)
        );
COMMIT;

BEGIN TRANSACTION;
IF(@userCash < @GemPrice)
            BEGIN
                ROLLBACK;
                RAISERROR('Insuficient money!', 16, 1);
                RETURN;
        END;

UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-= @GemPrice
        WHERE dbo.UsersGames.UserId = @userId
				AND dbo.UsersGames.GameId = @gameId;

INSERT INTO dbo.UserGameItems
        VALUES
        (@GemID, (
						 SELECT ug.Id FROM dbo.UsersGames ug
						 WHERE ug.UserId = @userId AND ug.GameId = @gameId)
        );
COMMIT;

BEGIN TRANSACTION;
IF(@userCash < @GoldenPrice)
            BEGIN
                ROLLBACK;
                RAISERROR('Insuficient money!', 16, 1);
                RETURN;
        END;

UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-= @GoldenPrice
        WHERE dbo.UsersGames.UserId = @userId
				AND dbo.UsersGames.GameId = @gameId;

INSERT INTO dbo.UserGameItems
        VALUES
        (@GoldenID, (
						 SELECT ug.Id FROM dbo.UsersGames ug
						 WHERE ug.UserId = @userId AND ug.GameId = @gameId)
        );
COMMIT;

BEGIN TRANSACTION;
IF(@userCash < @HellfirePrice)
            BEGIN
                ROLLBACK;
                RAISERROR('Insuficient money!', 16, 1);
                RETURN;
        END;

UPDATE dbo.UsersGames
          SET 
              dbo.UsersGames.Cash-= @HellfirePrice
        WHERE dbo.UsersGames.UserId = @userId
				AND dbo.UsersGames.GameId = @gameId;

INSERT INTO dbo.UserGameItems
        VALUES
        (@HellfireID, (
						 SELECT ug.Id FROM dbo.UsersGames ug
						 WHERE ug.UserId = @userId AND ug.GameId = @gameId)
        );
COMMIT;

SELECT u.Username, 
       g.Name, 
       ug.Cash, 
       i.Name AS [Item Name]
FROM dbo.Users u
     JOIN dbo.UsersGames ug ON u.Id = ug.UserId
     JOIN dbo.Games g ON ug.GameId = g.Id
     JOIN dbo.UserGameItems ugi ON ug.Id = ugi.UserGameId
     JOIN dbo.Items i ON ugi.ItemId = i.Id
WHERE g.Id = @gameId
ORDER BY [Item Name];

GO

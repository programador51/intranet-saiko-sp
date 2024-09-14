DECLARE @currentTc DECIMAL (14,2);
DECLARE @tcRate DECIMAL (14,2);

DECLARE @minTCAllowed DECIMAL (14,2);
DECLARE @partialitiesAllowed INT;

SELECT TOP 1 @currentTc=saiko FROM TCP ORDER BY id DESC 

SELECT 
    @tcRate= CAST([value] AS DECIMAL (14,2))
 FROM Parameters WHERE parameter= 23

SELECT @minTCAllowed = @currentTc - @tcRate

SELECT @partialitiesAllowed=CAST ([value] AS INT) FROM Parameters WHERE parameter= 22

SELECT @minTCAllowed AS minTc, @currentTc AS currentTc, @tcRate AS tcRate, @partialitiesAllowed AS partialitiesAllowed

ALTER TABLE PositionsProyects ADD cost DECIMAL(20,4) NOT NULL DEFAULT 0;
GO
ALTER TABLE PositionsProyects ADD sell DECIMAL(20,4) NOT NULL DEFAULT 0;
GO

ALTER TABLE PositionsProyects ADD ivaCostRate INT CHECK (ivaCostRate IN (16, 8, 0)) NOT NULL DEFAULT 16;
GO
ALTER TABLE PositionsProyects ADD ivaSellRate INT CHECK (ivaSellRate IN (16, 8, 0)) NOT NULL DEFAULT 16;
GO
ALTER TABLE PositionsProyects ADD ivaCostAmount AS CAST((cost * ivaCostRate/100) AS DECIMAL(20,4)) PERSISTED;
GO
ALTER TABLE PositionsProyects ADD ivaSellAmount AS CAST((sell * ivaSellRate/100) AS DECIMAL(20,4)) PERSISTED;
GO
ALTER TABLE PositionsProyects ADD totalCost AS CAST((cost + ivaCostAmount) AS DECIMAL(20,4)) PERSISTED;
GO
ALTER TABLE PositionsProyects ADD totalSell AS CAST((sell + ivaSellAmount) AS DECIMAL(20,4)) PERSISTED;
GO

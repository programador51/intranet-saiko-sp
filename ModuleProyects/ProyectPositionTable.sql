DROP TABLE IF EXISTS PositionsProyects;
CREATE TABLE PositionsProyects
(
	[id] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[createdBy] [nvarchar](256) NOT NULL,
	[updatedBy] [nvarchar](256) NULL,
	[idProject] [int] NOT NULL,
	[status] [nvarchar](255) NOT NULL,
	[description] [nvarchar](max) NULL,
	[ocCustomer] [nvarchar](256) NULL,
	[percentageOfCompletion] [decimal](5, 2) NULL,
	[pos] [nvarchar](256) NOT NULL,
	[createdDate] [datetime] NOT NULL DEFAULT (GETUTCDATE()) ,
	[updatedDate] [datetime] NULL DEFAULT (GETUTCDATE()),
	[cost] DECIMAL(20,4) NOT NULL DEFAULT 0,
	[sell] DECIMAL(20,4) NOT NULL DEFAULT 0,
	[idUen] INT NOT NULL,
	[ivaCostRate] INT CHECK (ivaCostRate IN (16, 8, 0)) NOT NULL DEFAULT 16,
	[ivaSellRate] INT CHECK (ivaSellRate IN (16, 8, 0)) NOT NULL DEFAULT 16,
	[ivaCostAmount] AS CAST((cost * ivaCostRate/100) AS DECIMAL(20,4)) PERSISTED,
	[ivaSellAmount] AS CAST((sell * ivaSellRate/100) AS DECIMAL(20,4)) PERSISTED,
	[totalCost] AS CAST((cost + (cost*ivaCostRate/100)) AS DECIMAL(20,4)) PERSISTED,
	[totalSell] AS CAST((sell+ (sell*ivaSellRate/100)) AS DECIMAL(20,4)) PERSISTED
)
GO
	

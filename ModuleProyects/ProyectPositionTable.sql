DROP TABLE IF EXISTS PositionsProyects;
CREATE TABLE PositionsProyects
(
	[id] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[createdBy] [nvarchar](256) NOT NULL,
	[updatedBy] [nvarchar](256) NOT NULL,
	[idProject] [int] NOT NULL,
	[status] [bit] NOT NULL DEFAULT 1,
	[statusPosition] [nvarchar](255) NOT NULL DEFAULT 'SolicitudNormal',
	[description] [nvarchar](max) NULL,
	[ocCustomer] [nvarchar](256) NULL,
	[percentageOfCompletion] [decimal](5, 2) NULL,
	[pos] [nvarchar](256)  NULL,
	[createdDate] [datetime] NOT NULL DEFAULT (GETUTCDATE()) ,
	[updatedDate] [datetime] NULL DEFAULT (GETUTCDATE()),
	[cost] DECIMAL(20,4) NOT NULL DEFAULT 0,
	[sell] DECIMAL(20,4) NOT NULL DEFAULT 0,
	[idUen] INT NOT NULL,
	[satKey] NVARCHAR(256) NOT NULL,
	[satDescription] NVARCHAR(256) NOT NULL,
	[um] NVARCHAR(256) NOT NULL,
	[umDescription] NVARCHAR(256) NOT NULL,
	[ivaCostRate] INT CHECK (ivaCostRate IN (16, 8, 0)) NOT NULL DEFAULT 16,
	[ivaSellRate] INT CHECK (ivaSellRate IN (16, 8, 0)) NOT NULL DEFAULT 16,
	[ivaCostAmount] AS CAST((cost * ivaCostRate/100) AS DECIMAL(20,4)) PERSISTED,
	[ivaSellAmount] AS CAST((sell * ivaSellRate/100) AS DECIMAL(20,4)) PERSISTED,
	[totalCost] AS CAST((cost + (cost*ivaCostRate/100)) AS DECIMAL(20,4)) PERSISTED,
	[totalSell] AS CAST((sell+ (sell*ivaSellRate/100)) AS DECIMAL(20,4)) PERSISTED
)
GO
	ALTER TABLE [dbo].[PositionsProyects]  WITH CHECK ADD  CONSTRAINT [CK__PositionsProyects__statusPosition] CHECK  (([statusPosition]='Cancelar' OR [statusPosition]='NoAsignado' OR [statusPosition]='Terminado' OR [statusPosition]='Activo' OR [statusPosition]='Propuesta' OR [statusPosition]='SolicitudNormal' OR [statusPosition]='SolicitudUrgente'))
GO
ALTER TABLE [dbo].[PositionsProyects] CHECK CONSTRAINT [CK__PositionsProyects__statusPosition]

DROP TABLE IF EXISTS [dbo].[Proyects];
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Proyects](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[buyer] [nvarchar](1000) NULL,
	[buyerEmail] [nvarchar](256) NULL,
	[buyerPhone] [nvarchar](15) NULL,
	[comments] [nvarchar](max) NULL,
	[createdBy] [nvarchar](256) NOT NULL,
	[createdDate] [datetime] NOT NULL DEFAULT (GETUTCDATE()),
	[link] [nvarchar](1000) NULL,
	[noRFQ] [nvarchar](256) NULL,
	[solped] [nvarchar](1000) NULL,
	[title] [nvarchar](256) NULL,
	[updatedBy] [nvarchar](256)NOT NULL,
	[updatedDate] [datetime] NOT NULL DEFAULT (GETUTCDATE()),
	[user] [nvarchar](256) NULL,
	[userEmail] [nvarchar](256) NULL,
	[userPhone] [nvarchar](15) NULL,
	[idClient] [int] NOT NULL DEFAULT 0,
	[status] [BIT] NOT NULL DEFAULT 1,
    [statusProyect] [nvarchar](256) NOT NULL DEFAULT 'Activo',
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Proyects] ADD PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
GO
EXEC sys.sp_addextendedproperty @name=N'Column_Description', @value=N'Con lada incluido' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Proyects', @level2type=N'COLUMN',@level2name=N'buyerPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'Column_Description', @value=N'HTML o contenido markdown' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Proyects', @level2type=N'COLUMN',@level2name=N'comments'
GO
EXEC sys.sp_addextendedproperty @name=N'Column_Description', @value=N'Con lada incluido' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Proyects', @level2type=N'COLUMN',@level2name=N'userPhone'
GO

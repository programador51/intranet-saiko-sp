CREATE TYPE [dbo].[MovementConcepts] AS TABLE(
	[id] [int] IDENTITY(1,1) NOT NULL,
    [idConcept] [int] NULL,
    [description] [nvarchar](256) NOT NULL,
    [idType] [int] NOT NULL,
    [status] [tinyint] NOT NULL
)
DROP TYPE IF EXISTS [dbo].[ProposalPositionIdType]
CREATE TYPE [dbo].[ProposalPositionIdType] AS TABLE(
	idPosition INT NOT NULL,
	positionDescription NVARCHAR(MAX) NOT NULL
)
GO

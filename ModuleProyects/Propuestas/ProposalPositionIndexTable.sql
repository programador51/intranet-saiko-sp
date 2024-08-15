
DROP TABLE IF EXISTS [ProposalPositionIndex];
CREATE TABLE [ProposalPositionIndex] (
  [id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [idProposal] int NOT NULL,
  [idPosition] int NOT NULL,
  [positionDescription] NVARCHAR(MAX),
  [createdBy] nvarchar(50) NOT NULL,
  [createdDate] datetime NOT NULL DEFAULT (GETUTCDATE()),
  [status] bit NOT NULL DEFAULT (1),
  [updatedBy] nvarchar(50),
  [updatedDate] datetime DEFAULT (GETUTCDATE())
)
GO
EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Proposal id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProposalPositionIndex',
@level2type = N'Column', @level2name = 'idProposal';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Position id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProposalPositionIndex',
@level2type = N'Column', @level2name = 'idPosition';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Name of the person who created the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProposalPositionIndex',
@level2type = N'Column', @level2name = 'createdBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Record creation date',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProposalPositionIndex',
@level2type = N'Column', @level2name = 'createdDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Indicates it is active or not (1 | 0)',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProposalPositionIndex',
@level2type = N'Column', @level2name = 'status';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last person who updated the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProposalPositionIndex',
@level2type = N'Column', @level2name = 'updatedBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last update date of the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProposalPositionIndex',
@level2type = N'Column', @level2name = 'updatedDate';
GO

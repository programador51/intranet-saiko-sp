DROP TABLE IF EXISTS [ProyectProposals];

CREATE TABLE [ProyectProposals] (
  [id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [idCustomer] int NOT NULL,
  [idExecutive] int NOT NULL,
  [idProyect] int NOT NULL,
  [proposalNumber] NVARCHAR(256) NOT NULL,
  [proposalStatus] nvarchar(256) NOT NULL DEFAULT 'Activa',
  [subTotal] decimal(14,4) NOT NULL,
  [iva] decimal(14,4) NOT NULL,
  [total] AS CAST((subTotal +  iva) AS DECIMAL(20,4)) PERSISTED,
  [attn] nvarchar(256),
  [expirationDate] DATE NOT NULL,
  [paymentTerms] nvarchar(256),
  [termsAndConditions] nvarchar(MAX),
  [createdBy] nvarchar(50) NOT NULL,
  [createdDate] datetime NOT NULL DEFAULT (GETUTCDATE()),
  [updatedBy] nvarchar(50),
  [updatedDate] datetime DEFAULT (GETUTCDATE()),
  [status] bit NOT NULL DEFAULT (1)
)
GO
ALTER TABLE [dbo].[ProyectProposals]  WITH CHECK ADD CONSTRAINT [CK__ProyectProposals__proposalStatus] CHECK  (([proposalStatus]='Activa' OR [proposalStatus]='Enviada' OR [proposalStatus]='Aceptada'OR [proposalStatus]='Cancelada'))
GO
EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Customer id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'idCustomer';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Executive id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'idExecutive';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Proyect id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'idProyect';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Proposal status',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'proposalStatus';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Subtotal of the proposal',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'subTotal';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'IVA of the proposal',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'iva';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Total of the proposal',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'total';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Name of the person who created the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'createdBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Record creation date',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'createdDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last person who updated the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'updatedBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last update date of the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'updatedDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Indicates it is active or not (1 | 0)',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'ProyectProposals',
@level2type = N'Column', @level2name = 'status';
GO
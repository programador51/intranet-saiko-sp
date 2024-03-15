CREATE TABLE [InvoiceCancellationHistory] (
  [id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [idInvoice] int NOT NULL,
  [idUser] int,
  [documentType] nvarchar(256) NOT NULL,
  CHECK ([documentType] IN ('Notas de credito', 'Factura emitida', 'Complemento')),
  [createdBy] nvarchar(50) NOT NULL DEFAULT ('SISTEMA'),
  [createdDate] datetime NOT NULL DEFAULT (GETUTCDATE()),
  [status] bit NOT NULL DEFAULT (1),
  [updatedBy] nvarchar(50),
  [updatedDate] datetime DEFAULT (GETUTCDATE())
)
GO
EXEC sp_addextendedproperty
@name = N'Table_Description',
@value = 'Table in charge of storing the cancellation history of CFDIS',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Legal document id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'idInvoice';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'User id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'idUser';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Indicates the type of legal document cancelled."Notas de credito", "Factura emitida", "Complemento"',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'documentType';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Name of the person who created the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'createdBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Record creation date',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'createdDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Indicates it is active or not (1 | 0)',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'status';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last person who updated the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'updatedBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last update date of the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'InvoiceCancellationHistory',
@level2type = N'Column', @level2name = 'updatedDate';
GO
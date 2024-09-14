CREATE TABLE [PaymentReminder] (
  [id] int PRIMARY KEY NOT NULL IDENTITY(1, 1),
  [idInvoice] int NOT NULL,
  [idClient] int NOT NULL,
  [idTag] int,
  [emitedDate] datetime NOT NULL,
  [expirationDate] datetime NOT NULL,
  [indexDate] date NOT NULL,
  [idRule] int NOT NULL,
  [contact] nvarchar(128) ,
  [phone] nvarchar(50) ,
  [email] nvarchar(50) ,
  [total] decimal(14,4) NOT NULL,
  [residue] decimal(14,4) NOT NULL,
  [currency] nvarchar(3) NOT NULL CHECK (currency IN ('MXN', 'USD')),
  [createdBy] nvarchar(50) NOT NULL DEFAULT ('SISTEMA'),
  [createdDate] datetime NOT NULL DEFAULT (GETUTCDATE()),
  [updatedBy] nvarchar(50),
  [updatedDate] datetime DEFAULT (GETUTCDATE())
)
GO


EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Invoice emited id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'idInvoice';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Customer id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'idClient';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Id tag',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'idTag';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Emited date',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'emitedDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Expiration date',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'expirationDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Index Date',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'indexDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'ID of the rule to which the record belongs',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'idRule';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Primary contact full name',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'contact';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Phone number contact',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'phone';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Email contact',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'email';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Invoice total',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'total';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Invoice residue',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'residue';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Invoice currency',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'currency';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Name of the person who created the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'createdBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'Record creation date',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'createdDate';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last person who updated the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'updatedBy';
GO

EXEC sp_addextendedproperty
@name = N'Column_Description',
@value = 'The last update date of the record',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'PaymentReminder',
@level2type = N'Column', @level2name = 'updatedDate';
GO
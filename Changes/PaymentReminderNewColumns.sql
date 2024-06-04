-- ALTER TABLE PaymentReminder DROP COLUMN folio;
-- ALTER TABLE PaymentReminder DROP COLUMN idCxc;
-- ALTER TABLE PaymentReminder DROP COLUMN executive;
-- ALTER TABLE PaymentReminder DROP COLUMN partiality;
ALTER TABLE PaymentReminder ADD folio NVARCHAR(256);
ALTER TABLE PaymentReminder ADD idCxc INT;
ALTER TABLE PaymentReminder ADD executive NVARCHAR(10);
ALTER TABLE PaymentReminder ADD partiality NVARCHAR(50);
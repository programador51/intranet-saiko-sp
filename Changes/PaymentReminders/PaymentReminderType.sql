CREATE TYPE PaymentReminderType AS TABLE (
    idInvoice INT,
    idClient INT,
    emitedDate DATETIME,
    expirationDate DATETIME,
    indexDate DATE,
    idRule INT,
    contact NVARCHAR(128),
    phone NVARCHAR(50),
    email NVARCHAR(50),
    total DECIMAL(14,4),
    residue DECIMAL(14,4),
    currency NVARCHAR(3)
)
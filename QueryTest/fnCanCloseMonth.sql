-- CREATE FUNCTION dbo.fnCanClose()
-- RETURNS @result TABLE 
-- (
--     movementsCount INT,
--     movementsAccountedCount INT,
--     invoiceECount INT,
--     invoiceEAccountedCount INT,
--     invoiceRCount INT,
--     invoiceRAccountedCount INT,
--     canClose BIT,
--     errorMessage NVARCHAR(128)
-- )







DECLARE @currentDate DATETIME = '2023-07-01';
DECLARE @lastDay DATETIME = EOMONTH(@currentDate);

DECLARE @firtsDay DATE = DATEADD(MONTH, DATEDIFF(MONTH, 0, @currentDate), 0)

DECLARE @idMovementStatus INT =3 -- Movimiento conciliado
DECLARE @idBankAccount INT = 69 -- Id bank account
DECLARE @accountedStatus BIT = 1 -- Indicates that the record was accounted

DECLARE @incomeFrom INT= 3;
DECLARE @outcomeFrom INT= 4;
DECLARE @invoiceEFrom INT= 1;
DECLARE @invoiceRFrom INT= 2;

DECLARE @invoiceEType INT = 2
DECLARE @invoiceRType INT = 1


DECLARE @movementsCount INT;
DECLARE @invoiceECount INT;
DECLARE @invoiceRCount INT;

DECLARE @movementsAccountedCount INT;
DECLARE @invoiceEAccountedCount INT;
DECLARE @invoiceRAccountedCount INT;

DECLARE @canClose BIT=1;
DECLARE @erroMessage NVARCHAR(128)='';


SELECT 
    @movementsCount= COUNT(*)
FROM Accounted AS accounted
LEFT JOIN Movements AS movement 
    ON movement.MovementID = accounted.idRecord
WHERE accounted.idFrom IN (@incomeFrom,@outcomeFrom) -- Ingreso / egreso
    AND accounted.[accounted] = @accountedStatus
    AND movement.bankAccount = @idBankAccount
    AND movement.[status] = @idMovementStatus
    AND movementDate <= @lastDay;

    
SELECT
     @movementsAccountedCount= COUNT(*)
FROM Movements 
WHERE 
    movementDate <= @lastDay AND 
    [status]=@idMovementStatus AND
    bankAccount= @idBankAccount;

SELECT 
    @invoiceECount=COUNT(*)
FROM LegalDocuments 
WHERE 
    idTypeLegalDocument=@invoiceEType  AND
    idLegalDocumentStatus NOT IN (8,10) AND
   (createdDate >= @firtsDay AND createdDate <= @lastDay);

SELECT 
    @invoiceEAccountedCount=COUNT(*)
FROM Accounted AS accounted
LEFT JOIN LegalDocuments AS invoice ON invoice.id = accounted.idRecord
WHERE 
    accounted.idFrom= @invoiceEFrom AND
    accounted.accounted = @accountedStatus AND
    invoice.idTypeLegalDocument=@invoiceEType AND
    invoice.idLegalDocumentStatus NOT IN (8,10) AND
    (invoice.createdDate >= @firtsDay AND invoice.createdDate <= @lastDay);

SELECT 
    @invoiceRCount=COUNT(*)
FROM LegalDocuments 
WHERE 
    idTypeLegalDocument=@invoiceRType AND
    idLegalDocumentStatus NOT IN (8,10) AND
   (createdDate >= @firtsDay AND createdDate <= @lastDay);

SELECT 
     @invoiceRAccountedCount=COUNT(*)
FROM Accounted AS accounted
LEFT JOIN LegalDocuments AS invoice ON invoice.id = accounted.idRecord
WHERE 
    accounted.idFrom= @invoiceRFrom AND
    accounted.accounted = @accountedStatus AND
    invoice.idTypeLegalDocument=@invoiceRType AND
    invoice.idLegalDocumentStatus NOT IN (2,5) AND
    (invoice.createdDate >= @firtsDay AND invoice.createdDate <= @lastDay);

-- SELECT * FROM LegalDocumentStatus WHERE idTypeLegalDocumentType=1 AND [status]=1
IF(@movementsCount != @movementsAccountedCount)
    BEGIN
        SET @canClose =0;
        SET @erroMessage = @erroMessage + 'Los movimientos conciliados con coinciden con los contabilizados. '
    END
IF(@invoiceECount != @invoiceEAccountedCount)
    BEGIN
        SET @canClose =0;
        SET @erroMessage = @erroMessage + 'Las facturas emitidas no coinciden con las facturas emitidas contabilizadas. '
    END
IF(@invoiceRCount != @invoiceRAccountedCount)
    BEGIN
        SET @canClose =0;
        SET @erroMessage = @erroMessage + 'Las facturas recibidas no coinciden con las facturas recibidas contabilizadas. '
    END

SELECT 
    @movementsCount AS movementsCount,
    @movementsAccountedCount AS movementsAccountedCount,
    @invoiceECount AS invoiceECount,
    @invoiceEAccountedCount AS invoiceEAccountedCount,
    @invoiceRCount AS invoiceRCount,
    @invoiceRAccountedCount AS invoiceRAccountedCount;

SELECT 
    @canClose AS canClose,
    @erroMessage AS errorMessage;
-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 1-12-2021
-- ************************************************************************************************************************
-- Description: Search the document with the document number
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idExecutive: [Foreign key] - Id of the executive to filter the documents
-- @idCustomer: [Foreign key] - Id of the customer belong that document
-- @documentNumber: Document number to search
-- @idTypeDocument: [Foreign Key] Type of document it's being search
-- @pageRequested: Number page to search
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  1-12-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************
-- ============================================[FOLLOWING RESULT OF QUERY]=================================================

CREATE PROCEDURE sp_GetDocumentSearch(
    @idExecutive INT,
    @idCustomer INT,
    @documentNumber INT,
    @idTypeDocument INT,
    @pageRequested INT
)

AS BEGIN

    -- Number of registers founded
    DECLARE @noRegisters INT;

    -- Since which register start searching the information
    DECLARE @offsetValue INT;

    -- Total pages founded on the query
    DECLARE @totalPages DECIMAL;

    -- LIMIT of registers that can be returned per query
    DECLARE @rowsPerPage INT;

    ------------------------------ Calculate the pagination ------------------------------

    SELECT @noRegisters = COUNT(*) FROM Documents
    
    WHERE
        idExecutive = @idExecutive AND
        idCustomer = @idCustomer AND
        idTypeDocument = @idTypeDocument AND
        documentNumber = @documentNumber;

    SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;

    SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);

    SELECT
    @totalPages AS pages,
    @pageRequested AS actualPage;


    SET LANGUAGE Spanish;
    
    ------------------------------ Query of the documents ------------------------------

    SELECT 
    
    Documents.STSprogramID,
    Documents.amountToBeCredited,
    Documents.amountToPay,
    Documents.associatedInOutID,
    Documents.createdBy,
    Documents.idCustomer AS idCustomer,

    REPLACE(CONVERT(VARCHAR(10),Documents.createdDate,6),' ','/') AS createdDate,

    Documents.creditDays,
    Documents.currectFaction,
    Documents.currencyPayment,
    Documents.documentNumber,

    REPLACE(CONVERT(VARCHAR(10),Documents.expirationDate,6),' ','/') AS expirationDate,

    Documents.factionsNumber,
    Documents.idBank,
    Documents.idContact,
    
    CASE 
        WHEN Documents.idContract IS NULL THEN ''
        ELSE CONVERT(NVARCHAR,Documents.idContract)
    END AS idContract,

	Documents.contract AS contract,
    
    Documents.idCurrency,
    Documents.idDocument,
    Documents.idExecutive,

    CASE 
        WHEN Documents.idInvoice IS NULL THEN ''
        ELSE CONVERT(NVARCHAR,Documents.idInvoice)
    END AS idInvoice,

    Documents.idMovements,

    CASE 
        WHEN Documents.idOC IS NULL THEN ''
        ELSE CONVERT(NVARCHAR,Documents.idOC)
    END AS idOC,

    Documents.idPaymentForm,
    Documents.idProbability,
    Documents.idProgress,

    CASE 
        WHEN Documents.idQuotation IS NULL THEN ''
        ELSE CONVERT(NVARCHAR,Documents.idQuotation)
    END AS idQuotation,

    Documents.idStatus,
    Documents.idTypeDocument,
	DocumentTypes.description AS typeDocumentDescription,

    CASE 
        WHEN Documents.invoiceMizarNumber IS NULL THEN ''
        ELSE Documents.invoiceMizarNumber
    END AS invoiceMizarNumber,

    Documents.isComplement,
    Documents.lastUpdatedBy,
    Documents.lastUpdatedDate,
    Documents.pdf,

	CONVERT(BIT,Documents.hasAttachedFiles) AS hasFiles ,

	CONVERT(BIT,Documents.hasReminders) AS hasReminders,

    CONVERT(VARCHAR(10),Documents.reminderDate,105) AS reminderDate,

    Documents.stampedInvoice,
    Documents.supplierInvoice,
    Documents.totalAcreditedAmount,
    Documents.totalAmount,

	Documents.authorizationFlag AS authorizationFlag,

	CAST(Documents.totalAmount AS DECIMAL(14,2)) AS totalAmountNumber,

    Documents.xml,

	CASE 
		WHEN Documents.wasSend IS NULL THEN
		CONVERT(BIT,0)

		ELSE CONVERT(BIT,Documents.wasSend)

	END AS wasSendedPdf,

    Users.userID AS Users_UserId,
    Users.firstName,
    Users.middleName,
    Users.lastName1,
    Users.lastName2,
    CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS executiveFullName,
    CONCAT(SUBSTRING(firstName,1,1),SUBSTRING(middleName,1,1),SUBSTRING(lastName1,1,1),SUBSTRING(lastName2,1,1)) AS Ejecutivo,

    Currencies.currencyID AS Currencies_currencyID,
    Currencies.code AS Moneda,

    DocumentStatus.documentStatusID AS DocumentStatus_id,
    DocumentStatus.description AS Estatus,
	Documents.limitBillingTime AS limitBillingTime,
	Documents.protected AS tc,
	Documents.tcRequested AS tcRequested,

    CASE
        WHEN Documents.invoiceNumberSupplier IS NULL THEN ''

        ELSE FORMAT(Documents.invoiceNumberSupplier,'0000000') END AS invoiceNumberSupplier,

	CASE
		WHEN GETDATE() < Documents.limitBillingTime THEN CONVERT(BIT,1)

		ELSE CONVERT(BIT,0) END AS allowedToBill
		


    FROM Documents

    JOIN Users ON Documents.idExecutive = Users.userID
    JOIN Currencies ON Documents.idCurrency = Currencies.currencyID
    JOIN DocumentStatus ON Documents.idStatus = DocumentStatus.documentStatusID
	JOIN DocumentTypes ON Documents.idTypeDocument = DocumentTypes.documentTypeID

    WHERE
        (Documents.idExecutive = @idExecutive) AND
        (Documents.idTypeDocument = @idTypeDocument) AND
        (Documents.idCustomer = @idCustomer) AND
        (Documents.documentNumber = @documentNumber)

    ORDER BY Documents.idDocument DESC
        
    OFFSET @offsetValue ROWS 
    FETCH NEXT @rowsPerPage ROWS ONLY ;

END
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 21-09-2021

-- Description: Get "n" documents filtered by executive , type document , status , customer and date range

-- ===================================================================================================================================
-- PARAMETERS:
-- @idExecutive: Id of the executive who created the document
-- @idTypeDocument: Id type of document to fetch
-- @idStatus: Id status of the document
-- @beginDate: Date range begin
-- @endDate: Date range end
-- @rangeBegin: Since which register start searching
-- @idCustomer: Id of the customer to fetch his related documents 
-- @noRegisters: Number of documents to fetch

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  21-09-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetDocuments(
    @idExecutive INT,
    @idTypeDocument INT,
    @idStatus INT
    @beginDate DATETIME,
    @endDate DATETIME,
    @rangeBegin INT,
    @idCustomer INT,
    @noRegisters INT
)

AS BEGIN

    SET LANGUAGE Spanish;
    
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
    
    Documents.idCurrency,
    Documents.idCustomer,
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

    CASE 
        WHEN Documents.invoiceMizarNumber IS NULL THEN ''
        ELSE Documents.invoiceMizarNumber
    END AS invoiceMizarNumber,

    Documents.isComplement,
    Documents.lastUpdatedBy,
    Documents.lastUpdatedDate,
    Documents.pdf,
    Documents.protected,

    CONVERT(VARCHAR(10),Documents.reminderDate,105) AS reminderDate,

    Documents.stampedInvoice,
    Documents.supplierInvoice,
    Documents.totalAcreditedAmount,
    Documents.totalAmount,
    Documents.xml,

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
    DocumentStatus.description AS Estatus


    FROM Documents

    JOIN Users ON Documents.idExecutive = Users.userID
    JOIN Currencies ON Documents.idCurrency = Currencies.currencyID
    JOIN DocumentStatus ON Documents.idStatus = DocumentStatus.documentStatusID

    WHERE
        (Documents.idExecutive = @idExecutive) AND
        (Documents.idTypeDocument = @idTypeDocument) AND
        (Documents.idStatus = @idStatus OR @idStatus IS NULL) AND
        (Documents.idCustomer = @idCustomer)

    ORDER BY Documents.idDocument DESC
    
    OFFSET @rangeBegin ROWS 
    FETCH NEXT @noRegisters ROWS ONLY ;  

END
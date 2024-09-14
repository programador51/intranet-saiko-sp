-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 21-02-2021
-- ************************************************************************************************************************
-- Description: After a invoice it's generated to SAT, the information of the register (preinvoice) its also inserted
-- into legal documents
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idDocument: Id of the preinvoice generated to SAT
-- @executive: Executive who perfomred the action
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
-- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  21-02-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************
-- ============================================[FOLLOWING RESULT OF QUERY]=================================================
CREATE PROCEDURE sp_AddInvoiceToLegalDocuments(
    idDocument INT,
    executive NVARCHAR(30)
) AS BEGIN -- OBTENER LOS DATOS DEL CLIENTE
DECLARE @idCustomer INT;

DECLARE @rfcCustomer NVARCHAR(30);

DECLARE @commercialName NVARCHAR(100);

DECLARE @socialReason NVARCHAR(100);

SELECT
    @idCustomer = idCustomer
FROM
    Documents
WHERE
    idDocument = 2772;

SELECT
    @rfcCustomer = rfc,
    @commercialName = commercialName,
    @socialReason = socialReason
FROM
    Customers
WHERE
    customerID = @idCustomer;

-- OBTENER EL RFC DE LA EMPRESA
DECLARE @rfcEmitter NVARCHAR(200)
SELECT
    @rfcEmitter = value
FROM
    Parameters
WHERE
    parameter = 9;

-- SELECT @idCustomer AS idCustomer , @socialReason AS socialReason , @rfcCustomer AS rfcReceptor , @rfcEmitter AS rfcEmitter , @commercialName AS commercialName;
-- OBTENER LA MONEDA DE LA FACTURA
DECLARE @currencyCode NVARCHAR(3);

DECLARE @idCurrency INT
SELECT
    @idCurrency = idCurrency
FROM
    Documents
WHERE
    idDocument = @idDocument;

SELECT
    @currencyCode = code
FROM
    Currencies
WHERE
    currencyId = 2;

SELECT
    @currencyCode AS digitCurrencyCode;

INSERT INTO
    LegalDocuments (
        accountingDate,
        acumulated,
        createdBy,
        createdDate,
        creditDays,
        currencyCode,
        discount,
        emitedDate,
        expirationDate,
        idCustomer,
        idDocument,
        idFacturamaLegalDocument,
        idLegalDocumentProvider,
        idLegalDocumentReference,
        idLegalDocumentStatus,
        idTypeLegalDocument,
        import,
        iva,
        lastUpadatedDate,
        lastUpdatedBy,
        noDocument,
        pdf,
        residue,
        rfcEmiter,
        rfcReceptor,
        socialReason,
        total,
        uuid,
        uuidReference,
        [xml]
    )
SELECT
    NULL,
    0,
    @executive,
    dbo.fn_MexicoLocalTime(GETDATE()),
    Documents.creditDays,
    @currencyCode,
    0,
    dbo.fn_MexicoLocalTime(GETDATE()),
    dbo.fn_MexicoLocalTime(GETDATE()),
    Documents.idCustomer,
    Documents.idDocument,
    Documents.invoiceMizarNumber,
    Documents.idCustomer,
    NULL,
    6,
    2,
    Documents.subTotalAmount,
    Documents.ivaAmount,
    dbo.fn_MexicoLocalTime(GETDATE()),
    @executive,
    Documents.documentNumber,
    CONVERT(INT, Documents.pdf),
    Documents.totalAmount,
    @rfcEmitter,
    @rfcCustomer,
    @socialReason,
    Documents.totalAmount,
    Documents.uuid,
    NULL,
    CONVERT(INT, Documents.xml)
FROM
    Documents
WHERE
    idDocument = @idDocument;

END
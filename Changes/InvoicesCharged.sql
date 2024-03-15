SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GetInvoicesDocumentsV2]
(
    @customerId NVARCHAR(256),
    @statusId INT,
    @beginDate DATE,
    @endDate DATE,
    @search NVARCHAR(15),
    @pageRequested INT,
    @accounting BIT
)
AS
BEGIN

    DECLARE @rowsPerPage INT = 100;
    DECLARE @offset INT;
    DECLARE @pages INT;

    -- LEFT JOIN Accounted ON invoice.id = Accounted.idRecord 

------------------------------------------------------------------------------------------------------------------------------------------------------------

    DECLARE @ACCOUNT_JOIN NVARCHAR(MAX)
        = ' LEFT JOIN Accounted
        ON Accounted.idRecord = invoice.id 
           AND Accounted.idFrom = 1 ';

    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- DECLARE @FILTER_ACCOUNTING NVARCHAR(MAX) = CONCAT(' AND Accounted.accounted = ', @accounting, ' AND Accounted.idFrom = 1 ');

        DECLARE @FILTER_ACCOUNTING NVARCHAR(MAX)
        = CONCAT(
                    ' AND (',
                    ISNULL(CONVERT(NVARCHAR(256), @accounting), 'NULL'),
                    ' IS NULL OR Accounted.accounted = ',
                    ISNULL(CONVERT(NVARCHAR(256), @accounting), 'NULL'),
                    ' OR Accounted.accounted IS NULL ) '
                );


    IF (@accounting = 1 )
    BEGIN

        SET @FILTER_ACCOUNTING
            = CONCAT(
                        ' AND (',
                        ISNULL(CONVERT(NVARCHAR(256), @accounting), 'NULL'),
                        ' IS NULL OR Accounted.accounted = ',
                        ISNULL(CONVERT(NVARCHAR(256), @accounting), 'NULL'),
                        ' ) '
                    );

    END

    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    DECLARE @FILTER_DATE NVARCHAR(MAX)
        = ' WHERE invoice.createdDate >= ''' + CONVERT(NVARCHAR, @beginDate) + ''' AND 
    invoice.createdDate <= '''           + CONVERT(NVARCHAR, @endDate) + '''';

    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    DECLARE @FILTER_USER NVARCHAR(MAX) = ''
    IF (@customerId IS NOT NULL)
        SET @FILTER_USER = CONCAT(' AND invoice.socialReason LIKE ''%',@customerId,'%''');

    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    DECLARE @FILTER_STATUS NVARCHAR(MAX)
        = ' AND invoice.idLegalDocumentStatus IN (SELECT 
                                                                CASE 
                                                                    WHEN '
          + ISNULL(CONVERT(NVARCHAR, @statusId), ' NULL ')
          + ' IS NULL THEN id
                                                                    ELSE '
          + ISNULL(CONVERT(NVARCHAR, @statusId), ' NULL ')
          + '
                                                                 END
                                                            FROM LegalDocumentStatus WHERE [status]=1 AND idTypeLegalDocumentType=2) ';
    IF (@statusId IS NOT NULL)
        SET @FILTER_STATUS = ' AND invoice.idLegalDocumentStatus =  ' + CONVERT(NVARCHAR, @statusId);

    IF (@statusId = 20)
        SET @FILTER_STATUS = ' AND invoice.idLegalDocumentStatus IN (7,9)  ';


    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    DECLARE @FILTER_SEARCH NVARCHAR(MAX) = '';
    IF (@search IS NOT NULL)
        SET @FILTER_SEARCH = ' AND invoice.noDocument=' + CONVERT(NVARCHAR, @search);

    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    DECLARE @FILTER NVARCHAR(MAX) = @FILTER_DATE + @FILTER_USER + @FILTER_STATUS+ @FILTER_ACCOUNTING + @FILTER_SEARCH;

    DECLARE @QUERY_PAGINATION NVARCHAR(MAX) = 'SELECT @count = COUNT(*) FROM LegalDocuments AS invoice '+ @ACCOUNT_JOIN + @FILTER;

    PRINT(@QUERY_PAGINATION);

    EXEC sp_GetPagination @pageRequested,
                          @QUERY_PAGINATION,
                          @rowsPerPage,
                          @spOffset = @offset OUTPUT,
                          @spTotalPages = @pages OUTPUT;

    ------------------------------------------------------------------------------------------------------------------------------------------------------------


    DECLARE @JSON_FORMAT NVARCHAR(MAX)
        = 'OFFSET ' + CONVERT(NVARCHAR, @offset) + ' ROWS FETCH NEXT ' + CONVERT(NVARCHAR, @rowsPerPage)
          + ' ROWS ONLY FOR JSON PATH, INCLUDE_NULL_VALUES ,ROOT(''documents'');'


    ------------------------------------------------------------------------------------------------------------------------------------------------------------

    DECLARE @DYNAMIC_QUERY NVARCHAR(MAX)
        = '
    
    SELECT  
    invoice.createdDate AS emited,
    invoice.[xml] AS [xml],
    invoice.pdf AS [pdf],
    document.idDocument AS idPreinvoice,
    invoice.id AS id,
    invoice.uuid AS uuid,
    FORMAT(document.documentNumber,''0000000'') AS numeroDocumento,
    invoice.noDocument AS documentNumber,
    invoice.currencyCode AS [moneda],
    invoiceStatus.[description] AS [status.description],
    invoiceStatus.id AS [status.id],
    invoice.total AS [total.numero],
    dbo.fn_FormatCurrency(invoice.total ) AS [total.texto],
    dbo.FormatDate(invoice.createdDate) AS [registro.formated],
    dbo.FormatDateYYYMMDD(invoice.createdDate) AS [registro.yyyymmdd],
    dbo.FormatDate(invoice.expirationDate) AS [facturar.formated],
    dbo.FormatDateYYYMMDD(invoice.expirationDate) AS [facturar.yyyymmdd],
    CASE 
        WHEN invoice.expirationDate IS NULL THEN ''ND''
        ELSE dbo.FormatDate(invoice.expirationDate)
    END AS [expirationDateFl],
    CASE 
        WHEN invoice.createdDate IS NULL THEN ''ND''
        ELSE dbo.FormatDate(invoice.createdDate)
    END AS [emitedDateFl],
    executive.initials AS [iniciales],
    invoiceStatus.[description] AS [estatus],
    customer.socialReason AS [razonSocial],
    customer.socialReason AS [customer.socialReason],
    customer.customerID AS [customer.id],
    dbo.fn_FormatCurrency(document.totalAcreditedAmount) [cobrado],
    dbo.fn_FormatCurrency(invoice.total - document.totalAcreditedAmount) AS [saldo],
    dbo.FormatDate(document.createdDate) AS [createdDate],
    dbo.fn_FormatCurrency(document.subTotalAmount) AS [import],
    dbo.fn_FormatCurrency(document.ivaAmount) AS [iva],
    ISNULL(CONVERT(BIT,Accounted.accounted),CONVERT(BIT,0)) AS isAccounted

    FROM LegalDocuments AS invoice
    LEFT JOIN LegalDocumentStatus AS invoiceStatus ON invoiceStatus.id=invoice.idLegalDocumentStatus
    LEFT JOIN Documents AS document ON document.idDocument= invoice.idDocument
    LEFT JOIN Users AS executive ON executive.userID= document.idExecutive
    LEFT JOIN Customers AS customer ON customer.customerID = invoice.idCustomer'+  @ACCOUNT_JOIN + @FILTER + ' ORDER BY invoice.id DESC ' + @JSON_FORMAT;

    PRINT (@DYNAMIC_QUERY);

    EXECUTE sp_executesql @DYNAMIC_QUERY;

    SELECT @pages AS pages,
           @pageRequested AS actualPage,
           1 AS noRegisters
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 27-07-2022
-- Description: Update the invoice when one of his CxC receives a pay
-- STORED PROCEDURE NAME:	sp_UpdateInvoiceCxcAssociation
-- ************************************************************************************************************************
-- PARAMETERS:
-- [acredited:decimal[14,4]] New accredited amount for the invoice
-- [idInvoice:int] Id of the invoice to update
-- [tolerance:decimal[14,4]] Tolerance in order to accpet the invoice as paid
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
-- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  07-27-2022     Jose Luis Perez             1.0.0.0         Documentation and query		
--  01-11-2024     Adrian Alardin              1.0.0.1         Fixed only documents without the cnacel status		
-- ************************************************************************************************************************
ALTER PROCEDURE [dbo].[sp_UpdateInvoiceCxcAssociation](
    @acredited DECIMAL(14,4),
    @idInvoice INT,
    @tolerance DECIMAL(14,4)
)

AS BEGIN

    DECLARE @newAmountAcredited DECIMAL(14,4);
    DECLARE @totalAmount DECIMAL(14,4);
    DECLARE @toleranceCalculated DECIMAL(14,4);
    DECLARE @statusInvoice INT;
    DECLARE @statusCancel INT =8;

    SELECT 
      @newAmountAcredited = totalAcreditedAmount + @acredited , 
      @totalAmount = totalAmount FROM Documents WHERE idDocument = @idInvoice;

    SELECT @toleranceCalculated = @totalAmount - @newAmountAcredited; 

    -- Ya no se utiliza el estatus del pedido, se deja como facturado. Pero si se actualiza el de legal documents
    -- SELECT @statusInvoice = CASE WHEN @toleranceCalculated <= @tolerance THEN 32 ELSE 31 END;

-- 32 Cobrada
-- 31 Parcialmente cobrada

    SELECT @statusInvoice = CASE WHEN @toleranceCalculated <= @tolerance THEN 10 ELSE 9 END;

    -- UPDATE Documents SET totalAcreditedAmount = totalAcreditedAmount + @acredited , idStatus = @statusInvoice WHERE idDocument = @idInvoice;
    UPDATE Documents SET totalAcreditedAmount = totalAcreditedAmount + @acredited WHERE idDocument = @idInvoice;

    DECLARE @totalLegalDocument DECIMAL(14,2);
    DECLARE @total DECIMAL(14,2);

    SELECT @total = totalAcreditedAmount FROM Documents WHERE idDocument = @idInvoice;
    SELECT @totalLegalDocument = total FROM LegalDocuments WHERE idDocument = @idInvoice;

    UPDATE LegalDocuments SET 
        idLegalDocumentStatus = @statusInvoice ,
        residue = @totalLegalDocument - @total 
    WHERE 
        idDocument = @idInvoice AND 
        idLegalDocumentStatus != @statusCancel



END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 08-08-2022
-- ************************************************************************************************************************
-- Description: Get the list of cxcs pending to pay of a customer
-- ************************************************************************************************************************
-- PARAMETERS:
-- @idCustomer:int - Id of the customer to fetch his pending cxcs to pay
-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
-- ***********************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ========================================================================================================================
--  08-08-2022     Jose Luis Perez             1.0.0.0         Documentation and query		
--  01-11-2024     Adrian Alardin              1.0.0.1         statsus fixed		
-- ************************************************************************************************************************
ALTER PROCEDURE [dbo].[sp_GetCxCsPendingToPayCustomer](@idCustomer INT)
AS
BEGIN
    SELECT
        CxP.idDocument AS id,
        CxP.documentNumber AS noDocument,
        CxP.idInvoice AS [invoice.id],
        Invoice.idDocumentConcept AS [invoice.concept.id],
        InformativeIncomes.description AS [invoice.concept.description],
        FORMAT(Invoice.documentNumber, '0000000') AS [invoice.documentNumber.formatted],
        Invoice.documentNumber AS [invoice.documentNumber.number],
        CASE 
            WHEN ISNUMERIC(LegalDocuments.noDocument)=1 THEN dbo.fn_formatFolio(CAST(LegalDocuments.noDocument AS INT))
            ELSE LegalDocuments.noDocument
        END AS [invoice.folio],
        -- LegalDocuments.noDocument AS [invoice.folio],
        CxP.idInvoice AS idOfTheInvoice,
        Currencies.code AS currency,
        CxP.totalAmount AS [total.number],
        dbo.fn_FormatCurrency(CxP.totalAmount) AS [total.text],
        CxP.amountToPay AS [residue.number],
        dbo.fn_FormatCurrency(CxP.amountToPay) [residue.text],
        CONCAT(CxP.currectFaction, '/', CxP.factionsNumber) AS partialitie,
        CxP.uuid AS uuid
    FROM
        Documents CxP
        INNER JOIN Currencies ON CxP.idCurrency = Currencies.currencyID
        INNER JOIN Documents Invoice ON CxP.idInvoice = Invoice.idDocument
        INNER JOIN LegalDocuments ON CxP.uuid = LegalDocuments.uuid
        INNER JOIN InformativeIncomes ON Invoice.idDocumentConcept = InformativeIncomes.id
    WHERE
    CxP.idCustomer = @idCustomer
        AND CxP.idTypeDocument = 5
        AND CxP.amountToPay > 0
        AND CxP.idStatus!=19
    FOR JSON PATH,
    ROOT('cxcs'),
    INCLUDE_NULL_VALUES;

    END
GO








-- SELECT idStatus,* FROM Documents WHERE idTypeDocument=5
-- SELECT * FROM DocumentStatus WHERE documentTypeID=5
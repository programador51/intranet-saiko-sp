-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-24-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetIsInvoiceCancelable
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idLegalDocument: The legal document id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns:If the invoice is cancelable or not
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-24		Adrian Alardin   			1.0.0.0			Initial Revision	
--	2022-03-02		Adrian Alardin   			1.0.0.1			Se modifico para que trajera el id del pdf que se tiene que eliminar del blobstorage	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/24/2022
-- Description: sp_GetIsInvoiceCancelable -If the invoice is cancelable or not.
-- =============================================
CREATE PROCEDURE sp_GetIsInvoiceCancelable
    (
    @idLegalDocument INT,
    @idExecutive INT 
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    SELECT
        CONCAT (Users.firstName,' ',Users.middleName,' ',Users.lastName1,' ',Users.lastName2) AS fullName,
        Users.email AS executiveContact,
        LegalDocuments.idLegalDocumentStatus,
        CASE
            WHEN LegalDocuments.idLegalDocumentStatus=7 THEN 1
            ELSE 0
        END AS isCancelabe,
        CASE
            WHEN LegalDocuments.idLegalDocumentStatus=7 THEN Documents.invoiceMizarNumber
            ELSE '-1'
        END AS cfdiId,
        CASE
            WHEN LegalDocuments.idLegalDocumentStatus=7 THEN ISNULL(DocumentFile.id,LegalFile.id)
            ELSE -1
        END AS pdfToDelete,
        CASE
            WHEN LegalDocuments.idDocument IS NULL THEN 1 
            ELSE 0 
        END AS isSpecial,
        ISNULL (LegalDocuments.idDocument,-1) AS idDocument,
        Document.invoiceMizarNumber AS folio,
        ISNULL(Contacts.email,Customers.email) AS customerContact,
        ISNULL(
            CONCAT(Contacts.firstName,' ',Contacts.middleName,' ',Contacts.lastName1,' ',Contacts.lastName2),
            Customers.socialReason
            ) AS customerName

    FROM LegalDocuments

        LEFT JOIN Documents ON Documents.idDocument=LegalDocuments.idDocument
        LEFT JOIN Documents AS Document ON Document.idDocument = LegalDocuments.idDocument
        LEFT JOIN AssociatedFiles DocumentFile ON DocumentFile.id=Document.pdf
        LEFT JOIN AssociatedFiles AS LegalFile ON LegalFile.id=LegalDocuments.pdf
        LEFT JOIN Users ON Users.userID=@idExecutive
        LEFT JOIN Customers ON Customers.customerID=Documents.idCustomer
        LEFT JOIN Contacts ON Contacts.customerID=Customers.customerID

    WHERE LegalDocuments.id=@idLegalDocument

END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------
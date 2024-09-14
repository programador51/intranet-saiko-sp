-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-08-2022
-- Description: Gets more info for the table
-- STORED PROCEDURE NAME:	sp_GetInvoiceReceptionPopUp
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: The list of all ODC that the specific RFC has (could be from diferents customers but with the same RFC)
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/08/2022
-- Description: sp_GetInvoiceReceptionPopUp -Gets more info for the table
-- =============================================
CREATE PROCEDURE sp_GetInvoiceReceptionPopUp (
    @legalDocumentId INT,
    @uuid NVARCHAR(256)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    SELECT 
        LegalDocument.id,
        LegalDocument.socialReason,
        dbo.fn_ConcatPhones(Contact.cellNumberAreaCode,Contact.cellNumber,Customer.ladaMovil,Customer.movil) AS cellPhone,
        dbo.fn_ConcatPhones(Contact.phoneNumber,Contact.phoneNumberAreaCode,Customer.ladaPhone,Customer.phone)AS phoneNumber, 
        ISNULL(Contact.email,Customer.email) AS email,
        LegalDocument.noDocument,
        dbo.fn_FormatCurrency(LegalDocument.import) AS import,
        dbo.fn_FormatCurrency(LegalDocument.iva) as iva,
        dbo.fn_FormatCurrency(LegalDocument.total) as total,
        dbo.fn_FormatCurrency(LegalDocument.acumulated) as acumulated,
        dbo.fn_FormatCurrency(LegalDocument.residue) as residue,
        LegalDocument.idLegalDocumentStatus,
        LegalStatus.description


    FROM LegalDocuments AS LegalDocument

    LEFT JOIN Contacts AS Contact ON LegalDocument.idLegalDocumentProvider=Contact.customerID
    LEFT JOIN Customers AS Customer ON LegalDocument.idLegalDocumentProvider=Customer.customerID
    LEFT JOIN LegalDocumentStatus AS LegalStatus ON LegalDocument.idLegalDocumentStatus=LegalStatus.id

    WHERE LegalDocument.idTypeLegalDocument=1  AND LegalDocument.id=@legalDocumentId;
    
   EXEC sp_GetCXC @uuid
END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------
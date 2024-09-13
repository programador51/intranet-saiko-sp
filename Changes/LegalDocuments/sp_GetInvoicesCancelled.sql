-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-13-2024
-- Description: Get the invoices cancelled in a specific period
-- STORED PROCEDURE NAME:	sp_GetInvoicesCancelled
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @initialDate: The initial date to filter the invoices
-- @finalDate: The final date to filter the invoices
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- 1. id: The identifier of the invoice
-- 2. folio: The folio of the invoice
-- 3. type: The type of the invoice
-- 4. socialReason: The social reason of the invoice
-- 5. cancelationDate: The date of the cancelation of the invoice
-- 6. subTotal: The sub total of the invoice
-- 7. iva: The iva of the invoice
-- 8. total: The total of the invoice
-- 9. reference: The reference of the invoice
-- 10. creationDate: The creation date of the invoice

-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-09-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetInvoicesCancelled')
    BEGIN 

        DROP PROCEDURE sp_GetInvoicesCancelled;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/13/2024
-- Description: sp_GetInvoicesCancelled - get the invoices cancelled in a specific period
CREATE PROCEDURE sp_GetInvoicesCancelled(
    @initialDate DATETIME,
    @finalDate   DATETIME
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        cfdi.id,
        cfdi.noDocument AS folio,
        cfdiType.[description] AS [type],
        cfdi.socialReason AS socialReason,
        cfdi.lastUpadatedDate AS cancelationDate,
        cfdi.import AS subTotal,
        cfdi.iva AS iva,
        cfdi.total AS total,
        ISNULL(creditNote.noDocument, cfdi.noDocument) AS reference,
        cfdi.createdDate AS creationDate
    FROM 
        LegalDocuments AS cfdi 
        LEFT JOIN LegalDocumentTypes AS cfdiType ON cfdi.idTypeLegalDocument = cfdiType.id
        LEFT JOIN LegalDocuments AS creditNote ON creditNote.id = cfdi.idLegalDocumentReference
    WHERE 
        cfdi.idTypeLegalDocument IN (2,3)
        AND cfdi.idLegalDocumentStatus IN (8,12)
        AND (cfdi.lastUpadatedDate >= @initialDate AND cfdi.lastUpadatedDate <= @finalDate)

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------

-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-10-2022
-- Description: Gets all the invoce emitted that can be replace for and other.
-- STORED PROCEDURE NAME:	sp_GetInvoiceToReplace
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @search: The input search
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: Gets all the invoce emitted that can be replace for and other.
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-03-10		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/10/2022
-- Description: sp_GetInvoiceToReplace -Gets all the invoce emitted that can be replace for and other.
-- =============================================
CREATE PROCEDURE sp_GetInvoiceToReplace
    (
    @search NVARCHAR(256)-- EL INPUT PARA BUSCAR
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    SET @search=@search + '%'
    SELECT
        id,
        currencyCode,
        emitedDate,
        facturamaNoDocument,
        idCustomer,
        rfcReceptor,
        socialReason,
        dbo.fn_FormatCurrency(total) AS total,
        uuid

    FROM LegalDocuments
    WHERE idTypeLegalDocument=2 AND idLegalDocumentStatus=7 AND (socialReason LIKE @search OR rfcReceptor LIKE @search OR facturamaNoDocument LIKE @search)



END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------


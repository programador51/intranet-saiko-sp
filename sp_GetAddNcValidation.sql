-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-15-2023
-- Description: Get the validation for add a NC to a invoice
-- STORED PROCEDURE NAME:	sp_GetAddNcValidation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-06-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/15/2023
-- Description: sp_GetAddNcValidation - Get the validation for add a NC to a invoice
CREATE PROCEDURE sp_GetAddNcValidation(
    @importe DECIMAL(14,4),
    @invoiceUuid NVARCHAR(256)
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @invoiceResidue DECIMAL(14,4);

    SELECT @invoiceResidue = residue
    FROM LegalDocuments
    WHERE uuid=@invoiceUuid

    IF(@importe>=@invoiceResidue)
        BEGIN
        RAISERROR (15600, 1, 0, 'No es valida la nota de credito para esta factura');
    END
    ELSE
        BEGIN
        SELECT idDocument, amountToPay AS residue
        FROM Documents
        WHERE uuid=@invoiceUuid
        ORDER BY amountToPay DESC

               SELECT idFacturamaLegalDocument AS idFacturama FROM LegalDocuments WHERE uuid=@invoiceUuid 


    END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
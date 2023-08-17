-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-07-2022
-- Description: Check if the invoice haven't been created against SAT, yet
-- STORED PROCEDURE NAME:	sp_GetValidationCanCreateInvoice
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
--	2022-11-07		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 11/07/2022
-- Description: sp_GetValidationCanCreateInvoice - Check if the invoice haven't been created against SAT, yet
CREATE PROCEDURE sp_GetValidationCanCreateInvoice(
    @idDocument INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idInvoiceFacturama NVARCHAR(256);

    SELECT @idInvoiceFacturama = invoiceMizarNumber FROM Documents WHERE idDocument = @idDocument

    SELECT 
        CASE 
            WHEN @idInvoiceFacturama IS NULL THEN CONVERT(BIT,1) 
            ELSE CONVERT(BIT,0) 
        END AS canCreateInvoice;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-16-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateDocumentRelatedV2
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
--	2023-02-16		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/16/2023
-- Description: sp_UpdateDocumentRelatedV2 - Some Notes
CREATE PROCEDURE sp_UpdateDocumentRelatedV2(
    @idQuote INT,
    @idOrder INT,
    @idOdc INT,
    @idContract INT
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    UPDATE Documents SET
        idInvoice=@idOrder,
        idOC=@idOdc,
        idContract=@idContract
    WHERE idDocument=@idQuote
    UPDATE Documents SET
        idQuotation=@idQuote,
        idOC=@idOdc,
        idContract=@idContract
    WHERE idDocument=@idOrder
    UPDATE Documents SET
        idQuotation=@idQuote,
        idInvoice=@idOrder,
        idContract=@idContract
    WHERE idDocument=@idOdc
    IF @idContract IS NOT NULL
        BEGIN
        UPDATE Documents SET
            idQuotation=@idQuote,
            idInvoice=@idOrder,
            idOC=@idOdc
        WHERE idDocument=@idContract
    END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-25-2022
-- Description: Update the documents related to a document
-- STORED PROCEDURE NAME:	sp_UpdateDocumentRelated
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
--	2022-11-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 11/25/2022
-- Description: sp_UpdateDocumentRelated - Update the documents related to a document
CREATE PROCEDURE sp_UpdateDocumentRelated(
    @idDocument INT,
    @idQuote INT,
    @idODC INT,
    @idInvoice INT,
    @idContract INT,
    @modifyBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    UPDATE Documents SET
    idQuotation=@idQuote,
    idContact=@idContract,
    idOC=@idODC,
    idInvoice=@idInvoice,
    lastUpdatedBy= @modifyBy
    WHERE idDocument=@idDocument
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
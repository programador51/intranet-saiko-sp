-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-255-2022
-- Description:   Try  to cancel de  document by id
-- STORED PROCEDURE NAME:	sp_CancelDocuments
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @documentId: Document id
-- @lastUpdateBy: User who try to cancel the document.
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @Message: The reply message
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-05-255		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/255/2022
-- Description: sp_CancelDocuments -  Try  to cancel de  document by id
CREATE PROCEDURE sp_CancelDocuments(
   @documentId INT,
   @lastUpdateBy NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @documentType INT;

    SELECT @documentType= idTypeDocument FROM Documents WHERE idDocument=   @documentId

    DECLARE @Message NVARCHAR(MAX);

    IF @documentType =  1
        BEGIN  
            EXEC @Message= sp_CancelQuoteDocument @documentId, @lastUpdateBy
        END
    IF @documentType =  3
        BEGIN  
            EXEC @Message= sp_CancelODCDocumnet @documentId, @lastUpdateBy
        END
    IF @documentType =  2
        BEGIN  
            EXEC @Message= sp_CancelOrderDocument @documentId, @lastUpdateBy
        END
    IF @documentType =  6
        BEGIN  
            EXEC @Message= sp_CancelContractDocument @documentId, @lastUpdateBy
        END
    IF @documentType IS NULL
        BEGIN  
            EXEC @Message= sp_UpdateCancelInvoice @documentId, @lastUpdateBy
        END
SELECT @Message AS [Message]
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
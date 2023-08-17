-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-07-2022
-- Description: Check if the invoice is on revision
-- STORED PROCEDURE NAME:	sp_GetValidationRevisionSatatus
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
-- Description: sp_GetValidationRevisionSatatus - Check if the invoice is on revision
CREATE PROCEDURE sp_GetValidationRevisionSatatus(
    @idDocument INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @authorizationFlag INT;

    SELECT 
        @authorizationFlag = authorizationFlag 
    FROM Documents 
    WHERE idDocument = @idDocument;

    SELECT 
        CASE 
            WHEN @authorizationFlag = 3 THEN CONVERT(BIT,1) 
            ELSE CONVERT(BIT,0) 
        END AS isOnRevision;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
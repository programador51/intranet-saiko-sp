


-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-12-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOdcControlComments
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
--	2023-12-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT *
FROM sys.objects
WHERE type = 'P' AND name ='sp_GetOdcControlComments')
    BEGIN

    DROP PROCEDURE sp_GetOdcControlComments;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 12/12/2023
-- Description: sp_GetOdcControlComments - Some Notes
CREATE PROCEDURE sp_GetOdcControlComments(
    @idOdc INT
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT
        id,
        idOdc,
        comment,
        createdBy,
        wasSend,
        createdDate
    FROM OdcControlComments
    WHERE
        idOdc = @idOdc AND
        [status]=1

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
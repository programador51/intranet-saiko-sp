-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-20-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetIsPositionRemisionsInvoiced
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
--	2024-08-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetIsPositionRemisionsInvoiced')
    BEGIN 

        DROP PROCEDURE sp_GetIsPositionRemisionsInvoiced;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/20/2024
-- Description: sp_GetIsPositionRemisionsInvoiced - Some Notes
CREATE PROCEDURE sp_GetIsPositionRemisionsInvoiced(
    @idPosition INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @totalRemisions INT;
    DECLARE @totalRemisionsInvoiced INT;
    SELECT 
        @totalRemisions= COUNT (*) ,
        @totalRemisionsInvoiced= SUM(CASE WHEN idStatus= 5 THEN 1 ELSE 0 END) 
    FROM Documents 
    WHERE 
        idPosition = @idPosition
        AND idTypeDocument = 2
    SELECT 
        CASE 
            WHEN @totalRemisions = @totalRemisionsInvoiced THEN CAST(1 AS BIT)
            ELSE CAST(0 AS BIT)
        END AS isRemisionsInvoiced;


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
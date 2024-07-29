
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-29-2024
-- Description: Get the remision header
-- STORED PROCEDURE NAME:	sp_GetRemisionHeader
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idPosition: The position id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @totalSell: The total sell
-- @totalRemision: The total remision
-- @residue: The residue
-- ===================================================================================================================================
-- Returns: 
-- @totalSell: The total sell
-- @totalRemision: The total remision
-- @residue: The residue
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-07-29		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetRemisionHeader')
    BEGIN 

        DROP PROCEDURE sp_GetRemisionHeader;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/29/2024
-- Description: sp_GetRemisionHeader - Gets the remision header
CREATE PROCEDURE sp_GetRemisionHeader(
    @idPosition INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    

    DECLARE @totalSell DECIMAL(14,4);
    DECLARE @totalRemision DECIMAL(14,4);
    DECLARE @residue DECIMAL(14,4);

    SELECT
        @totalSell = totalSell
    FROM PositionsProyects
    WHERE 
        id = @idPosition;

    SELECT 
        @totalRemision=(totalAmount)
    FROM Documents
    WHERE 
        idPosition = @idPosition
        AND idTypeDocument = 2
        AND idStatus != 6;

    SET @residue = @totalSell - @totalRemision;

    SELECT 
        @totalSell AS totalSell,
        @totalRemision AS totalRemision,
        @residue AS residue;



END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
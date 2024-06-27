-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-05-2024
-- Description: Get proyects filtered
-- STORED PROCEDURE NAME:	sp_GetProyects
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @limit INT - Limit of registers to fetch
-- @noRFQ NVARCHAR(256) - No RFQ to filter
-- @buyer NVARCHAR(256) - Buyer to filter
-- @page INT - Page to fetch
-- @status NVARCHAR(256) - Status to filter
-- @orderBy NVARCHAR(4) - Order by ASC or DESC
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-06-05		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetProyects')
    BEGIN 

        DROP PROCEDURE sp_GetProyects;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/05/2024
-- Description: sp_GetProyects - Get proyects filtered
CREATE PROCEDURE sp_GetProyects(
    @limit INT,
    @search NVARCHAR(256),
    @idClient INT,
    @page INT,
    @status NVARCHAR(256),
    @orderBy NVARCHAR(4)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @offsetValue INT;
    SELECT @offsetValue = (@page - 1) * @limit;
    DECLARE @likeSearch VARCHAR(255) = ISNULL('%' + @search + '%', NULL);

    SELECT 
        proyect.id,
        proyect.noRFQ,
        proyect.buyer,
        proyect.solped,
        position.pos,
        proyect.[status]
    FROM Proyects AS proyect
    LEFT JOIN PositionsProyects AS position ON proyect.id = position.idProject
    LEFT JOIN Customers AS client ON proyect.idClient = client.customerID
    WHERE 
         (
            @search IS NULL 
            OR proyect.noRFQ LIKE @likeSearch
            OR proyect.buyer LIKE @likeSearch
            OR proyect.solped LIKE @likeSearch
            OR position.pos LIKE @likeSearch
            )
            AND proyect.[status] = @status 
        AND (@idClient IS NULL OR proyect.idClient = @idClient)

    ORDER BY 
        CASE 
            WHEN @orderBy='ASC' OR @orderBy IS NULL THEN proyect.noRFQ
        END ASC,
        CASE 
            WHEN @orderBy='DESC' THEN proyect.noRFQ
        END DESC
    OFFSET @offsetValue ROWS
    FETCH NEXT @limit ROWS ONLY; 

    DECLARE @pages INT;
    DECLARE @noRecordsFound INT;
    SELECT 
        @noRecordsFound = COUNT(*) 
    FROM Proyects AS proyect
    LEFT JOIN PositionsProyects AS position ON proyect.id = position.idProject
    WHERE 
        (
            @search IS NULL 
            OR proyect.noRFQ LIKE @likeSearch
            OR proyect.buyer LIKE @likeSearch
            OR proyect.solped LIKE @likeSearch
            OR position.pos LIKE @likeSearch
            )
            AND proyect.[status] = @status 
        AND (@idClient IS NULL OR proyect.idClient = @idClient)
    SELECT 
        @pages = CASE WHEN CEILING(@noRecordsFound / @limit) <1 THEN 1 ELSE CEILING(@noRecordsFound / @limit) END;
    SELECT 
        @pages AS pages,
        @noRecordsFound AS noRecordsFound;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------

-- SELECT * FROM Proyects
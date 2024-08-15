-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-06-2024
-- Description: Get the proposals table
-- STORED PROCEDURE NAME:	sp_GetProposals
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @limit INT - Limit of registers to fetch
-- @page INT - Page to fetch
-- @orderBy NVARCHAR(4) - Order by ASC or DESC
-- @status NVARCHAR(256) - Status to filter
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
--	2024-08-06		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetProposals')
    BEGIN 

        DROP PROCEDURE sp_GetProposals;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/06/2024
-- Description: sp_GetProposals - Get the proposals table
CREATE PROCEDURE sp_GetProposals(
    @limit INT,
    @page INT,
    @orderBy NVARCHAR(4),
    @status NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @offsetValue INT;
    SELECT @offsetValue = (@page - 1) * @limit;
    DECLARE @pages INT;
    DECLARE @noRecordsFound INT;


    SELECT 
        id,
        idCustomer,
        idExecutive,
        idProyect,
        proposalNumber,
        subTotal,
        iva,
        total
        
    FROM ProyectProposals
    WHERE 
        [status] = 1 AND
        (@status IS NULL OR proposalStatus = @status)
    ORDER BY 
        CASE 
            WHEN proposalStatus = 'Activa' THEN 1
            WHEN proposalStatus = 'Enviada' THEN 2
            WHEN proposalStatus = 'Aceptada' THEN 3
            ELSE 4
        END,
        CASE 
            WHEN @orderBy='ASC' OR @orderBy IS NULL THEN id
        END ASC,
        CASE 
            WHEN @orderBy='DESC' THEN id
        END DESC
    OFFSET @offsetValue ROWS
    FETCH NEXT @limit ROWS ONLY; 

    SELECT 
        @noRecordsFound = COUNT(*)
    FROM ProyectProposals
    WHERE 
        [status] = 1 AND
        (@status IS NULL OR proposalStatus = @status);

    SELECT 
        @pages = CASE WHEN CEILING(@noRecordsFound / @limit) <1 THEN 1 ELSE CEILING(@noRecordsFound / @limit) END;
    SELECT 
        @pages AS pages,
        @noRecordsFound AS noRecordsFound;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
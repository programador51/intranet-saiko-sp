-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-23-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetRemisionsFromPositions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idPosition INT - Id proyect to filter
-- @limit INT - Limit of registers to fetch
-- @page INT - Page to fetch
-- @orderBy NVARCHAR(4) - Order by ASC or DESC
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @idTypeDcument INT - Id type document
-- @offsetValue INT - Offset value
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-07-23		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT *
FROM sys.objects
WHERE type = 'P' AND name ='sp_GetRemisionsFromPositions')
    BEGIN

    DROP PROCEDURE sp_GetRemisionsFromPositions;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/23/2024
-- Description: sp_GetRemisionsFromPositions - Some Notes
CREATE PROCEDURE sp_GetRemisionsFromPositions(
    @idPosition INT,
    @limit INT,
    @page INT,
    @orderBy NVARCHAR(4)
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idTypeDcument INT = 2;
    DECLARE @offsetValue INT;
    SELECT @offsetValue = (@page - 1) * @limit;
    -- DECLARE @likeSearch VARCHAR(255) = ISNULL('%' + @search + '%', NULL);

    SELECT
        document.idDocument AS idDocument,
        positions.id AS idPosition,
        document.documentNumber AS documentNumber,
        customers.socialReason AS socialReason,
        currencies.code AS currency,
        document.totalAmount AS total,
        document.subTotalAmount AS subTotal,
        document.ivaAmount AS iva,
        document.createdDate AS emitedDate,
        documentStatus.description AS documentStatus,
        customers.customerID AS idCustomer,
        document.uuid AS uuid,
        document.idStatus AS idStatus

    FROM PositionsProyects AS positions
        LEFT JOIN Documents AS document ON positions.id = document.idPosition
        LEFT JOIN Customers AS customers ON document.idCustomer = customers.customerID
        LEFT JOIN Currencies AS currencies ON document.idCurrency = currencies.currencyID
        LEFT JOIN DocumentNewStatus AS documentStatus ON document.idStatus = documentStatus.id
    WHERE 
        positions.id = @idPosition
        AND positions.[status] = 1
        AND document.idTypeDocument = @idTypeDcument
    ORDER BY 
        CASE 
            WHEN @orderBy='ASC' OR @orderBy IS NULL THEN positions.id
        END ASC,
        CASE 
            WHEN @orderBy='DESC' THEN positions.id
        END DESC
        OFFSET @offsetValue ROWS
    FETCH NEXT @limit ROWS ONLY;


    DECLARE @pages INT;
    DECLARE @noRecordsFound INT;
    SELECT
        @noRecordsFound = COUNT(*)
    FROM PositionsProyects AS positions
        LEFT JOIN Documents AS document ON positions.id = document.idPosition
        LEFT JOIN Customers AS customers ON document.idCustomer = customers.customerID
        LEFT JOIN Currencies AS currencies ON document.idCurrency = currencies.currencyID
        LEFT JOIN DocumentNewStatus AS documentStatus ON document.idStatus = documentStatus.id
    WHERE 
        positions.id = @idPosition
        AND positions.[status] = 1
        AND document.idTypeDocument = @idTypeDcument
    SELECT
        @pages = CASE WHEN CEILING(@noRecordsFound / @limit) <1 THEN 1 ELSE CEILING(@noRecordsFound / @limit) END;
    SELECT
        @pages AS pages,
        @noRecordsFound AS noRecordsFound;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
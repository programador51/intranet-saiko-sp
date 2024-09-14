-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-29-2024
-- Description: Proyects Excel Report
-- STORED PROCEDURE NAME:	sp_GetProyectExcel
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
--	2024-08-29		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetProyectExcel')
    BEGIN 

        DROP PROCEDURE sp_GetProyectExcel;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/29/2024
-- Description: sp_GetProyectExcel - Proyects Excel Report
CREATE PROCEDURE sp_GetProyectExcel AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT 
        proyect.id AS id,
        proyect.createdDate AS createdDate,
        customer.socialReason AS socialReason,
        proyect.noRFQ AS noRFQ,
        proyect.solped AS solped,
        positions.ocCustomer AS ocCustomer,
        proyect.title AS title,
        positions.cost AS estimatedCost,
        ISNULL((SELECT SUM(subTotalAmount) FROM Documents WHERE idPosition = positions.id AND idTypeDocument= 3 AND idStatus = 17 ) ,0)AS cost,
        positions.sell AS estimatedSell,
        ISNULL((SELECT SUM(subTotalAmount) FROM Documents WHERE idPosition = positions.id AND idTypeDocument= 2 AND idStatus =5 ),0) AS sell

    FROM Proyects AS proyect
    LEFT JOIN Customers AS customer ON customer.customerID = proyect.idClient
    LEFT JOIN PositionsProyects AS positions ON positions.idProject = proyect.id


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
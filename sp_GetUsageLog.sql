-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-02-2023
-- Description: Gets the log of usage
-- STORED PROCEDURE NAME:	sp_GetUsageLog
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
--	2023-06-02		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/02/2023
-- Description: sp_GetUsageLog - Gets the log of usage
CREATE PROCEDURE sp_GetUsageLog
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT DISTINCT
        (
            SELECT
            TOP(1)
            lastUpdatedDate
        FROM Documents
        WHERE 
                idExecutive=document.idExecutive AND
            idCustomer=document.idCustomer
        ORDER BY lastUpdatedDate DESC
        ) AS lastUpdateDate,
        customer.socialReason AS socialReason,
        document.idExecutive AS idExecutive,
        ISNULL(document.lastUpdatedBy ,'ND') AS lastUpdatedBy,
        CONCAT(users.firstName,' ',users.lastName1, ' ', users.lastName2) AS executiveName,
        (
            SELECT COUNT(*)
        FROM Documents AS quote
        WHERE 
                quote.idExecutive=document.idExecutive AND
            quote.idCustomer=document.idCustomer AND
            quote.idTypeDocument=1
        ) AS quotes,
        (
            SELECT COUNT(*)
        FROM Documents AS orden
        WHERE 
                orden.idExecutive=document.idExecutive AND
            orden.idCustomer=document.idCustomer AND
            orden.idTypeDocument=2
        ) AS orden,
        (
            SELECT COUNT(*)
        FROM Documents AS odc
        WHERE 
                odc.idExecutive=document.idExecutive AND
            odc.idCustomer=document.idCustomer AND
            odc.idTypeDocument=3
        ) AS odc,
        (
            SELECT COUNT(*)
        FROM Documents AS [contract]
        WHERE 
                [contract].idExecutive=document.idExecutive AND
            [contract].idCustomer=document.idCustomer AND
            [contract].idTypeDocument=6
        ) AS [contract]


    FROM Documents AS document
        LEFT JOIN Users AS users ON users.userID=document.idExecutive
        LEFT JOIN Customers AS customer ON customer.customerID= document.idCustomer
    ORDER BY 
        document.idExecutive,
        quotes DESC, 
        orden DESC,
        [contract] DESC,
        odc DESC


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
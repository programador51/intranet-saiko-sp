-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-15-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_FacturacionHelp
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
--	2024-08-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_FacturacionHelp')
    BEGIN 

        DROP PROCEDURE sp_FacturacionHelp;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/15/2024
-- Description: sp_FacturacionHelp - Some Notes
CREATE PROCEDURE sp_FacturacionHelp AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        document.idDocument AS idDocument,
        document.documentNumber AS documentNumber,
        document.idCustomer AS idCustomer,
        document.protected AS tc,
        customer.creditDays AS creditDays
    FROM Documents AS document
    LEFT JOIN Customers AS customer ON document.idCustomer = customer.customerID
    WHERE 
        document.idTypeDocument = 2
        AND document.idStatus = 4

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------

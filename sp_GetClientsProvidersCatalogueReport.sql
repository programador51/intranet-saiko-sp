-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-15-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetClientsProvidersCatalogueReport
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
--	2023-08-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/15/2023
-- Description: sp_GetClientsProvidersCatalogueReport - Some Notes
ALTER PROCEDURE sp_GetClientsProvidersCatalogueReport(
    @idCustomerType INT,
    @idSector INT,
    @status TINYINT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    SELECT 
        customer.socialReason AS socialReason,
        customer.commercialName AS comertialName,
        customer.shortName AS shortName,
        customerType.[description] AS sector,
        customer.rfc,
        executive.initials,
        CONCAT(
            customer.street,', ',
            customer.suburb,', ',
            customer.city,', ',
            customer.polity,', ',
            customer.cp
        ) AS adress,
        CASE 
            WHEN 
                NULLIF(customer.ladaMovil, '') IS NULL OR 
                NULLIF(customer.movil, '') IS NULL 
            THEN 'ND' 
            ELSE CONCAT( '+ ',customer.ladaMovil,' ', customer.movil ) 
        END AS contactMovil,
        CASE 
            WHEN 
                NULLIF(customer.ladaPhone ,'')IS NULL OR 
                NULLIF(customer.phone,'') IS NULL 
            THEN 'ND'
            ELSE CONCAT(
                '+ ',customer.ladaPhone,' ',
                customer.phone
            )
        END AS contactPhone,
        customer.email,
        CASE 
            WHEN customer.[status]=1 THEN 'Activo'
            ELSE 'Inactivo'
        END AS [status]

    FROM Customers AS customer
    LEFT JOIN TypeOfCustomer AS customerType ON customerType.id=customer.idTypeOfCustomer
    LEFT JOIN Customer_Executive AS customerExecutive ON customerExecutive.customerID=customer.customerID
    LEFT JOIN Users AS executive ON executive.userID = customerExecutive.executiveID
    WHERE 
        customer.customerType=@idCustomerType AND
        customer.[status]=@status AND
        customer.idTypeOfCustomer IN (
            SELECT
                CASE 
                    WHEN @idSector IS NULL THEN id
                    ELSE @idSector
                END
            FROM TypeOfCustomer
            WHERE [status]=1
        ) 
    ORDER BY
        customer.socialReason

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------

SELECT * FROM Customers WHERE idTypeOfCustomer NOT IN(4,5)
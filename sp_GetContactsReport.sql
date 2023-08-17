-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-14-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetContactsReport
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
--	2023-08-14		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/14/2023
-- Description: sp_GetContactsReport - Some Notes
ALTER PROCEDURE sp_GetContactsReport(
    @idUen INT,
    @idSector INT
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    IF (@idUEN IS NULL)
        BEGIN
            EXEC sp_GetContactsReportWithOutUen @idSector
        END
    ELSE
        BEGIN
            SELECT 
                customer.socialReason AS socialReason,
                customerType.[description] AS sector,
                uen.[description] AS uen,
                contact.firstName AS firstName, 
                contact.middleName AS middleName ,
                contact.lastName1 AS lastName1 ,
                contact.lastName2 AS lastName2 ,
                CONCAT(
                    contact.lastName1,' ',
                    ISNULL(contact.lastName2,''),' ',
                    contact.firstName, ' ' ,
                    contact.middleName
                ) AS contactName,
                CASE 
                    WHEN 
                        NULLIF(contact.cellNumber, '') IS NULL OR 
                        NULLIF(contact.cellNumberAreaCode, '') IS NULL 
                    THEN 'ND' 
                    ELSE CONCAT( '+ ',contact.cellNumberAreaCode,' ', contact.cellNumber ) 
                END AS contactMovil,
                CASE 
                    WHEN 
                        NULLIF(contact.phoneNumberAreaCode ,'')IS NULL OR 
                        NULLIF(contact.phoneNumber,'') IS NULL 
                    THEN 'ND'
                    ELSE CONCAT(
                        '+ ',contact.phoneNumber,' ',
                        contact.phoneNumberAreaCode
                    )
                END AS contactPhone,
                contact.email AS email

            FROM Contacts AS contact
            LEFT JOIN ContactsByUens AS contactUen ON contactUen.idContact=contact.contactID
            LEFT JOIN Customers AS customer ON customer.customerID=contact.customerID
            LEFT JOIN TypeOfCustomer AS customerType ON customerType.id=customer.idTypeOfCustomer
            LEFT JOIN UEN AS uen ON uen.UENID= contactUen.idUen
            WHERE 
                contactUen.idUen IN
                (SELECT  
                    CASE
                        WHEN @idUen IS NULL THEN UENID 
                        ELSE @idUen 
                    END
                FROM UEN) AND
                customer.idTypeOfCustomer IN 
                (SELECT 
                    CASE
                        WHEN @idSector IS NULL THEN  id 
                        ELSE customer.idTypeOfCustomer
                    END
                FROM TypeOfCustomer) AND
                customer.status=1 AND
                contactUen.[status]=1 
            ORDER BY 
                customerType.[description],
                uen.[description],
                contact.lastName1,
                contact.lastName2,
                contact.firstName
                ASC
        END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
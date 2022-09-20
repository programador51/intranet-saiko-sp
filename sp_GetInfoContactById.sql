-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-17-2022
-- Description: Get the contact by his id
-- STORED PROCEDURE NAME:	sp_GetInfoContactById
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
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
--	2022-08-17		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/17/2022
-- Description: sp_GetInfoContactById - Get the contact by his id
CREATE PROCEDURE sp_GetInfoContactById(
    @idContact INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        contactID,
        customerID,
        firstName,
        middleName,
        lastName1,
        lastName2,
        phoneNumberAreaCode AS ladaPhone,
        phoneNumber AS phone,
        cellNumberAreaCode AS ladaMovil,
        cellNumber AS movil,
        position,
        email,
        [status],
        CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
        CONCAT('+',phoneNumberAreaCode,phoneNumber) AS phoneNumber,
        CONCAT('+',cellNumberAreaCode,cellNumber) AS cellNumber
        
        FROM Contacts 
        WHERE 
            contactID = @idContact AND
            [status] = 1

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
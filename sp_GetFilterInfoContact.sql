-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: Get the contact information with the status and text filter
-- STORED PROCEDURE NAME:	sp_GetFilterInfoContact
-- STORED PROCEDURE OLD NAME: sp_filterInfoContact
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerID: Is the id of the customer to whom the contact is related
-- @estatus: Is status filter
-- @beginRange: represents the start of the range from which you have to search  (not null)
-- @endRange: represents the end of the range from which you have to search (not null)
-- @search: Is the text to filter on (not null)
-- ===================================================================================================================================
-- Returns: 
--          STATUS representation 0-1
--          1: Activo
--          0: Inactivo
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-02		Adrian Alardin   			1.0.0.0			Initial Revision
--  2021-07-23      Adrian Alardin              1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/02/2021
-- Description: sp_filterInfoContact permite buscar todos los que cunplan con el estatus y el texto de busqueda.
-- =============================================
CREATE PROCEDURE sp_filterInfoContact
(
    -- Add the parameters for the stored procedure here
    @customerID INT,
    @estatus TINYINT,
    @beginRange INT,
    @endRange INT,
    @search NVARCHAR(30)

)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
   SELECT customerID,
            contactID,firstName,middleName,lastName1,lastName2,
                    phoneNumberAreaCode,phoneNumber,cellNumberAreaCode,cellNumber,
                    email,position,status,
                    CASE 
                WHEN status=1 THEN 'Activo'
                WHEN status=0 THEN 'Inactivo'
                END AS statusText,
                    CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
                    CONCAT(phoneNumberAreaCode,' ',phoneNumber) AS phone,
                    CONCAT(cellNumberAreaCode, ' ',cellNumber)AS cellPhone
                    FROM Contacts WHERE (customerID=@customerID AND status=@estatus) AND (
                        firstName LIKE @search OR
                        middleName LIKE @search OR
                        lastName1 LIKE @search OR
                        lastName2 LIKE @search
                        )
                    ORDER BY lastName1
                        OFFSET @beginRange ROWS
                        FETCH NEXT @endRange ROWS ONLY
END
GO

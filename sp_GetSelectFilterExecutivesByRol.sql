-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: List of executives that the user can filter
-- according to his rol

-- STORED PROCEDURE NAME:       sp_GetSelectFilterExecutivesByRol
-- STORED PROCEDURE OLD NAME:   sp_SelectFilterExecutives

-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @rolID:  Rol id in order to know which executives show to this rol

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer				Revision	        Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0		        Initial Revision
--      2021-07-26              Jose Luis Perez                         1.0.0.1                 Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_GetSelectFilterExecutivesByRol(

	@rolID INT

)

AS BEGIN

	SELECT

        AssociatedUsers.AssociatedID AS idRegister,
        AssociatedUsers.userID AS idUser,
        AssociatedUsers.rolID AS rolID,
        Users.userID AS ignore,
        Users.firstName,
        Users.middleName,
        Users.lastName1,
        Users.lastName2,
        CONCAT(firstName,' ',middleName,' ',lastName1,' ',lastName2) AS fullName,
        CONVERT(BIT,0) AS mustErase
        
        FROM AssociatedUsers

        JOIN Users ON AssociatedUsers.userID = Users.userID

        WHERE AssociatedUsers.rolID = @rolID

        ORDER BY firstName

END
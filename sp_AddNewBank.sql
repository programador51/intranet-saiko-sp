-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: If, the user typed a bank, this will be added
-- and used on the information he edited or added.

-- STORED PROCEDURE NAME:	sp_AddNewBank
-- STORED PROCEDURE OLD NAME: sp_SelectNewBank


-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @nameBank: Name of the bank that the user typed

-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************

CREATE PROCEDURE sp_AddNewBank(

    @nameBank VARCHAR
    
)

AS BEGIN

INSERT INTO Banks 
        
        (
            socialReason, commercialName,shortName,
            status,createdBy,createdDate,
            lastUpdatedBy,lastUpdatedDate,clave
        )

        VALUES

        (
            @nameBank,@nameBank,@nameBank,
            1,'Jose Luis', getDate(),
            'Jose Luis', getDate(),999
        );

        SELECT SCOPE_IDENTITY()

END
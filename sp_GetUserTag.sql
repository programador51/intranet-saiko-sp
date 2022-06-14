-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-13-2022
-- Description: Gets the user tag by type
-- STORED PROCEDURE NAME:	sp_GetUserTag
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @executiveId:The executive Id
-- @typeId:The section type id the tags is from
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
--	2022-06-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/13/2022
-- Description: sp_GetUserTag - Gets the user tag by type
CREATE PROCEDURE sp_GetUserTag(
    @executiveId INT,
    @typeId INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
    idTag, 
    [description]
    FROM Tags 
    WHERE idExecutive= @executiveId AND idType=@typeId

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
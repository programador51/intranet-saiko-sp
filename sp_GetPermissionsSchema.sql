-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-29-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetPermissionsSchema
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: The permissions schema
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-03-29		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/29/2022
-- Description: sp_GetPermissionsSchema - The permissions schema
CREATE PROCEDURE sp_GetPermissionsSchema AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT jsonSchema FROM PermissionsSchema WHERE id = (SELECT MAX(id) FROM PermissionsSchema)

END
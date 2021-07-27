-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Jose Luis Perez Olguin
-- Create date: 07-26-2021

-- Description: Get the permissions that exist on the system
-- It's used to print the permissions when adding or editing a rol permissions
-- (Get the structure to print it on the UI)

-- STORED PROCEDURE NAME:	sp_GetSkeletonPermissions
-- STORED PROCEDURE OLD NAME: sp_SkeletonPermissions

-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--  Date            Programmer		        Revision        Revision Notes			
-- =================================================================================================
--  2021-07-22	    Iván Díaz   		1.0.0.0		Initial Revision
--  2021-07-26      Jose Luis Perez             1.0.0.1         Documentation and file name update		
-- *****************************************************************************************************************************SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_GetSkeletonPermissions]

AS BEGIN

SELECT * FROM Sections ORDER BY orderElement

END

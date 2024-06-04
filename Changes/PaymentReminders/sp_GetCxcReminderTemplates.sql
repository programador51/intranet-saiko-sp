-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-04-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCxcReminderTemplates
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
--	2024-04-04		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCxcReminderTemplates')
    BEGIN 

        DROP PROCEDURE sp_GetCxcReminderTemplates;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/04/2024
-- Description: sp_GetCxcReminderTemplates - Some Notes
CREATE PROCEDURE sp_GetCxcReminderTemplates AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT
        id,
        body,
        [module]
    FROM EmailTemplates
    WHERE 
        module = 'banckAccountCxcReminder'
        OR module = 'emailSupport'
        OR module = 'phoneSupport'
        OR module = 'coprobanteEmail'

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
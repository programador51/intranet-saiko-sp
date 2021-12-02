-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-29-2021
-- Description: We obtain the TC of the day
-- STORED PROCEDURE NAME:	sp_GetTC
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- Returns:
-- The TC
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-11-29		Adrian Alardin   			1.0.0.0			Initial Revision
--			                                                    
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetTC
     AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON

-- Insert statements for procedure here
SET
    LANGUAGE Spanish;

SELECT id, fix, DOF, pays, purchase, sales, saiko, ROUND(saiko, 2) AS test FROM TCP WHERE IDENT_CURRENT('TCP')= id
END
GO

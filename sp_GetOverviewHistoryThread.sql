-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-13-2022
-- Description: Gets the history thread of a ToDo
-- STORED PROCEDURE NAME:	sp_GetOverviewHistoryThread
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @id: The parent id
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
--	2022-07-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/13/2022
-- Description: sp_GetOverviewHistoryThread - Gets the history thread of a ToDo
CREATE PROCEDURE sp_GetOverviewHistoryThread(
    @id NVARCHAR(256)
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT TOP(1)
        ToDo.idTag AS [tag.id] ,
        Tags.[description] AS [tag.description],
        ToDo.idSection AS [section.id],
        ToDoSections.[description] AS [section.description],
        ToDo.title ,
        ToDo.lastUpdateDate ,
        ToDo.reminderDate

    FROM ToDo

        INNER JOIN Tags ON ToDO.idTag = Tags.idTag
        INNER JOIN ToDoSections ON ToDo.idSection = ToDoSections.id

    WHERE parent = @id

    FOR JSON PATH, ROOT('overview'), INCLUDE_NULL_VALUES

    END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
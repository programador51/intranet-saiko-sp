-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-16-2022
-- Description: Gets the history records related to the parent ToDo
-- STORED PROCEDURE NAME:	sp_GetToDoHistory
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @parent: The parent uuid
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @actualDate: The actual México date
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-06-16		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/16/2022
-- Description: sp_GetToDoHistory - Gets the history records related to the parent ToDo
CREATE PROCEDURE sp_GetToDoHistory(
    @parent NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @actualDate DATETIME = dbo.fn_MexicoLocalTime(GETDATE());
    SELECT 
        ToDo.id,
        dbo.FormatDate(ToDo.atentionDate)  AS atentionDate,
        ToDo.fromId,
        ToDo.idSection AS sectionId,
        dbo.FormatDate(ToDo.reminderDate) AS reminderDate,
        ToDo.idTag AS [tag.id],
        ToDo.tagDescription AS [tag.description],
        ToDo.title AS title,
        ToDo.toDoNote AS todoNote,
        Customers.socialReason,
        parent,
        CAST (
            CASE 
                WHEN ToDo.atentionDate < @actualDate THEN 1
                ELSE 0 END
            AS bit
        ) AS isExpired
    FROM ToDo
    LEFT JOIN Customers ON Customers.customerID= ToDo.customerId
    WHERE ToDo.parent= @parent
    ORDER BY ToDo.id DESC

    FOR JSON PATH, ROOT('ToDo'), INCLUDE_NULL_VALUES

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-17-2022
-- Description: Gets the urgents todo from a user (the attention date has passed)
-- STORED PROCEDURE NAME:	sp_GetUrgetnToDos
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @executiveId:  Executive Id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @actualDate: The current date
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-06-17		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/17/2022
-- Description: sp_GetUrgetnToDos - Gets the urgents todo from a user (the attention date has passed)
CREATE PROCEDURE sp_GetUrgetnToDos(
    @executiveId INT,
    @type INT,
    @fromId INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @actualDate DATETIME = dbo.fn_MexicoLocalTime(GETDATE());

    IF (@type IS NULL OR @fromId IS NULL)
        BEGIN
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
            dbo.FormatDateYYYMMDD(ToDo.createdDate) AS [created.yymmdd],
            ToDo.createdDate AS [created.fullTime],
            dbo.FormatDate(ToDo.createdDate) AS [created.format],
            Customers.socialReason,
            ToDo.customerId AS customerId,
            ToDo.parent AS parent,
            CAST (
                CASE 
                    WHEN ToDo.isTaskFinished=0 THEN 1
                    ELSE 0
                END
                AS BIT
            ) AS isOpen,
            CAST (
                CASE 
                    WHEN dbo.fn_MexicoLocalTime(ToDo.atentionDate) < @actualDate THEN 1
                    ELSE 0 END
                AS bit
            ) AS isExpired
            FROM ToDo
            LEFT JOIN Customers ON Customers.customerID= ToDo.customerId
            WHERE 
                ToDo.executiveWhoCreatedId= @executiveId  AND
                ToDo.isTaskFinished=0 AND
                dbo.fn_MexicoLocalTime(ToDo.atentionDate) < @actualDate
            ORDER BY dbo.fn_MexicoLocalTime(ToDo.atentionDate) ASC
            FOR JSON PATH, ROOT('ToDo'), INCLUDE_NULL_VALUES
        END
    ELSE
        BEGIN
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
            dbo.FormatDateYYYMMDD(ToDo.createdDate) AS [created.yymmdd],
            ToDo.createdDate AS [created.fullTime],
            dbo.FormatDate(ToDo.createdDate) AS [created.format],
            Customers.socialReason,
            ToDo.customerId AS customerId,
            ToDo.parent AS parent,
            CAST (
                CASE 
                    WHEN ToDo.isTaskFinished=0 THEN 1
                    ELSE 0
                END
                AS BIT
            ) AS isOpen,
            CAST (
                CASE 
                    WHEN dbo.fn_MexicoLocalTime(ToDo.atentionDate) < @actualDate THEN 1
                    ELSE 0 END
                AS bit
            ) AS isExpired
            FROM ToDo
            LEFT JOIN Customers ON Customers.customerID= ToDo.customerId
            WHERE 
                ToDo.executiveWhoCreatedId= @executiveId  AND
                ToDo.isTaskFinished=0 AND
                dbo.fn_MexicoLocalTime(ToDo.atentionDate) < @actualDate AND
                ToDo.idSection= @type AND 
                ToDo.fromId= @fromId
            ORDER BY dbo.fn_MexicoLocalTime(ToDo.atentionDate) ASC
            FOR JSON PATH, ROOT('ToDo'), INCLUDE_NULL_VALUES
        END

   
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
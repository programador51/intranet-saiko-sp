-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-15-2022
-- Description: get the pending tasks to do
-- STORED PROCEDURE NAME:	sp_GetMyTodos
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
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
--	2022-06-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/15/2022
-- Description: sp_Nsp_GetMyTodosame - get the pending tasks to do
CREATE PROCEDURE sp_GetMyTodos(
    @executiveId INT,
    @type INT,
    @isUrgent BIT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @aditionalDays INT;
    DECLARE @actualDate DATETIME

    SELECT @aditionalDays=CAST ([value] AS INT), @actualDate= dbo.fn_MexicoLocalTime(GETDATE()) FROM Parameters WHERE parameter=30
    IF (@isUrgent=1)
        BEGIN
            EXEC sp_GetUrgetnToDos @executiveId
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
                        WHEN ToDo.atentionDate < @actualDate THEN 1
                        ELSE 0 END
                    AS bit
                ) AS isExpired
            FROM ToDo
            LEFT JOIN Customers ON Customers.customerID= ToDo.customerId
            WHERE ToDo.executiveWhoCreatedId= @executiveId AND ToDo.reminderDate <= DATEADD(DAY,@aditionalDays,@actualDate) AND ToDo.isTaskFinished=0 AND ToDo.idSection=@type
            ORDER BY atentionDate ASC

            FOR JSON PATH, ROOT('ToDo'), INCLUDE_NULL_VALUES
        
        END


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-10-2021
-- Description: We obtain the reminders created by an executive
-- STORED PROCEDURE NAME:	sp_GetReminder
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @executiveID - The executive id
-- @documentID - The document id
-- @sinceRegister - The begin range for the table
-- @limitRegisters - The end range for the table
-- ===================================================================================================================================
-- Returns:
-- The commentId,createdDate, the full name how registerd de reminder,the full name how must attend the reminder, attention date and 
-- the status. Sorted ascending
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-10		Adrian Alardin   			1.0.0.0			Initial Revision-
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetReminder(
        @executiveID INT 
        @documentID INT 
        @sinceRegister INT 
        @limitRegisters INT
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON
SET
    LANGUAGE Spanish;

-- Insert statements for procedure here
SET
    LANGUAGE Spanish;

SELECT
    Commentation.commentId,
    REPLACE(
        CONVERT(VARCHAR(10), Commentation.createdDate, 6),
        ' ',
        '/'
    ) AS createdDate,
	REPLACE(
        CONVERT(VARCHAR(10), Commentation.reminderDate, 6),
        ' ',
        '/'
    ) AS reminderDate,
    CONCAT (
        userRegister.firstName,
        ' ',
        userRegister.middleName,
        ' ',
        userRegister.lastName1,
        ' ',
        userRegister.lastName2
    ) AS registerFullName,
    userAttend.initials AS attendedInitials,
    REPLACE(
        CONVERT(VARCHAR(10), Commentation.attentionDate, 6),
        ' ',
        '/'
    ) AS attentionDate,
    Commentation.status,
    CASE
        WHEN Commentation.status = 0 THEN 'No atendido'
        ELSE 'Atendido'
    END AS statusDescription,
    Commentation.comment,
	CommentsTypes.descriptionType
FROM
    Commentation
    LEFT JOIN Users as userRegister ON Commentation.registerById = userRegister.userID
    LEFT JOIN Users as userAttend ON Commentation.mustAttendById = userAttend.userID
    LEFT JOIN CommentsTypes  ON Commentation.commentTypeId = CommentsTypes.commentsTypesId

WHERE
    (
        Commentation.registerById = @executiveID
        AND Commentation.documentId = @documentID
    )
    AND (Commentation.mustAttendById IS NOT NULL)
ORDER BY
    Commentation.attentionDate ASC OFFSET @sinceRegister ROWS FETCH NEXT @limitRegisters ROWS ONLY
END
GO
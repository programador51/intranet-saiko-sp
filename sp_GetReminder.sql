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
-- @ID - The documenT,contact or customer id
-- @sinceRegister - The begin range for the table
-- @limitRegisters - The end range for the table
-- @reminderFrom: Is an aditional value to validate if the reminder is for a contact, customer or a document.
--                The posibles values are:
--                  1: Customer                
--                  2: Contact                 
--                  3: Document 
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
--	2021-10-10		Adrian Alardin   			1.0.0.1			It changes the way we validate if the reminder was attended
--			                                                    
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetReminder(
        @executiveID INT ,
        @ID INT ,
        @sinceRegister INT ,
        @limitRegisters INT,
        @reminderFrom INT
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON

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
    userRegister.initials AS registerInitials,
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
    CONCAT (
        userAttend.firstName,
        ' ',
        userAttend.middleName,
        ' ',
        userAttend.lastName1,
        ' ',
        userAttend.lastName2
    ) AS attendedFullName,
    REPLACE(
        CONVERT(VARCHAR(10), Commentation.attentionDate, 6),
        ' ',
        '/'
    ) AS attentionDate,
    ISNULL(Commentation.realAttentionDate,'---'),
    Commentation.comment,
	Commentation.commentTypeDescription 
FROM
    Commentation
    LEFT JOIN Users as userRegister ON Commentation.registerById = userRegister.userID
    LEFT JOIN Users as userAttend ON Commentation.mustAttendById = userAttend.userID

WHERE
    (
        Commentation.registerById = @executiveID
        AND (
		CASE
			WHEN @reminderFrom=1 THEN Commentation.customerId
			WHEN @reminderFrom=2 THEN Commentation.contactId
			WHEN @reminderFrom=3 THEN Commentation.documentId
			ELSE -1
		END =@ID
		)
    )
    AND (Commentation.mustAttendById IS NOT NULL)
ORDER BY
    Commentation.attentionDate ASC OFFSET @sinceRegister ROWS FETCH NEXT @limitRegisters ROWS ONLY
END
GO
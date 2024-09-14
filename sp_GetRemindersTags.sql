-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 13-10-2021
-- Description: We obtain the reminders tags by users
-- STORED PROCEDURE NAME:	sp_GetRemindersTags
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @executiveID - The executive id
-- @reminderFrom: Is an aditional value to validate if the reminder is for a contact, customer or a document.
--                The posibles values are:
--                  1: Customer                
--                  2: Contact                 
--                  3: Document 
-- ===================================================================================================================================
-- Returns:
-- It return the array of reminders tags that the user logged  has created on the espesific level (Customers,Contacts,Documents)
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-13		Adrian Alardin   			1.0.0.0			Initial Revision
--	2021-10-13		Adrian Alardin   			1.0.1.0			We change the columns names and data type from CommentsTags
--				                                                Changed columns:
--				                                                    commentsTypeID => commentsTagsId [INT]
--				                                                    descriptionType => descriptionTag [NVARCHAR]
--				                                                    originComment => reminderFrom [INT]
--			                                                    
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetRemindersTags(
        @executiveID INT,
        @reminderFrom INT
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON -- Insert statements for procedure here
SET
    LANGUAGE Spanish;

SELECT
    commentsTagsId,
    descriptionTag
FROM
    CommentsTags
WHERE
    (executiveID = @executiveID)
    AND (reminderFrom = @reminderFrom)
    AND status = 1
END
GO
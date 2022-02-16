-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-12-2021
-- Description: We add the reminder dependig the level (customer,contact or document)
-- STORED PROCEDURE NAME:	sp_AddReminder
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @userRegisteredID: The user who register the reminder
-- @attentedExecutive: The user who we assing the reminder
-- @reminderDate: The reminder date
-- @attentionDate: The attention date
-- @comments: The comment
-- @reminderTagDescirption: The reminder tag
-- @createdBy: The user who register the reminder
-- @documentID: The document the reminder is related to // this has to validate if can be unique for documentId,customerID and contacID
-- @ID: Is the ID related to customer, contact or document
-- @reminderFrom: Is an aditional value to validate if the reminder is for a contact, customer or a document.
--                The posibles values are:
--                  1: Customer                
--                  2: Contact                 
--                  3: Document                 
--                  4: An authorization was aproved or rejected and the customerID = ID                                
-- ===================================================================================================================================
-- Returns:
-- If the reminder was added successfully
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-12		Adrian Alardin   			1.0.0.0			Initial Revision
--
--	2021-10-12		Adrian Alardin   			1.0.1.0			We add the folowing columns:
--                                                                  1.- customerID [INT]
--                                                                  2.- contactID [INT] 
--                                                                  3.- realAttentionDate [DATETIME]
--                                                                  4.- commentTypeDescription [NVARCHAR (15)]
--                                                              We remove the folowign column
--                                                                  1.-commentTypeId [INT]
--
--	2021-10-12		Adrian Alardin   			1.0.1.1			We change the sp to fit the needs to insert the reminder into
--				                                                customers,contacts or douments.
--	2021-10-15		Adrian Alardin   			1.0.1.2			We insert two columns more commentType= 1,reminderFrom=@reminderFrom
--	2021-10-15		Adrian Alardin   			1.0.1.3			We adjust to make commentType a variable
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_AddReminder(
         @userRegisteredID INT,
        @attentedExecutive INT,
        @reminderDate DATETIME,
        @attentionDate DATETIME,
        @comments NVARCHAR (256),
        @reminderTagDescirption NVARCHAR (50),
        @createdBy NVARCHAR (30),
        @ID INT,
		@reminderFrom INT,
		@realAttentionDate DATETIME,
		@attentionComment NVARCHAR(256),
		@previousCommentId BIGINT,
		@commentType INT
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
 DECLARE @customerID INT, @contactID INT,@documentID INT

	SET @customerID = CASE 
						WHEN @reminderFrom=1 THEN @ID
						WHEN @reminderFrom=4 THEN @ID
						ELSE NULL
						END
	SET @contactID = CASE 
						WHEN @reminderFrom=2 THEN @ID
						ELSE NULL
						END
	SET @documentID = CASE 
						WHEN @reminderFrom=3 THEN @ID
						ELSE NULL
						END
INSERT INTO
    Commentation (
        registerById,
        mustAttendById,
        reminderDate,
        attentionDate,
        createdDate,
        comment,
        commentTypeDescription,
        status,
        createdBy,
        lastUpdateBy,
        lastUpdateDate,
		customerId,
        contactId,
		documentId,
		commentType,
		reminderFrom,
		realAttentionDate,
		attentionComment,
		previousCommentId
    )
VALUES
(
        @userRegisteredID,
        @attentedExecutive,
        @reminderDate,
        @attentionDate,
        GETDATE(),
        @comments,
        @reminderTagDescirption,
        1,
        @createdBy,
        @createdBy,
        GETDATE(),
		@customerID,
		@contactID,
		@documentID,
		@commentType,
		@reminderFrom,
		@realAttentionDate,
		@attentionComment,
		@previousCommentId
    )
    UPDATE Documents SET hasReminders=1 WHERE @reminderFrom=3 AND idDocument=@ID
	SELECT SCOPE_IDENTITY() FROM Commentation AS previousCommentId
END
GO
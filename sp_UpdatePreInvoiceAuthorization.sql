-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-10-2021
-- Description: Is the authorization process to invoice the pre-invoice
-- STORED PROCEDURE NAME:	sp_UpdatePreInvoiceAutorization
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @attentedExecutive: the id of the executive who needs to be informed of the authorization process
-- @comments: Is the response commento to the executive it also works as the previus comment for the athorization request
-- @attentionDate: Is the date the executive have to finish the proces
-- @reminderDate: The reminder date
-- @userRegisteredID: The user id how register the reminder
-- @ID: In this case is the document Id
-- @reminderFrom: Where the reminder comes from 
--                  The posibles values are:
--                  1: Customer                
--                  2: Contact                 
--                  3: Document 
-- @createdBy: The executive id that either accept or reject the preinvoice
-- @previousCommentId: Is a parameter that the sp_AddReminder requires, but in this case is not needed
-- @commentID: The id of the reminder that is being answered
-- @idDocument: The document id
-- [INFORMATIVE]@idFlag: The authorization flag that the preinvoice need to be invoice
--          The posibles values are:
--          1: No requiere autorización                
--          2: Requiere autorización                 
--          3: En proceso
--          4: Autorizado      
-- @limitTime: The time limit that the authorization counts
-- @auhtorization: Indicates the operation, aprove or reject
--          The posibles values are:
--          1: Aprove                
--          2: Reject 
-- ===================================================================================================================================
-- Returns:
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-11-10		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_UpdatePreInvoiceAutorization(
        @attentedExecutive INT,
        @comments NVARCHAR(256),
        @attentionDate DATETIME,
        @reminderDate DATETIME,
        @userRegisteredID INT,
        @reminderTagDescirption NVARCHAR (50),
        @ID BIGINT,
        @reminderFrom INT,
        @createdBy NVARCHAR(30),
        @previousCommentId BIGINT,
        @commentID BIGINT,

        @auhtorization TINYINT,
		@commentType INT
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
    DECLARE @message NVARCHAR (128)
    DECLARE @comment NVARCHAR (256)
    DECLARE @idDocument BIGINT
    DECLARE @limitTime DATETIME
	DECLARE @commentTypeAuth INT
	DECLARE @commentTypeReject INT

    SET @comment=@comments
    SET @idDocument=@ID
	SET @limitTime=@attentionDate
	SET @commentTypeAuth=6
	SET @commentTypeReject=8

    
    EXEC sp_UpdateReminder @comment,@commentID,@commentID,@commentType
    IF @auhtorization=1 --Se autoriza el documento
        BEGIN
			EXEC sp_AddReminder @userRegisteredID,@attentedExecutive,@reminderDate,@attentionDate,@comments,@reminderTagDescirption,@createdBy,@ID,@reminderFrom,null,null,@commentID,@commentTypeAuth
            EXEC sp_UpdatePreinvoiceAuth @idDocument,4,@limitTime
            SET @message=' ha sido authorizada y se ha informado al ejecutivo'
        END
    ELSE --No se autoriza el documento
        BEGIN
		EXEC sp_AddReminder @userRegisteredID,@attentedExecutive,@reminderDate,@attentionDate,@comments,@reminderTagDescirption,@createdBy,@ID,@reminderFrom,null,null,@commentID,@commentTypeReject
            EXEC sp_UpdatePreinvoiceAuth @idDocument,2,null
            SET @message=' ha sido rechazada y se ha informado al ejecutivo'
        END
	SELECT @message AS message
    END
GO
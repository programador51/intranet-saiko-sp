-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 13-10-2021
-- Description: We create the tags for diferents users
-- STORED PROCEDURE NAME:	sp_AddCommnetTag
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @descriptionTag: is the tag description
-- @status: if is active or not
-- @createdDate: the date it was created
-- @createdBy: the user how create de tag
-- @lastUpdateDate: the date it was updated
-- @executiveId: The executive id
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
--			                                                    
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_AddCommnetTag(
        @descriptionTag NVARCHAR (50),
        @status TINYINT,
        @createdBy NVARCHAR (30),
        @executiveId INT,
        @reminderFrom INT 
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON -- Insert statements for procedure here
SET
    LANGUAGE Spanish;

INSERT INTO
    CommentsTags(
        descriptionTag,
        status,
        createdDate,
        createdBy,
        lastUpdateDate,
        lastUpdateBy,
        executiveId,
        reminderFrom,
    )
    VALUES(
        @descriptionTag,
        @status,
        GETDATE()
        @createdBy,
        GETDATE()
        @executiveId,
        @reminderFrom
    )
END
GO
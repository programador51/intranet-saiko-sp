-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-10-2021
-- Description: We obtain the reminders created by an executive
-- STORED PROCEDURE NAME:	sp_GetReminderInfoHeader
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @ID - The documenT,contact or customer id
-- @reminderFrom: Is an aditional value to validate if the reminder is for a contact, customer or a document.
--                The posibles values are:
--                  1: Customer                
--                  2: Contact                 
--                  3: Document 
-- ===================================================================================================================================
-- Returns:
-- The header for the modal
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-15		Adrian Alardin   			1.0.0.0			Initial Revision-
--	2021-10-26		Adrian Alardin   			1.0.2.0			It change the way de sp works, it does the same functiality as 
--                                                              the previus version but in a diferent way
--			                                                    
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetReminderInfoHeader(
        @ID BIGINT,
        @reminderFrom INT
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON -- Insert statements for procedure here
SET
    LANGUAGE Spanish;
    -- DECLARE @hederType1 NVARCHAR(100),@hederType2 NVARCHAR (100)

    ---------------------------------------------------------------------------------------------------CUSTOMER
    IF (@reminderFrom = 1)
        BEGIN
            SELECT
                CustomerTypes.description AS hederType1,
                Customers.commercialName AS hederType2
            FROM
                Customers
                LEFT JOIN CustomerTypes on Customers.customerType = CustomerTypes.customerTypeID
            WHERE
                customerID = @ID
        END
    ---------------------------------------------------------------------------------------------------CONTACT
    ELSE IF (@reminderFrom = 2)
        BEGIN
            SELECT
                CONCAT (
                    Contacts.firstName,
                    ' ',
                    Contacts.middleName,
                    ' ',
                    Contacts.lastName1,
                    ' ',
                    Contacts.lastName2
                ) AS hederType1,
                 Contacts.email AS hederType2
            FROM
                Contacts
            WHERE
                contactID = @ID
        END
---------------------------------------------------------------------------------------------------DOCUMENT

    ELSE IF (@reminderFrom = 3)
            BEGIN
                SELECT
                    DocumentTypes.description AS hederType1,
                    FORMAT(Documents.documentNumber,'0000000') AS hederType2
                FROM
                    Documents
                    LEFT JOIN DocumentTypes ON Documents.idTypeDocument = DocumentTypes.documentTypeID
                WHERE
                 Documents.idDocument = @ID

            END

-- SELECT
--     @hederType1 AS hederType1,
--     @hederType2 AS hederType2
---------------------------------------------------------------------------------------------------TABLE
END
GO
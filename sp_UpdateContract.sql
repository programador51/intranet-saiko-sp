-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin Iracheta 
-- Create date: 01-11-2022

-- Description: Update the contract document

-- STORED PROCEDURE NAME:	sp_UpdateContract


-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @reminderDate: The reminder date
-- @expirationDate: The expiration date
-- @idContact: The contact id
-- @editedBy: The executive how edit the document
-- @idContract: The contract id
-- ===================================================================================================================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================	
--  2021-01-10      Adrian Alardin Iracheta     1.0.0.0         Initial Revision		
-- *****************************************************************************************************************************



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_UpdateContract (

    @reminderDate DATE,
    @expirationDate DATE,
    @idContact INT,
    @editedBy NVARCHAR(30),
    @idContract INT

)

AS BEGIN

DECLARE @isEditable BIT;

SELECT @isEditable= dbo.isDocumentEditable(@idContract)

    IF @isEditable=1 
        BEGIN
            UPDATE Documents
                SET
                reminderDate=@reminderDate,
                expirationDate=@expirationDate,
                idContact = @idContact,
                lastUpdatedBy = @editedBy,
                lastUpdatedDate = GETDATE()
                WHERE idDocument = @idContract;

            SELECT @isEditable AS isEditable;
        END
    ELSE 
        BEGIN
            SELECT 'El contrato seleccionado ya no es editable' AS message,
            @isEditable AS isEditable;
        END
END



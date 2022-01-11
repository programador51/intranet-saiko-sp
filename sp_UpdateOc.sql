-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin Iracheta 
-- Create date: 01-11-2022

-- Description: Update the contract document

-- STORED PROCEDURE NAME:	sp_UpdateOc


-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idContact: The contact id
-- @creditDays: The credit days
-- @editedBy: The executive how edit the document
-- @idOc: The Oc id
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
CREATE PROCEDURE sp_UpdateOc (
    @idContact INT,
    @creditDays INT,
    @editedBy NVARCHAR(30),
    @idOc INT

)

AS BEGIN

DECLARE @isEditable BIT;

SELECT @isEditable= dbo.isDocumentEditable(@idOc)

    IF @isEditable=1 
        BEGIN
            UPDATE Documents
                SET
                idContact = @idContact,
                creditDays = @creditDays,
                lastUpdatedBy = @editedBy,
                lastUpdatedDate = GETDATE()
                WHERE idDocument = @idOc;

            SELECT @isEditable AS isEditable;
        END
    ELSE 
        BEGIN
            SELECT 'El contrato seleccionado ya no es editable' AS message,
            @isEditable AS isEditable;
        END
END



-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin Iracheta 
-- Create date: 12-28-2021

-- Description: Update the preinvoice document

-- STORED PROCEDURE NAME:	sp_UpdatePreinVoiceV2


-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @cfdi: The CFDI
-- @payMethod: The payment method
-- @payForm: The payment form
-- @editedBy: The user how edit the document.
-- @contact: The new contact id
-- @idInvoice: The document id (in this case is the invoice id)
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
CREATE PROCEDURE sp_UpdatePreinVoiceV2 (

    @cfdi INT,
    @payMethod INT,
    @payForm INT,
    @editedBy NVARCHAR(30),
    @contact INT,
    @idInvoice INT

)

AS BEGIN

DECLARE @isEditable BIT;

SELECT @isEditable= dbo.isDocumentEditable(@idInvoice)
    IF @isEditable=1 
        BEGIN
            UPDATE Documents
                SET
                idContact = @contact,
                lastUpdatedDate = GETDATE(),
                idPaymentMethod = @payMethod,
                idPaymentForm = @payForm,
                lastUpdatedBy = @editedBy,
                idCfdi = @cfdi
                WHERE idDocument = @idInvoice;
        END
    ELSE 
        BEGIN
            SELECT 'La prefactura seleccionada ya no es editable'
        END
END



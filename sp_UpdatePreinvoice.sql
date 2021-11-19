-- ************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- ************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 19-11-2021
-- ************************************************************************************************************************
-- Description: Update the information of the preinvoice when the invoice it's created
-- ************************************************************************************************************************
-- PARAMETERS:
-- @currency: Id of the new currency to use on preinvoice
-- @tc: New TC to use on preinvoice
-- @importe: Iva + Subtotal (with the TC exchange applied)
-- @updatedBy: Fullname of the executive who created the invoice documento
-- @iva: New iva (with TC exchange applied)
-- @subtotal: New subtotal (with TC exchange applied)
-- @idPreinvoice: Id of the preinvoice document to update

-- ************************************************************************************************************************
--	REVISION HISTORY/LOG
 -- ************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  19-11-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- ************************************************************************************************************************

CREATE PROCEDURE sp_UpdatePreinvoice(
    @currency INT,
    @tc DECIMAL(14,4),
    @importe DECIMAL(14,4),
    @updatedBy NVARCHAR(30),
    @iva DECIMAL(14,4),
    @subtotal DECIMAL(14,4),
    @idPreinvoice INT
)

AS BEGIN

    UPDATE Documents SET

      idCurrency = @currency,
      protected = @tc,
      lastUpdatedDate = GETDATE(),
      totalAmount = @importe,
      subTotalAmount = @subtotal, 
      lastUpdatedBy = @updatedBy,
      ivaAmount = @iva,
      tcRequested = @tc

    WHERE idDocument = @idPreinvoice;

END
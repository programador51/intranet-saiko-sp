-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-26-2023
-- Description: Get the validation for add a NCR to a invoice recived
-- STORED PROCEDURE NAME:	sp_GetAddNcrValidation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2023-06-26		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/26/2023
-- Description: sp_GetAddNcrValidation - Get the validation for add a NCR to a invoice recived
CREATE PROCEDURE sp_GetAddNcrValidation(
    @importe DECIMAL(14,4),
    @invoiceUuid NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @existInvoice BIT=0;
    SELECT @existInvoice =
        CASE 
            WHEN id IS NULL THEN 0
            ELSE 1
        END
    FROM LegalDocuments
    WHERE uuid=@invoiceUuid;

    IF(@existInvoice IS NULL)
        BEGIN
            ;THROW 51000, 'La factura que asocia esta nota de credito no existe', 1; 
        END
    ELSE

        BEGIN
            DECLARE @invoiceResidue DECIMAL(14,4);
            DECLARE @tc DECIMAL(14,2)
            SELECT TOP(1) @tc = DOF   FROM TCP ORDER BY id DESC

            SELECT @invoiceResidue = residue
            FROM LegalDocuments
            WHERE uuid=@invoiceUuid

            IF(@importe>=@invoiceResidue)
                BEGIN
                    ;THROW 51000, 'No es valida la nota de credito para esta factura.', 1; 

                END
            ELSE
                BEGIN
                    SELECT 
                        idDocument, 
                        amountToPay AS residue
                    FROM Documents
                    WHERE uuid=@invoiceUuid AND idTypeDocument=4
                    ORDER BY idDocument DESC

                    
                    SELECT 
                        -- invoice.idFacturamaLegalDocument AS idFacturama, -- no necesito el id de facturama
                        invoice.id AS idInvoice
                        -- invoice.socialReason AS socialReason,
                        -- customer.cp AS cp,
                        -- customer.fiscalRegime AS fiscalRegime,
                        -- @tc AS exchangeRate,
                        -- dbo.fn_NextLegalDocNumberNCE() AS folio -- Eliminar esta opcion debe de estar el folio de la NC recibida
                    FROM LegalDocuments AS invoice
                    -- LEFT JOIN Customers AS customer ON  customer.customerID = invoice.idCustomer
                    WHERE invoice.uuid=@invoiceUuid 

                END

        END


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
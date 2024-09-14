-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-20-2021
-- Description: We add the reminder dependig the level (customer,contact or document)
-- STORED PROCEDURE NAME:	sp_UpdateCancelDocumets
-- STORED PREVIOUS NAME:	sp_UpdateQuoteStatus
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @quoteId: the quote id
-- @preInvoiceId: the pre-invoice id
-- @ocId: The oc id
-- @executiveId: The executive id
-- @motive: The motive it was canceled
-- @modifyBy: The user how modify the document
-- @docuemntType: The document Type
--                 1:Cotizacion
--                 2:Pre-Factura
--                 3:Orden de compra
--                 4:Cuentas por Pagar
--                 5:Cuentas por cobrar
--                 6:Contratos
--                 7:Orden de pago
--                 8:Servicios recibidos
--                 9:Origen.
-- ===================================================================================================================================
-- The document status id to cancel de docuement  (Depends the document type is the document status id)
--                 4 :Cotizacion
--                 12 :Pre-Factura
--                 8 :Orden de compra
--                 23 :Cuentas por Pagar
--                 19 :Cuentas por cobrar
--                 15 :Contratos -- Dosen't cancel the document just finished
--                 27 :Orden de pago
--                 29 :Servicios recibidos -- Dosen't cancel the document just finished
--                 9 :Origen. -- Dosen´t have one but could be the same as a contract
-- ===================================================================================================================================
-- Returns:
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-10-20		Adrian Alardin   			1.0.0.0			Initial Revision
--	2021-10-21		Adrian Alardin   			1.0.1.0			We adjus this sp to cancel every document
--	2021-10-28		Adrian Alardin   			1.2.0.0			We adjust to cancel and terminate documents
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_UpdateCancelDocument(
        @quoteId BIGINT,
        @preInvoiceId BIGINT,
        @ocId BIGINT,
        @contractId BIGINT,
        @executiveId INT,
        @motive NVARCHAR (256),
		@docuemntType INT,
		@modifyBy NVARCHAR (30)
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
    DECLARE @cancelDocumentStatus INT
    DECLARE @ocWasSend TINYINT, @preInvoiceStatus INT
    DECLARE @contractParentId BIGINT
	DECLARE @mensaje NVARCHAR (256), @status TINYINT
    IF(@docuemntType=1)
    -- ========= IT MEANS THAT THE DOCUMENT IS A QUOTE =========
        BEGIN
            SELECT @contractParentId= idContractParent FROM Documents WHERE idDocument=@quoteId;
            IF(@contractParentId IS NULL)
                -- ========= IT MEANS THAT THE QUOTE DOSE NOT HAVE A CONTRACT PARENT =========
                BEGIN
                    SET @cancelDocumentStatus=4--                                                    [4]: Cancel the Quote Document
                    EXEC sp_UpdateDocumentStatus @cancelDocumentStatus,@quoteId,@modifyBy
                    EXEC sp_AddDocumentCancelLog @executiveId,@quoteId,@motive--                    Insert the Quote Document to DocumentCancelLog
					SET @mensaje= 'Se cancelo la cotizacion exitosamente'
					SET @status= 1
                END
            ELSE
                -- ========= IT MEANS THAT THE QUOTE DOSE HAVE A CONTRACT PARENT =========
                BEGIN
                    SET @cancelDocumentStatus=4--                                                   [4]: Cancel the Quote Document
                    EXEC sp_UpdateDocumentStatus @cancelDocumentStatus,@quoteId,@modifyBy--         CANCEL THE QUOTE DOCUMENT
                    SET @cancelDocumentStatus=15--                                                  [15]: Terminates the contract
                    EXEC sp_UpdateDocumentStatus @cancelDocumentStatus,@contractParentId,@modifyBy--TERMINATE THE CONTRACT
                    EXEC sp_AddDocumentCancelLog @executiveId,@quoteId,@motive--                    Insert the Quote Document to DocumentCancelLog
                    EXEC sp_AddDocumentCancelLog @executiveId,@contractParentId,@motive--           Insert the Contract Document to DocumentCancelLog
					SET @mensaje= 'Se cancelo la cotizacion y se termino el contrato origen exitosamente'
					SET @status= 1
                END

        END
    ELSE IF(@docuemntType=2 OR @docuemntType=3)
    -- ========= IT MEANS THAT WE TRY TO CANCEL THE PREINVOICE OR THE OC DOCUMENTS =========
        BEGIN
             SELECT @preInvoiceStatus=idStatus FROM Documents WHERE idDocument=@preInvoiceId
             SELECT @ocWasSend= wasSend FROM Documents WHERE idDocument=@ocId
            IF (@preInvoiceStatus=9 AND (@ocWasSend=0 OR @ocWasSend IS NULL))
            -- ========= IT MEANS THAT THE PRE-INVOICE IS OPEN AND THE OC HAVE NOT BEEN SEND. THE DOCUMENTS CAN BE CANCEL=========
                BEGIN
                    SET @cancelDocumentStatus=12--                                                  [12]: Cancel the pre-invoice Document
                    EXEC sp_UpdateDocumentStatus @cancelDocumentStatus,@preInvoiceId,@modifyBy--    CANCEL THE PRE-INVOICE DOCUMENT
                    SET @cancelDocumentStatus=8--                                                   [8]: Cancel the oc Document
                    EXEC sp_UpdateDocumentStatus @cancelDocumentStatus,@ocId,@modifyBy--            CANCEL THE OC DOCUMENT
                    EXEC sp_AddDocumentCancelLog @executiveId,@preInvoiceId,@motive--               Insert the pre-invoice Document to DocumentCancelLog
                    EXEC sp_AddDocumentCancelLog @executiveId,@ocId,@motive--                       Insert the oc Document to DocumentCancelLog
					SET @mensaje= 'Se cancelo la Orden de compra y la Prefactura exitosamente'
					SET @status= 1
                END
            ELSE
            -- ========= IT MEANS THAT THE PRE-INVOICE IS NOT OPEN OR THE OC HAVE BEEN SEND. THE DOCUMENTS CAN NOT BE CANCEL=========
                BEGIN
					SET @mensaje= 'No se pudo cancelar. La OC ya fue enviada y/o la Prefactura se encuentra Timbrada'
					SET @status= 0
                END
        END
    ELSE IF(@docuemntType=6)
    -- ========= IT MEANS THAT THE PRE-INVOICE IS OPEN AND THE OC HAVE NOT BEEN SEND. THE DOCUMENTS CAN BE CANCEL=========
        BEGIN
            SET @cancelDocumentStatus=15--                                                      [15]: Terminates the contract
            EXEC sp_UpdateDocumentStatus @cancelDocumentStatus,@contractId,@modifyBy--			TERMINATE THE CONTRACT
			SET @mensaje= 'Se terminio el contrato exitosamente'
			SET @status= 1
        END
	ELSE
    -- ========= IT MEANS THAT NOTHIGS HAPPENS=========
		BEGIN
			SET @mensaje= 'Hubo un problema ponte en contacto con el equipo TI'
			SET @status= 0
		END
	SELECT @mensaje AS message,@status AS status
    END
GO
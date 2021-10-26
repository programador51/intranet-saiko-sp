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
-- @documentId: The document id
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
--VARIABLES: 
-- @documentStatusId: The document status id (Depends the document type is the document status id)
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
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_UpdateCancelDocument(
        @quoteId INT,
        @ocId INT,
        @preInvoiceID INT,
        @invoiceID INT,
        @executiveId INT,
        @motive NVARCHAR (256),
		@docuemntType INT,
		@modifyBy NVARCHAR (30)
    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
    DECLARE @documentStatusId INT
    IF (@docuemntType=1)
        BEGIN
            EXEC sp_UpdateDocumentStatus 4,@quoteId,@modifyBy-- [4]: Cancel the Quote Document
            EXEC sp_AddDocumentCancelLog @executiveId,@quoteId,@motive--        Insert the Quote Document to DocumentCancelLog
        END
    ELSE IF(@docuemntType = 4 OR @docuemntType = 2)
            BEGIN
                EXEC sp_UpdateDocumentStatus 8,@ocId,@modifyBy--                    [8]: Cancel the OC Document
                EXEC sp_UpdateDocumentStatus 12,@preInvoiceID,@modifyBy--           [12]: Cancel the Pre-Invoice Document
                EXEC sp_UpdateDocumentStatus 1,@quoteId,@modifyBy--                 [1]: Change the Quote from won to open
                EXEC sp_AddDocumentCancelLog @executiveId,@ocId,@motive--           Insert the OC Document to DocumentCancelLog
                EXEC sp_AddDocumentCancelLog @executiveId,@preInvoiceID,@motive--   Insert the Pre-Invoice Document to DocumentCancelLog
            END
    END
GO
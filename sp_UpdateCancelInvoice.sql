-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-25-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_UpdateCancelInvoice
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idLegalDocument: The legal document id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns:
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/25/2022
-- Description: sp_UpdateCancelInvoice - Update the document [invoice: cancelada, pre-invoice:abierta, quote: ganada].
-- =============================================
CREATE PROCEDURE sp_UpdateCancelInvoice
    (
    @legalDocumentId INT,
    @pdfIds NVARCHAR (MAX)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @TransactionName NVARCHAR(32) = 'CancelInvoiceTransaction';
    BEGIN TRANSACTION @TransactionName
        DECLARE @documentRelatedId INT;
        DECLARE @preInvoiceId INT;
        DECLARE @quoteId INT;
        DECLARE @idDocumentInvoicePDF INT;
        DECLARE @idLegalInvoicePDF INT;

        SELECT @documentRelatedId=idDocument FROM LegalDocuments WHERE id=@legalDocumentId

        -- Se obtiene el id del registro de AssociatedFiles para actualizar el registro pdf de Docuementos
        -- de la prefactura y en LegalDocuments
       SELECT @idLegalInvoicePDF= CONVERT(int,value) FROM STRING_SPLIT(@pdfIds,',',1) WHERE ordinal=1


--? ----------------- ↓↓↓ CHANGE THE INVOICE DOCUMET STATUST TO 'CANCELADO ↓↓↓ -----------------------

        UPDATE LegalDocuments
            SET idLegalDocumentStatus=8,
            pdf=@idLegalInvoicePDF
        WHERE id=@legalDocumentId
--? ----------------- ↑↑↑ CHANGE THE INVOICE DOCUMET STATUST TO 'CANCELADO ↑↑↑ -----------------------


--? ----------------- ↓↓↓ VALIDATES IF THE INVOICE IS A SPECIAL ONE OR NOT ↓↓↓ -----------------------

        IF(@documentRelatedId IS NOT NULL)
            BEGIN

                --? RETRIVE THE PREINVOICE AND QUOTE ID 
                SELECT @idDocumentInvoicePDF= CONVERT(int,value) FROM STRING_SPLIT(@pdfIds,',',1) WHERE ordinal=3
                SELECT 
                    @preInvoiceId=PreInvoiceDoc.idDocument,
                    @quoteId=QuoteDoc.idDocument
                FROM LegalDocuments 
                LEFT JOIN Documents AS PreInvoiceDoc ON PreInvoiceDoc.idDocument=LegalDocuments.idDocument
                LEFT JOIN Documents AS QuoteDoc ON QuoteDoc.idDocument=PreInvoiceDoc.idQuotation
                WHERE LegalDocuments.id=@legalDocumentId


                --? CHANGE THE PREINVOICE DOCUMET STATUST TO 'PREFACTURA'
                UPDATE Documents
                    SET idStatus=9,
                        pdf=@idDocumentInvoicePDF
                WHERE idDocument=@preInvoiceId

                --? CHANGE THE QUOTE DOCUMET STATUST TO 'GANADA'
                UPDATE Documents
                    SET idStatus=2
                WHERE idDocument=@quoteId


                --? CHANGE THE CXC DOCUMET STATUST TO 'CANCELADA'
                UPDATE Documents
                    SET idStatus=19
                WHERE (idInvoice=@preInvoiceId AND idTypeDocument=5)
            END
--? ----------------- ↑↑↑ VALIDATES IF THE INVOICE IS A SPECIAL ONE OR NOT ↑↑↑ -----------------------

    COMMIT TRANSACTION @TransactionName

END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------
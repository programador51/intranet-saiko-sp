SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/25/2022
-- Description: sp_UpdateCancelInvoice - Update the document [invoice: cancelada, pre-invoice:abierta, quote: ganada].
-- =============================================
ALTER PROCEDURE [dbo].[sp_UpdateCancelInvoice]
    (
    @legalDocumentId INT,

    --* 03/03/22
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

        DECLARE @idPosition INT;
        DECLARE @idProyect INT;


         

        SELECT @documentRelatedId=idDocument FROM LegalDocuments WHERE id=@legalDocumentId

        --* 03/03/22
        -- Se obtiene el id del registro de AssociatedFiles para actualizar el registro pdf de Docuementos
        -- de la prefactura y en LegalDocuments
       SELECT @idLegalInvoicePDF= CONVERT(int,value) FROM STRING_SPLIT(@pdfIds,',',1) WHERE ordinal=1

--? ----------------- ↓↓↓ CHANGE THE INVOICE DOCUMET STATUST TO 'CANCELADO ↓↓↓ -----------------------

        UPDATE LegalDocuments
            SET idLegalDocumentStatus=8,
            pdf=@idLegalInvoicePDF --* 03/03/22
            
        WHERE id=@legalDocumentId
--? ----------------- ↑↑↑ CHANGE THE INVOICE DOCUMET STATUST TO 'CANCELADO ↑↑↑ -----------------------


--? ----------------- ↓↓↓ VALIDATES IF THE INVOICE IS A SPECIAL ONE OR NOT ↓↓↓ -----------------------

        IF(@documentRelatedId IS NOT NULL)
            BEGIN

                --? RETRIVE THE PREINVOICE AND QUOTE ID 

                --* 03/03/22
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
                    SET idStatus=4,
                    pdf=@idDocumentInvoicePDF, --* 03/03/22
                    invoiceMizarNumber=NULL
                WHERE idDocument=@preInvoiceId

                --? CHANGE THE QUOTE DOCUMET STATUST TO 'GANADA'
                UPDATE Documents
                    SET idStatus=2
                WHERE idDocument=@quoteId

                --? CHANGE THE CXC DOCUMET STATUST TO 'CANCELADA'
                UPDATE Documents
                    SET idStatus=19
                WHERE (idInvoice=@preInvoiceId AND idTypeDocument=5)


            SELECT 
                    @idPosition= idPosition
                FROM Documents WHERE idDocument= @preInvoiceId;
                
                IF(@idPosition IS NOT NULL)
                    BEGIN
                        DECLARE @totalPositions INT;
                        DECLARE @totalPositionsActive INT;
                        DECLARE @idProposal INT;
                        DECLARE @hasProposal BIT=0;

                        SELECT 
                            @idProyect= idProject
                        FROM PositionsProyects WHERE id= @idPosition;

                        SELECT 
                            TOP(1) @idProposal= idProposal
                        FROM ProposalPositionIndex
                        WHERE idPosition= @idPosition
                        ORDER BY idProposal DESC;

                        SELECT 
                            @hasProposal= CASE 
                                            WHEN [status] = 1 THEN 1
                                            ELSE 0
                                        END
                        FROM ProyectProposals
                        WHERE 
                            id= @idProposal
                            AND [status]= 1

                            IF(@hasProposal=1)
                                BEGIN
                                    UPDATE PositionsProyects SET 
                                        [statusPosition]='Propuesta'
                                    WHERE id= @idPosition;
                                END
                            ELSE
                                BEGIN
                                    UPDATE PositionsProyects SET 
                                        [statusPosition]='Activo'
                                    WHERE id= @idPosition;
                                END
                        

                        SELECT 
                            @totalPositions= COUNT(*) 
                        FROM PositionsProyects WHERE idProject= @idProyect AND [statusPosition] !='Cancelar';

                        SELECT 
                            @totalPositionsActive= COUNT(*)
                        FROM PositionsProyects WHERE idProject= @idProyect AND [statusPosition] ='Activo';

                        IF(@totalPositions = @totalPositionsActive)
                            BEGIN
                                UPDATE Proyects SET 
                                    [statusProyect]='ActivoOperando'
                                WHERE id= @idProyect;
                            END
                        ELSE 
                            BEGIN
                                UPDATE Proyects SET 
                                    [statusProyect]='ActivoPropuestaPendiente'
                                WHERE id= @idProyect;
                            END
                    END
            END
            SELECT 'La factura se cancelo correctamente' AS message
--? ----------------- ↑↑↑ VALIDATES IF THE INVOICE IS A SPECIAL ONE OR NOT ↑↑↑ -----------------------

    COMMIT TRANSACTION @TransactionName

END
GO

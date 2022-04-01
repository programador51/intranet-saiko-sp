
DECLARE @legalDocumentId INT = 3;
DECLARE @TransactionName NVARCHAR(32) = 'CancelInvoiceTransaction';

BEGIN TRANSACTION @TransactionName
    DECLARE @documentRelatedId INT;
    DECLARE @preInvoiceId INT;
    DECLARE @quoteId INT;

    SELECT @documentRelatedId=idDocument FROM LegalDocuments WHERE id=@legalDocumentId

    --? CHANGE THE INVOICE DOCUMET STATUST TO 'CANCELADO'
    UPDATE LegalDocuments
        SET idLegalDocumentStatus=8
    WHERE id=@legalDocumentId

    IF(@documentRelatedId IS NOT NULL)
        BEGIN
            --? RETRIVE THE PREINVOICE AND QUOTE ID 
            SELECT 
                @preInvoiceId=PreInvoiceDoc.idDocument,
                @quoteId=QuoteDoc.idDocument
            FROM LegalDocuments 
            LEFT JOIN Documents AS PreInvoiceDoc ON PreInvoiceDoc.idDocument=LegalDocuments.idDocument
            LEFT JOIN Documents AS QuoteDoc ON QuoteDoc.idDocument=PreInvoiceDoc.idQuotation
            WHERE LegalDocuments.id=@legalDocumentId


            --? CHANGE THE PREINVOICE DOCUMET STATUST TO 'PREFACTURA'
            UPDATE Documents
                SET idStatus=9
            WHERE idDocument=@preInvoiceId

            --? CHANGE THE QUOTE DOCUMET STATUST TO 'GANADA'
            UPDATE Documents
                SET idStatus=2
            WHERE idDocument=@quoteId
        END

COMMIT TRANSACTION @TransactionName


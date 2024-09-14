    -- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-14-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_BalanceMovementsC
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
--	2023-08-14		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/14/2023
-- Description: sp_BalanceMovementsC - Some Notes
CREATE PROCEDURE sp_BalanceMovementsC(
    @idSocialReason INT,
    @beginDate DATETIME,
    @endDate DATETIME
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
        
    DECLARE @idMovementCancelStatus INT =4;
    DECLARE @idOrdenCancelStatus INT =12;
    DECLARE @idCxCCancelStatus INT =23;
    DECLARE @idInvoiceCancelStatus INT =5;
    DECLARE @idMovementType INT = 2;
    DECLARE @idCustomerType INT= 2
    DECLARE @idInvoiceType INT= 1;
    DECLARE @idOrdenType INT= 3;

    IF(@beginDate IS NULL OR @endDate IS NULL)
        BEGIN
            SELECT 
                @beginDate =FIRST_VALUE(createdDate) 
            OVER (ORDER BY createdDate) 
            FROM LegalDocuments
            WHERE 
                idTypeLegalDocument=@idInvoiceType AND
                idLegalDocumentStatus != @idInvoiceCancelStatus
            SELECT 
                @endDate =FIRST_VALUE(createdDate) 
            OVER (ORDER BY createdDate DESC) 
            FROM LegalDocuments
            WHERE 
                idTypeLegalDocument=@idInvoiceType AND
                idLegalDocumentStatus != @idInvoiceCancelStatus
        END

    SELECT DISTINCT
        customer.customerID AS idCustomer,
        customer.socialReason AS socialReason,
        (
            SELECT DISTINCT
                invoice.noDocument AS invoiceNo,
                invoice.createdDate AS emitedDate,
                invoice.currencyCode AS currency,
                invoice.total,
                invoice.residue,
                odc.protected AS tc,
                (
                    SELECT 
                        movement.noMovement AS movementNo,
                        movement.amount AS totalMovement,
                        account.currency AS currency,
                        movement.movementDate AS depositDate,
                        associationCxp.tcConcilation AS tc,
                        associationCxp.amountPaid,
                        associationCxp.amountAccumulated,
                        associationCxp.newAmount AS invoiceResidue,
                        movement.movementType,
                        movement.[status],
                        CONCAT(
                            'Depósito por ',dbo.fn_FormatCurrency(associationCxp.amountPaid),
                            CASE
                                WHEN account.currency='MXN' THEN ' pesos'
                                ELSE ' dolares'
                            END, ' ',
                            'parcialidad ', CONCAT(cxp.currectFaction,'/',cxp.factionsNumber), ', ',
                            bank.shortName, ' - ', account.accountNumber, ' - ', account.currency
                        )AS movementMessage
                    FROM ConcilationCxP AS associationCxp
                    LEFT JOIN Movements AS movement ON movement.MovementID=associationCxp.idMovement
                    LEFT JOIN Documents AS cxp ON cxp.idDocument=associationCxp.idCxP
                    LEFT JOIN BankAccountsV2 AS account ON account.id = movement.bankAccount
                    LEFT JOIN Banks AS bank ON bank.bankID=account.bank
                    WHERE
                        movement.movementType= @idMovementType AND
                        movement.[status] != @idMovementCancelStatus AND
                        associationCxp.uuid= invoice.uuid AND
                        associationCxp.uuid = invoice.uuid AND
                        associationCxp.[status]!= 0 AND
                        cxp.idStatus != @idCxCCancelStatus AND
                        account.[status]!=0

                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ) AS movements
                
            FROM LegalDocuments AS invoice
            LEFT JOIN LegalDocumentsAssociations AS association ON association.idLegalDocuments=invoice.id
            LEFT JOIN Documents AS odc ON odc.idDocument=association.idDocument

            WHERE 
                invoice.idLegalDocumentStatus != @idInvoiceCancelStatus AND
                invoice.idTypeLegalDocument = @idInvoiceType AND
                invoice.socialReason = customer.socialReason AND
                odc.idStatus!=@idOrdenCancelStatus AND
                association.[status]!=0
            FOR JSON PATH, INCLUDE_NULL_VALUES
        ) AS invoice
    FROM Customers AS customer
    LEFT JOIN LegalDocuments AS invoiceDoc ON invoiceDoc.socialReason=customer.socialReason
    WHERE 
        customer.customerType=@idCustomerType AND 
        customer.customerID=@idSocialReason AND
        invoiceDoc.idTypeLegalDocument=1 AND
        invoiceDoc.idLegalDocumentStatus!=@idInvoiceCancelStatus AND
        customer.socialReason= invoiceDoc.socialReason AND
        (invoiceDoc.emitedDate >= @beginDate AND invoiceDoc.emitedDate <=@endDate)

    ORDER BY customer.socialReason
    FOR JSON PATH, ROOT('BalanceMovements')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
    

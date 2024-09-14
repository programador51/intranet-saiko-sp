-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-11-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetBalanceMovementsReport
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
--	2023-08-11		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/11/2023
-- Description: sp_GetBalanceMovementsReport - Some Notes
CREATE PROCEDURE sp_GetBalanceMovementsReport(
    @idSocialReason INT,
    @beginDate DATETIME,
    @endDate DATETIME
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idMovementCancelStatus INT =4;
    DECLARE @idOrdenCancelStatus INT =6;
    DECLARE @idCxCCancelStatus INT =19;
    DECLARE @idInvoiceCancelStatus INT =8;
    DECLARE @idMovementType INT = 1;
    DECLARE @idCustomerType INT= 1
    DECLARE @idInvoiceType INT= 2;
    DECLARE @idOrdenType INT= 2;

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
                orden.protected AS tc,
                (
                    SELECT 
                        movement.noMovement AS movementNo,
                        movement.amount AS totalMovement,
                        account.currency AS currency,
                        movement.movementDate AS depositDate,
                        associationCxc.tcConcilation AS tc,
                        associationCxc.amountPaid,
                        associationCxc.amountAccumulated,
                        associationCxc.newAmount AS invoiceResidue,
                        movement.movementType,
                        movement.[status],
                        CONCAT(
                            'Depósito por ',dbo.fn_FormatCurrency(associationCxc.amountPaid),
                            CASE
                                WHEN account.currency='MXN' THEN ' pesos'
                                ELSE ' dolares'
                            END, ' ',
                            'parcialidad ', CONCAT(cxc.currectFaction,'/',cxc.factionsNumber), ', ',
                            bank.shortName, ' - ', account.accountNumber, ' - ', account.currency
                        )AS movementMessage
                    FROM ConcilationCxC AS associationCxc
                    LEFT JOIN Movements AS movement ON movement.MovementID=associationCxc.idMovement
                    LEFT JOIN Documents AS cxc ON cxc.idDocument=associationCxc.idCxC
                    LEFT JOIN BankAccountsV2 AS account ON account.id = movement.bankAccount
                    LEFT JOIN Banks AS bank ON bank.bankID=account.bank
                    WHERE
                        movement.movementType= @idMovementType AND
                        movement.[status] != @idMovementCancelStatus AND
                        associationCxc.uuid= invoice.uuid AND
                        associationCxc.uuid = invoice.uuid AND
                        associationCxc.[status]!= 0 AND
                        cxc.idStatus != @idCxCCancelStatus AND
                        account.[status]!=0

                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ) AS movements
                
            FROM LegalDocuments AS invoice
            LEFT JOIN Documents AS orden ON orden.uuid=invoice.uuid
            WHERE 
                orden.idTypeDocument=@idOrdenType AND
                orden.idStatus != @idOrdenCancelStatus AND
                invoice.idLegalDocumentStatus != @idInvoiceCancelStatus AND
                invoice.idTypeLegalDocument = @idInvoiceType AND
                invoice.idCustomer = customer.customerID AND
                orden.uuid = invoice.uuid
            FOR JSON PATH, INCLUDE_NULL_VALUES
        ) AS invoice
    FROM Customers AS customer
    LEFT JOIN LegalDocuments AS invoiceDoc ON invoiceDoc.idCustomer=customer.customerID
    WHERE 
        customer.customerType=@idCustomerType AND 
        customer.customerID IN (
            SELECT DISTINCT
                CASE 
                    WHEN @idSocialReason IS NULL THEN invoiceDocument.idCustomer
                    ELSE @idSocialReason
                END
            FROM LegalDocuments AS invoiceDocument 
            WHERE 
                invoiceDocument.idLegalDocumentStatus != @idInvoiceCancelStatus AND
                invoiceDocument.idTypeLegalDocument=@idInvoiceType
        ) AND
        (invoiceDoc.createdDate >= @beginDate AND invoiceDoc.createdDate <=@endDate)

    ORDER BY customer.socialReason
    FOR JSON PATH, ROOT('BalanceMovements')

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------








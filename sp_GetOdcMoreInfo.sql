-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-18-2023
-- Description: More info odc
-- STORED PROCEDURE NAME:	sp_GetOdcMoreInfo
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
--	2023-08-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/18/2023
-- Description: sp_GetOdcMoreInfo - More info odc
CREATE PROCEDURE sp_GetOdcMoreInfo(
    @idDocument INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        odc.documentNumber,
        documentStatus.[description] AS [status],
        currency.code AS currency,
        customer.socialReason,
        customer.rfc,
        odc.createdDate AS emitedDate,
        odc.sentDate AS sendDate,
        odc.subTotalAmount AS subtotal,
        odc.ivaAmount AS iva,
        odc.totalAmount AS total,
        (
            SELECT DISTINCT
                invoice.noDocument AS documentNumber,
                invoice.createdDate AS receptionDate,
                (customer.creditDays + invoice.createdDate) AS expirationDate,
                invoice.currencyCode AS currency,
                invoice.total AS total,
                association.tc AS tc,
                invoice.residue AS recidue,
                (
                    SELECT DISTINCT
                        payments.id,
                        payments.idMovement,
                        movement.createdDate AS emitedDate,
                        account.currency AS currency,
                        movement.amount AS total,
                        payments.tcConcilation AS tc,
                        payments.amountApplied AS applied
                        
                    FROM ConcilationCxP AS payments
                    LEFT JOIN Movements AS movement ON movement.MovementID=payments.idMovement
                    LEFT JOIN BankAccountsV2 AS account ON account.id = movement.bankAccount
                    WHERE payments.uuid =  invoice.uuid
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                    
                ) AS movements
            FROM LegalDocumentsAssociations AS association
            LEFT JOIN LegalDocuments AS invoice ON invoice.id=association.idLegalDocuments
            LEFT JOIN Customers AS customer ON customer.socialReason = invoice.socialReason
            LEFT JOIN TCP AS tc ON tc.[date] = invoice.createdDate
            WHERE association.idDocument=@idDocument
            FOR JSON PATH,INCLUDE_NULL_VALUES
        ) AS invoice

    FROM Documents AS odc
    LEFT JOIN DocumentNewStatus AS documentStatus ON documentStatus.id=odc.idStatus
    LEFT JOIN Currencies AS currency ON currency.currencyID=odc.idCurrency
    LEFT JOIN Customers AS customer ON customer.customerID = odc.idCustomer
    WHERE odc.idDocument=@idDocument
    FOR JSON PATH,ROOT('odcMoreInfo'), INCLUDE_NULL_VALUES

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
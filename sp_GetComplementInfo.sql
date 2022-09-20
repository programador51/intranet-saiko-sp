-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-26-2022
-- Description: Gets the necessary information for the plugin
-- STORED PROCEDURE NAME:	sp_GetComplementInfo
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMovement: Movement id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @postalCode: Postal code
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
--	2022-08-26		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/26/2022
-- Description: sp_GetComplementInfo - Gets the necessary information for the plugin
CREATE PROCEDURE sp_GetComplementInfo(
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @postalCode NVARCHAR(30);
    SELECT @postalCode=[value] FROM Parameters WHERE parameter=18


    IF OBJECT_ID(N'tempdb..#TempAssocaition') IS NOT NULL
            BEGIN
                DROP TABLE #TempAssocaition
            END

    CREATE TABLE #TempAssocaition (
        id INT NOT NULL IDENTITY(1,1),
        idCxC INT NOT NULL,
        idInvoice INT NOT NULL,
        idMovement INT NOT NULL,
        uuid NVARCHAR(256) NOT NULL,
        paymentMethod NVARCHAR(3) NOT NULL,
        amountUsedFromMovement DECIMAL(14,4) NOT NULL,
        ampuntToInvoice DECIMAL(14,4) NOT NULL,
        documentNumber NVARCHAR(128) NOT NULL,
        currency NVARCHAR(3) NOT NULL
    )

    INSERT INTO #TempAssocaition (
        idCxC,
        idInvoice,
        idMovement,
        uuid,
        paymentMethod,
        amountUsedFromMovement,
        ampuntToInvoice,
        documentNumber,
        currency
    )

    SELECT 
        concilationCxC.idCxC,
        document.idInvoice,
        concilationCxC.idMovement,
        invoice.uuid,
        paymetForms.code,
        SUM(concilationCxC.amountPaid),
        SUM(concilationCxC.amountApplied),
        legalDocument.noDocument,
        legalDocument.currencyCode
        
    FROM ConcilationCxC AS concilationCxC
    LEFT JOIN Documents AS document ON document.idDocument= concilationCxC.idCxC
    LEFT JOIN Documents AS invoice ON invoice.idDocument=document.idInvoice
    LEFT JOIN LegalDocuments AS legalDocument ON legalDocument.uuid= invoice.uuid
    LEFT JOIN PaymentForms AS paymetForms ON paymetForms.idPayForm= invoice.idPaymentForm
    LEFT JOIN Movements AS movement ON movement.MovementID=@idMovement
    WHERE 
        concilationCxC.idMovement= @idMovement AND 
        movement.[status]=3 AND 
        movementType=1
    GROUP BY 
        concilationCxC.idCxC, 
        document.idInvoice,
        invoice.uuid,
        legalDocument.noDocument,
        legalDocument.currencyCode,
        paymetForms.code,
        concilationCxC.idMovement
    ORDER BY concilationCxC.idCxC DESC;

    SELECT 
        'P' AS [CfdiType],
        '14' AS [NameId],
        dbo.fn_NextLegalDocNumberFE() AS [Folio],
        @postalCode AS [ExpeditionPlace], 
        customer.rfc AS [Receiver.Rfc],
        'CP01' AS [Receiver.CfdiUse],
        customer.socialReason AS [Receiver.Name],
        customer.fiscalRegime AS [Receiver.FiscalRegime],
        customer.cp AS [Receiver.TaxZipCode],
        JSON_QUERY(
            (SELECT 
                JSON_QUERY((
                    SELECT GETUTCDATE() AS [Date],
                        FORMAT(paymentMethod,'00') AS [PaymentForm],
                        (
                            SELECT 
                                SUM(amountUsedFromMovement) 
                            FROM #TempAssocaition 
                            WHERE idMovement=@idMovement AND paymentMethod= 'PPD'
                        ) AS [Amount],
                        currency.code AS [Currency],
                        JSON_QUERY((
                            SELECT DISTINCT
                            '02' AS [TaxObject],
                            tempAssociation.uuid AS [Uuid],
                            tempAssociation.documentNumber AS [Folio],
                            tempAssociation.currency AS [Currency],
                            (
                                SELECT 
                                    SUM(ampuntToInvoice) / SUM (amountUsedFromMovement)
                                FROM #TempAssocaition 
                                WHERE 
                                    idInvoice=tempAssociation.idInvoice AND
                                    paymentMethod='PPD'

                                GROUP BY uuid
                            ) AS [EquivalenceDocRel],
                            tempAssociation.paymentMethod AS [PaymentMethod],
                            (
                                SELECT 
                                    SUM(ampuntToInvoice) 
                                FROM #TempAssocaition 
                                WHERE 
                                    idInvoice=tempAssociation.idInvoice AND
                                    paymentMethod='PPD'

                                GROUP BY uuid  
                            ) AS [AmountPaid]
                            FROM #TempAssocaition AS tempAssociation
                            WHERE tempAssociation.paymentMethod='PPD'
                            ORDER BY tempAssociation.documentNumber
                            FOR JSON PATH
                        )) AS RelatedDocuments
                    FROM Movements AS movement 
                    WHERE 
                        movement.MovementID=@idMovement AND
                        movement.[status]=3 AND 
                        movement.movementType=1
                    FOR JSON PATH
                )) AS [Payments]
                
            FROM Movements AS movement 
            WHERE 
                movement.MovementID=@idMovement AND
                movement.[status]=3 AND 
                movementType=1 
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
        ) AS [Complemento]


    FROM Movements AS movement 
    LEFT JOIN BankAccounts AS bankAccount ON bankAccount.bankAccountID= movement.bankAccount
    LEFT JOIN Currencies AS currency ON currency.currencyID= bankAccount.currencyID
    LEFT JOIN Customers AS customer ON customer.customerID= movement.customerAssociated
    
    WHERE movement.MovementID=@idMovement 
    FOR JSON PATH,ROOT('complement')
    


    IF OBJECT_ID(N'tempdb..#TempAssocaition') IS NOT NULL
            BEGIN
                DROP TABLE #TempAssocaition
            END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
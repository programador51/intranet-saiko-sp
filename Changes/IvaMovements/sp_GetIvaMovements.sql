-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-22-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetIvaMovements
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
--	2024-03-22		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetIvaMovements')
    BEGIN 

        DROP PROCEDURE sp_GetIvaMovements;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/22/2024
-- Description: sp_GetIvaMovements - Some Notes
CREATE PROCEDURE sp_GetIvaMovements(
    @date DATETIME
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @beginDate DATE;
    DECLARE @endDate DATE;
    DECLARE @tc DECIMAL(14,4);
    SELECT @tc = dof FROM TCP

    SELECT 
        @beginDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @date), 0),
        @endDate = EOMONTH(@date);

    SELECT 
        incomes.MovementID AS [folio],
        incomes.createdDate AS [date],
        (

            SELECT
                concepts.[description]
            FROM ConcilationCxC AS cxcAssociation
            LEFT JOIN Documents AS cxc ON cxc.idDocument = cxcAssociation.idCxC
            LEFT JOIN LegalDocuments AS invoice ON invoice.uuid = cxc.uuid
            LEFT JOIN InformativeIncomes AS concepts ON concepts.id = invoice.idConcept
            WHERE 
                cxcAssociation.idMovement = incomes.MovementID
            FOR JSON PATH

        ) AS [concept],
        CONCAT(bank.shortName, ' ', banckAccount.accountNumber, ' ',banckAccount.currency) AS [accountDescription],
        CAST((incomes.amount) -  ( 0.16*incomes.amount)  AS DECIMAL(14,4)) AS [import],
        0.16*incomes.amount AS [iva], 
        incomes.amount AS [total],
        banckAccount.currency AS [currency],
        @tc AS [tc]

    FROM Movements AS incomes
    LEFT JOIN BankAccountsV2 AS banckAccount ON banckAccount.id = incomes.bankAccount
    LEFT JOIN Banks AS bank ON bank.bankID = banckAccount.bank
    WHERE 
        incomes.[status] IN (2,5)
        AND incomes.movementType=1
        AND customerAssociated IS NOT NULL
        AND incomes.movementDate >= @beginDate
        AND incomes.movementDate <= @endDate
    GROUP BY 
        incomes.MovementID,
        incomes.amount,
        incomes.createdDate,
        bank.shortName,
        banckAccount.accountNumber,
        banckAccount.currency
    ORDER BY incomes.MovementID
    FOR JSON PATH, ROOT('ivaIncomes')

    -- ! ---------------------------------------------------------------------------------


    SELECT 
        cxpAssociation.idMovement AS [folio],
        outcomes.createdDate AS [date],
        (
            SELECT DISTINCT
                concepts.[description] 
            FROM ConcilationEgresses AS insideCxpAssociation
            LEFT JOIN InformativeExpenses AS concepts ON concepts.id = insideCxpAssociation.idConcept
            WHERE 
                insideCxpAssociation.idMovement= cxpAssociation.idMovement
            FOR JSON PATH
        ) AS [concept],
        CONCAT(bank.shortName, ' ', banckAccount.accountNumber, ' ',banckAccount.currency) AS [accountDescription],
        CAST(outcomes.amount - (((SUM(invoice.iva) / SUM(invoice.total)))*outcomes.amount) AS DECIMAL(14,4)) AS [import],
        ((SUM(invoice.iva) / SUM(invoice.total)))*outcomes.amount AS [iva],
        outcomes.amount  AS [total],
        banckAccount.currency AS [currency],
        @tc AS [tc]

FROM ConcilationEgresses AS cxpAssociation 
    LEFT JOIN LegalDocuments AS invoice ON invoice.id = cxpAssociation.idInvoice
    LEFT JOIN Movements AS outcomes ON outcomes.MovementID = cxpAssociation.idMovement
    LEFT JOIN BankAccountsV2 AS banckAccount ON banckAccount.id = outcomes.bankAccount
    LEFT JOIN Banks AS bank ON bank.bankID = banckAccount.bank
    WHERE 
        outcomes.[status] IN (2,5)
        AND outcomes.movementType=2
        AND outcomes.movementDate >= @beginDate
        AND outcomes.movementDate <= @endDate
    GROUP BY 
        cxpAssociation.idMovement,
        outcomes.amount,
        outcomes.createdDate,
        bank.shortName,
        banckAccount.accountNumber,
        banckAccount.currency
    ORDER BY cxpAssociation.idMovement
    FOR JSON PATH,ROOT('ivaOutcomes') 

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
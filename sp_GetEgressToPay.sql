SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- *******************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- *******************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 25-02-2022
-- Description: Get the egress that must be pay
-- STORED PROCEDURE NAME:	sp_GetEgressToPay
-- ===============================================================================================================================
--	REVISION HISTORY/LOG
-- *******************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- ===============================================================================================================================
--	25-02-2022		Jose Luis Perez Olguin   			1.0.0.0			Initial Revision
-- *******************************************************************************************************************************
-- ===============================================================================================================================

ALTER PROCEDURE [dbo].[sp_GetEgressToPay]
    (@idTypeEgress INT)
AS
BEGIN
    SELECT LegalDocuments.acumulated AS [acumulated.number],
        dbo.fn_FormatCurrency(LegalDocuments.acumulated) AS [acumulated.text],
        LegalDocuments.residue AS [residue.number],
        dbo.fn_FormatCurrency(LegalDocuments.residue) AS [residue.text],
        Currencies.code AS [currency],
        LegalDocuments.total AS [total.number],
        dbo.fn_FormatCurrency(LegalDocuments.total) AS [total.text],
        InformativeExpenses.[description] AS [expense.description],
        InformativeExpenses.id AS [expense.id],
        LegalDocuments.uuid,
        LegalDocuments.noDocument AS folio
    FROM LegalDocuments
        INNER JOIN LegalDocumentsAssociations
        ON LegalDocuments.id = LegalDocumentsAssociations.idLegalDocuments
        INNER JOIN InformativeExpenses
        ON LegalDocumentsAssociations.idConcept = InformativeExpenses.id
        INNER JOIN Currencies
        ON InformativeExpenses.currency = Currencies.currencyID
    WHERE LegalDocumentsAssociations.idConcept = @idTypeEgress
        AND LegalDocuments.residue != 0
    FOR JSON PATH, ROOT('expensesToPay'), INCLUDE_NULL_VALUES;
    END
GO

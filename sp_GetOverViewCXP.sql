-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-18-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOverViewCXP
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idMovement: The movement id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: The CXP and the releated info 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-03-18		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/18/2022
-- Description: sp_GetOverViewCXP - The CXP and the releated info 
CREATE PROCEDURE sp_GetOverViewCXP(
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    SELECT 
        Customers.socialReason AS [socialReson],
        CONCAT (Documents.currectFaction,'/',Documents.partialitiesRequested) AS [CXP.partialities],
        Currencies.code AS [CXP.currency],
        dbo.fn_FormatCurrency(Documents.totalAmount) AS [CXP.total],
        dbo.fn_FormatCurrency(Documents.totalAcreditedAmount) AS [CXP.acumulated],
        dbo.fn_FormatCurrency(Documents.amountToPay) AS [CXP.residue],
        Documents.idInvoice AS [Invoice.noFactura],
        dbo.fn_FormatCurrency(LegalDocuments.total) AS [Invoice.total],
        dbo.fn_FormatCurrency(LegalDocuments.acumulated) AS [Invoice.acumulated],
        dbo.fn_FormatCurrency(LegalDocuments.residue) AS [Invoice.residue]


    FROM Documents 
    LEFT JOIN ConcilationCxP ON ConcilationCxP.idMovement=@idMovement
    LEFT JOIN Customers ON Customers.customerID=Documents.idCustomer
    LEFT JOIN Currencies ON Currencies.currencyID=DOCUMENTS.idCurrency
    LEFT JOIN LegalDocuments ON LegalDocuments.uuid=Documents.uuid

    WHERE Documents.idDocument=ConcilationCxP.idCxP

    FOR JSON PATH, ROOT('OverviewCXP')

END









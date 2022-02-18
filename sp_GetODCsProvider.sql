-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-01-2022
-- Description: gets all the users on the sistem
-- STORED PROCEDURE NAME:	sp_GetODCsProvider
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: The list of all ODC that the specific RFC has (could be from diferents customers but with the same RFC)
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-01		Adrian Alardin   			1.0.0.0			Initial Revision	
--	2022-02-03		Adrian Alardin   			1.0.0.1			Filter all ODC for the customer ID
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/01/2022
-- Description: sp_GetODCsProvider -Get the ODCs from the specific RFC
-- =============================================
CREATE PROCEDURE sp_GetODCsProvider (
    --@customerRFC NVARCHAR(256)
    @customerId INT
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    SELECT  
        Documents.idDocument AS id,
        FORMAT(Documents.documentNumber,'0000000') as noDocument,
        Currencies.code AS currency,
        Documents.totalAmount AS [total.number],
        dbo.fn_FormatCurrency(Documents.totalAmount) AS [total.text],
        Documents.totalAmount - ISNULL(Documents.totalAcreditedAmount,0)AS [residue.number],
        dbo.fn_FormatCurrency(Documents.totalAmount - ISNULL(Documents.totalAcreditedAmount,0)) AS [residue.text]
	
        -- Esto esta de mas pero se puede necesitar
        /*
        Documents.amountToBeCredited AS [couldBe.amountToBeCredited],
        Documents.amountToPay AS [couldBe.amountToPay],
        docType.description AS [couldBe.description], 
        docStatus.description AS [couldBe.description]
        */
    FROM Documents 
    LEFT JOIN StateDocuments AS docStatus ON Documents.idStatus=docStatus.state
    LEFT JOIN DocumentTypes AS docType ON Documents.idTypeDocument=docType.documentTypeID
    LEFT JOIN Currencies ON Documents.idCurrency=Currencies.currencyID

    WHERE 
        --Documents.idCustomer IN (SELECT customerID FROM Customers WHERE rfc=@customerRFC) AND
        Documents.idCustomer =@customerId AND
        idTypeDocument=3 
        AND (docStatus.state=30 OR docStatus.state=6)  
        AND Currencies.currencyID != 3 
        AND (Documents.totalAcreditedAmount IS NULL 
            OR Documents.totalAcreditedAmount=0 
            OR  Documents.totalAcreditedAmount < Documents.totalAmount)

    FOR JSON PATH,ROOT('ODC')
    
   
END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------
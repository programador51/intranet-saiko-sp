-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-09-2022
-- Description: Gets more info for the table
-- STORED PROCEDURE NAME:	sp_GetCXP
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
--	2022-02-09		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/09/2022
-- Description: sp_GetCXP -Gets more info for the table
-- =============================================
CREATE PROCEDURE sp_GetCXP
    (
    @uuid NVARCHAR(256)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    SELECT
        Doc.idDocument AS id,
        Doc.documentNumber,
        Doc.idCurrency,
        Currencies.code,
        CONCAT(Doc.currectFaction,'/',Doc.partialitiesRequested) AS partialities,
        dbo.fn_FormatCurrency(Doc.subTotalAmount)AS import,
        dbo.fn_FormatCurrency(Doc.totalAmount) AS total,
        dbo.fn_FormatCurrency(Doc.amountToPay) AS residue,
        dbo.fn_FormatCurrency(Doc.totalAcreditedAmount) AS acredited
    FROM Documents AS Doc
        LEFT JOIN Currencies ON Doc.idCurrency=Currencies.currencyID
    WHERE Doc.uuid=@uuid AND Doc.idTypeDocument=4 AND Doc.idStatus!=23
    ORDER BY Doc.createdDate DESC


END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 15-12-2021
-- Description: We obtain the total acredited amount from the invoices
-- STORED PROCEDURE NAME:	sp_GetAcreditedAmount
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @invoiceIds - The invoices ids
-- ===================================================================================================================================
-- Returns:
-- documentId, totalAcreditedAmount
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-12-15		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_GetAcreditedAmount(@invoiceIds VARCHAR(MAX)) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON -- Insert statements for procedure here
SET
    LANGUAGE Spanish;
    SELECT idDocument,ISNULL(totalAcreditedAmount,0) as totalAcreditedAmount
FROM Documents WHERE idDocument IN (SELECT value FROM STRING_SPLIT(@invoiceIds,','))
END
GO
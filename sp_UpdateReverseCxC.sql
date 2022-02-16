-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 12-23-2021
-- Description: Reverse the amount to pay (residue) and the total acredited amount for the CxC
-- STORED PROCEDURE NAME:	sp_UpdateReverseCxC
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @id: The invoice id
-- @refund: The refund
             
-- ===================================================================================================================================
-- Returns:
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes
-- =================================================================================================
--	2021-12-23		Adrian Alardin   			1.0.0.0			Initial Revision
-- *****************************************************************************************************************************
SET
    ANSI_NULLS ON
GO
SET
    QUOTED_IDENTIFIER ON
GO
    CREATE PROCEDURE sp_UpdateReverseCxC(
        @id BIGINT,
        @refund Decimal (14,4)

    ) AS BEGIN -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
SET
    NOCOUNT ON 
    UPDATE Documents SET amountToPay = amountToPay + dbo.fn_RoundDecimals((totalAcreditedAmount - @refund),2) , totalAcreditedAmount = totalAcreditedAmount - dbo.fn_RoundDecimals((totalAcreditedAmount - @refund),2) WHERE idDocument = @id
END
GO
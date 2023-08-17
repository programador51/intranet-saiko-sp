-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 11-25-2022
-- Description: Identifies if the quote has a contract
-- STORED PROCEDURE NAME:	sp_GetQuoteComesFromContract
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idQuote: Qupte id,
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @stauts TINYINT: Status
-- @comeFromContract TINYINT: indicates if the quote has a contract.
-- ===================================================================================================================================
-- Returns: 
-- comeFormContract: indicates if the quote has a contract.
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-11-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 11/25/2022
-- Description: sp_GetQuoteComesFromContract - Identifies if the quote has a contract
CREATE PROCEDURE sp_GetQuoteComesFromContract(
    @idQuote INT
)
AS
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @stauts TINYINT= 1;
    DECLARE @comeFromContract TINYINT;

    SELECT 
        @comeFromContract=
            CASE 
                WHEN COUNT(*) > 0 THEN 1
                ELSE 0
            END
    FROM ContractQuotes 
    WHERE 
        idQuote= @idQuote AND 
        [status]= @stauts


    SELECT 
        @comeFromContract AS comeFormContract,
        idContract 
    FROM ContractQuotes 
    WHERE 
    idQuote= @idQuote AND 
    [status]= @stauts

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
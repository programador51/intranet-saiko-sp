-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-24-2022
-- Description: Add the asociation of the movement to a informative income
-- STORED PROCEDURE NAME:	sp_AddInformativeIncomesAssociation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-03-24		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/24/2022
-- Description: sp_AddInformativeIncomesAssociation - Add the asociation of the movement to a informative income
CREATE PROCEDURE sp_AddInformativeIncomesAssociation(
    @applied DECIMAL (14,2),
    @creadeBy NVARCHAR(30),
    @idIncomes INT,
    @idMovement INT,
    @import DECIMAL (14,2),
    @lastUpdatedBy NVARCHAR(30),
    @tc DECIMAL (14,2)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    INSERT INTO UnbilledIncomes
        (
        applied ,
        createdBy ,
        idIncomes ,
        idMovement ,
        import ,
        lastUpdatedBy ,
        tc
        )
        
    VALUES
        (
            @applied,
            @creadeBy,
            @idIncomes,
            @idMovement,
            @import,
            @lastUpdatedBy,
            @tc
        )

END
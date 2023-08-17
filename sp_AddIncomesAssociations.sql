-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-01-2023
-- Description: Associate the movement for concpets
-- STORED PROCEDURE NAME:	sp_AddIncomesAssociations
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
--	2023-03-01		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/01/2023
-- Description: sp_AddIncomesAssociations - Associate the movement for concpets
CREATE PROCEDURE sp_AddIncomesAssociations(
    @idMovement INT,
    @idClient INT,
    @createdBy NVARCHAR(30),
    @concepts ConceptsAssociation READONLY
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    INSERT INTO ConceptAssociation (
        applied,
        createdBy,
        idConcept,
        idMovement,
        import,
        [status],
        lastUpdatedBy,
        tc
    )
    SELECT 
        amount,
        @createdBy,
        idConcept,
        @idMovement,
        amount,
        1,
        @createdBy,
        1
    FROM @concepts

END


-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------

SELECT * FROM ConceptAssociation
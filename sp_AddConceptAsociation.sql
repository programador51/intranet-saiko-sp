-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 02-22-2022
-- Description: Asocaite the movment to a Concept (egress or incomes)
-- STORED PROCEDURE NAME:	sp_AddConceptAsociation
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- createdBy: The user how create the record
-- conceptId: The concept id the movment is asociated
-- movementId:The movment id 
-- import: The total import of the movment asociated
-- ===================================================================================================================================
-- Returns
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-02-22		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 02/22/2022
-- Description: sp_AddConceptAsociation -Asocaite the movment to a Concept (egress or incomes)
-- =============================================
CREATE PROCEDURE sp_AddConceptAsociation
    (
    @createdBy NVARCHAR (30),
    @conceptId INT,
    @movementId INT,
    @import DECIMAL (14,4)
)

AS
BEGIN

    INSERT INTO ConceptsAssosations (
        createdBy,
        lastUpdateBy,
        conceptId,
        idMovment,
        import
)
    VALUES (
        @createdBy,
        @createdBy,
        @conceptId,
        @movementId,
        @import
    )


END
GO
-- ----------------- ↓↓↓ BLOCK OF CODE ↓↓↓ -----------------------
-- ----------------- ↑↑↑ BLOCK OF CODE ↑↑↑ -----------------------
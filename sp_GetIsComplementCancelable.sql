-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-08-2022
-- Description: check if the complement is cancelable
-- STORED PROCEDURE NAME:	sp_GetIsComplementCancelable
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @customerRFC: The RFC provider from the legal document
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @concilationArray: Array of id from the concilations
-- @idMovement: Movemnt id
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-09-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/08/2022
-- Description: sp_GetIsComplementCancelable - check if the complement is cancelable
CREATE PROCEDURE sp_GetIsComplementCancelable(
    @concilationArray NVARCHAR(MAX),
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @hasComplement BIT;
    DECLARE @isComplementCancelable BIT=0;
    DECLARE @ppdCount INT;
    DECLARE @complementStatus TINYINT;
    DECLARE @idCfdiComplement NVARCHAR(256)= NULL;
    DECLARE @uuidComplement NVARCHAR(256)= NULL;

    SELECT 
        @hasComplement= 
            CASE
                WHEN idPaymentPluginStatus = 2 THEN 1
                ELSE 0
            END
    FROM Movements
    WHERE MovementID=@idMovement AND [status] NOT IN(1,5);

    SELECT 
        @complementStatus=[status] 
    FROM Complements 
    WHERE idMovement=@idMovement AND [status]=1


    SELECT 
        @ppdCount=COUNT(*)
    FROM Documents WHERE uuid IN (
        SELECT 
            uuid
        FROM ConcilationCxC 
        WHERE id IN (SELECT CONVERT(INT,[value]) FROM string_split(@concilationArray,','))
        GROUP BY uuid
    ) AND idTypeDocument=2 AND idPaymentForm=1;


    IF (@ppdCount>0 AND @hasComplement=1 AND @complementStatus=1)
        BEGIN
            SET @isComplementCancelable=1;
            SELECT @idCfdiComplement= idCfdi,@uuidComplement=uuid FROM Complements WHERE idMovement=@idMovement
        END

    SELECT @isComplementCancelable AS isComplementCancelable, @idCfdiComplement AS idCfdi, @uuidComplement AS uuidComplement

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
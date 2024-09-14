-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-08-2024
-- Description: Get if a position can be canceled
-- STORED PROCEDURE NAME:	sp_GetCanCancelPosition
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idPosition INT - Id position
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @canCancel BIT - Can cancel
-- @positionHasOc BIT - Position has OC
-- @canCancelPosition BIT - Can cancel position
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2024-07-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCanCancelPosition')
    BEGIN 

        DROP PROCEDURE sp_GetCanCancelPosition;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/08/2024
-- Description: sp_GetCanCancelPosition - Get if a position can be canceled
CREATE PROCEDURE sp_GetCanCancelPosition(
    @idPosition INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @canCancel BIT = 0;
    DECLARE @positionHasOc BIT =0;
    DECLARE @positionHasRemisions BIT =0;
    DECLARE @canCancelPosition BIT = 0;
    SELECT 
        @canCancel= CASE 
            WHEN statusPosition = 'Terminado' THEN 0
            WHEN statusPosition = 'NoAsignado' THEN 0
            WHEN statusPosition = 'Cancelar' THEN 0
            ELSE 1
        END
    FROM PositionsProyects
    WHERE 
        id = @idPosition;

   PRINT('CAN CANCEL: ' + CAST(@canCancel AS VARCHAR));

    
    SELECT 
        @positionHasOc = CASE 
            WHEN COUNT(*)>0 THEN  1
            ELSE 0
        END
    FROM Documents
    WHERE 
        idPosition = @idPosition
        AND idTypeDocument = 3
        AND idStatus != 12;

        PRINT('HAS OC: ' + CAST(@positionHasOc AS VARCHAR));


    SELECT 
        @positionHasRemisions = CASE 
            WHEN COUNT(*)>0 THEN  1
            ELSE 0
        END
    FROM Documents
    WHERE 
        idPosition = @idPosition
        AND idTypeDocument = 2
        AND idStatus != 6;

        PRINT('HAS REMISION: ' + CAST(@positionHasRemisions AS VARCHAR));



    SELECT 
        @canCancelPosition= CASE 
            WHEN @positionHasOc = 0 AND @positionHasRemisions = 0 AND @canCancel = 1 THEN 1
            ELSE 0
        END;

        PRINT('HAS OC: ' + CAST(@canCancelPosition AS VARCHAR));


    SELECT @canCancelPosition as canCancelPosition


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
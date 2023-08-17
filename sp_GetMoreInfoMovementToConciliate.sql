-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-28-2022
-- Description: Get more info from the movements
-- STORED PROCEDURE NAME:	sp_GetMoreInfoMovementToConciliate
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
--	2022-09-28		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/28/2022
-- Description: sp_GetMoreInfoMovementToConciliate - Get more info from the movements
CREATE PROCEDURE sp_GetMoreInfoMovementToConciliate(
    @idMovement INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
    DECLARE @movementStatus INT;
    DECLARE @movementType INT;
    DECLARE @message NVARCHAR(128)='NO MESSAGE';

    SELECT 
        @movementStatus= [status], 
        @movementType = movementType
    FROM Movements 
    WHERE MovementID=@idMovement;


    IF(@movementStatus=1)
        BEGIN
            SET @message= 'Movimiento no asociado';
        END

    IF(@movementStatus=5)
        BEGIN
            SET @message= 'No aplica ingreso cancelado'
        END
    
    SELECT @message AS [message]
    IF(@movementType=1)
        BEGIN
            SELECT DISTINCT
                movement.MovementID,
                FORMAT(CAST(invoice.noDocument AS INT),'0000000') AS noDocument,
                invoice.currencyCode,
                dbo.FormatDate(invoice.emitedDate) AS emitedDate,
                CONCAT(cxc.currectFaction,'/',cxc.factionsNumber) AS fraction,
                dbo.FormatDate(invoice.expirationDate) AS expirationDate,
                dbo.fn_FormatCurrency(
                        (SELECT 
                        SUM(conciliation2.amountApplied)
                    FROM ConcilationCxC AS conciliation2
                    WHERE conciliation2.idMovement=conciliation.idMovement
                    )
                ) AS amount
            FROM ConcilationCxC AS conciliation
                LEFT JOIN LegalDocuments AS invoice ON invoice.uuid= conciliation.uuid
                LEFT JOIN Movements AS movement ON movement.MovementID= conciliation.idMovement
                LEFT JOIN Documents AS cxc ON cxc.idDocument= conciliation.idCxC
            WHERE movement.MovementID=@idMovement
        END
    ELSE
        BEGIN
            SELECT DISTINCT
                movement.MovementID,
                FORMAT(CAST(invoice.noDocument AS INT),'0000000') AS noDocument,
                invoice.currencyCode,
                invoice.emitedDate,
                CONCAT(cxp.currectFaction,'/',cxp.factionsNumber) AS fraction,
                invoice.expirationDate,
                dbo.fn_FormatCurrency(
                        (SELECT 
                        SUM(conciliation2.amountApplied)
                    FROM ConcilationCxC AS conciliation2
                    WHERE conciliation2.idMovement=conciliation.idMovement
                    )
                ) AS amount
            FROM ConcilationCxP AS conciliation
                LEFT JOIN LegalDocuments AS invoice ON invoice.uuid= conciliation.uuid
                LEFT JOIN Movements AS movement ON movement.MovementID= conciliation.idMovement
                LEFT JOIN Documents AS cxp ON cxp.idDocument= conciliation.idCxP
            WHERE movement.MovementID=@idMovement
        END

        

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
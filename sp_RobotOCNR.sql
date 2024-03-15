-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 10-12-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_RobotOCNR
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
--	2023-10-12		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 10/12/2023
-- Description: sp_RobotOCNR - Some Notes
CREATE PROCEDURE sp_RobotOCNR AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @beginDate DATE;
    DECLARE @endDate DATE;
    DECLARE @odcStatus INT= 10;

    DECLARE @subTotalMxn DECIMAL(14,4);
    DECLARE @subTotalUsd DECIMAL(14,4);
    DECLARE @tc DECIMAL(14,4);
    DECLARE @createdBy NVARCHAR(30)='SISTEMA'

    SELECT @tc=purchase 
    FROM TCP 
    WHERE id =(SELECT TOP(1) id - 1 FROM TCP ORDER BY id DESC)

    DECLARE @idSumarry INT;

    SELECT 
        @beginDate = DATEADD(DAY, 1, EOMONTH(GETUTCDATE(), -1)),
        @endDate= CAST(EOMONTH(GETUTCDATE()) AS DATE)


    SELECT 
        @subTotalUsd=SUM(calculationCostSubtotal)
    FROM DocumentItems
    WHERE 
        currency='USD' AND
        document IN (
            SELECT 
                idDocument
            FROM Documents 
            WHERE 
                idTypeDocument= 3 AND
                idStatus= @odcStatus AND
                (createdDate >= @beginDate AND createdDate <= @endDate)
        )
    SELECT 
        @subTotalMxn=SUM(calculationCostImport + calculationCostIva)
    FROM DocumentItems
    WHERE 
        currency='MXN' AND
        document IN (
            SELECT 
                idDocument
            FROM Documents 
            WHERE 
                idTypeDocument= 3 AND
                idStatus= @odcStatus AND
                (createdDate >= @beginDate AND createdDate <= @endDate)
        )
    INSERT INTO SummaryOCNR (
        recordDate,
        mxnTotal,
        usdTotal,
        tc,
        createdBy,
        updatedBy
    ) VALUES (
        CAST(GETUTCDATE() AS DATE),
        ISNULL(@subTotalMxn,0),
        ISNULL(@subTotalUsd,0),
        @tc,
        @createdBy,
        @createdBy

    );
    SELECT @idSumarry= SCOPE_IDENTITY();
    INSERT INTO DetailOCNR (
        idOdc,
        idSummary,
        createdBy,
        updatedBy
    )
    SELECT 
        idDocument,
        @idSumarry,
        @createdBy,
        @createdBy
    FROM Documents 
    WHERE 
        idTypeDocument= 3 AND
        idStatus= @odcStatus AND
        (createdDate >= @beginDate AND createdDate <= @endDate)

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
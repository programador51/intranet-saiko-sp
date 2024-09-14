-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 05-20-2022
-- Description: Add log error.
-- STORED PROCEDURE NAME:	sp_AddLog
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @createdBy: User who tryy to create the record
-- @error: Error message
-- @infoSended: Info that was try to send to the database
-- @mustBeSyncManually: Indicates if we must syync manually
-- @provider: The error provider where the errors occurs
-- @responseReceived: The response recive
-- @wasAnError: Indicartes if it was an error.
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
--	2022-05-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 05/20/2022
-- Description: sp_AddLog - Add log error
CREATE PROCEDURE sp_AddLog(
    @createdBy NVARCHAR(30),
    @error NVARCHAR(MAX),
    @infoSended NVARCHAR(MAX),
    @mustBeSyncManually TINYINT,
    @provider INT,
    @responseReceived NVARCHAR(MAX),
    @wasAnError TINYINT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    INSERT INTO Logs (
        createdBy,
        error,
        infoSended,
        mustBeSyncManually,
        [provider],
        responseReceived,
        wasAnError
    )

    VALUES (
        @createdBy,
        @error,
        @infoSended,
        @mustBeSyncManually,
        @provider,
        @responseReceived,
        @wasAnError
    )

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
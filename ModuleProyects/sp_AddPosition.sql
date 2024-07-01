-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-04-2024
-- Description: add a new position
-- STORED PROCEDURE NAME:	sp_AddPosition
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @description: The description of the position
-- @pos: The position
-- @laborCost: The labor cost
-- @laborSell: The labor sell
-- @material: The material
-- @ocCustomer: The OC customer
-- @percentageOfCompletion: The percentage of completion
-- @quantity: The quantity
-- @status: The status
-- @subPos: The sub position
-- @umSat: The UM SAT
-- @idProject: The id project
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
--	2024-06-04		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddPosition')
    BEGIN 

        DROP PROCEDURE sp_AddPosition;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/04/2024
-- Description: sp_AddPosition - add a new position
CREATE PROCEDURE sp_AddPosition
(
    @description NVARCHAR(MAX),
    @pos NVARCHAR(256),
    @cost DECIMAL(18, 2),
    @sell DECIMAL(18, 2),
    @ivaCostRate INT,
    @ivaSellRate INT,
    @ocCustomer NVARCHAR(256),
    @percentageOfCompletion DECIMAL(5, 2),
    @idProject INT,
    @createdBy NVARCHAR(256),
    @updatedBy NVARCHAR(256),
    @idUen INT,
    @staKey NVARCHAR(256),
    @staDescription NVARCHAR(256),
    @um NVARCHAR(256),
    @umDescription NVARCHAR(256)
)
AS 
BEGIN
    SET LANGUAGE Spanish;
    SET NOCOUNT ON;
    DECLARE @tranName NVARCHAR(50) = 'addPosition';
    DECLARE @trancount INT;
    DECLARE @status NVARCHAR(50) = 'Activo';
    SET @trancount = @@trancount;
    BEGIN TRY
        IF (@trancount = 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName;
            END

        INSERT INTO PositionsProyects(
            [description],
            pos,
            ocCustomer,
            percentageOfCompletion,
            [status],
            idProject,
            createdBy,
            updatedBy,
            cost,
            sell,
            ivaCostRate,
            ivaSellRate,
            idUen,
            staKey,
            staDescription,
            um,
            umDescription
            )
        VALUES (
            @description,
            @pos,
            @ocCustomer,
            @percentageOfCompletion,
            @status,
            @idProject,
            @createdBy,
            @updatedBy,
            @cost,
            @sell,
            @ivaCostRate,
            @ivaSellRate,
            @idUen,
            @staKey,
            @staDescription,
            @um,
            @umDescription

        )
        SELECT SCOPE_IDENTITY() AS idPosition;

        IF (@trancount = 0)
            BEGIN
                COMMIT TRANSACTION @tranName;
            END
    END TRY
    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)
        DECLARE @xstate INT= XACT_STATE();

        DECLARE @infoSended NVARCHAR(MAX)= 'Sin informacion por el momento';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (@xstate= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (@xstate=1 AND @trancount=0)
            BEGIN
                -- COMMIT TRANSACTION @tranName
                ROLLBACK TRANSACTION @tranName
            END

        IF (@xstate=1 AND @trancount > 0)
            BEGIN
                ROLLBACK TRANSACTION @tranName;
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;
    END CATCH
END;
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-26-2022
-- Description: Add the new tc every day
-- STORED PROCEDURE NAME:	sp_AddTc
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @fix: FIX
-- @dof: DOF
-- @pays: Pay
-- @purchase: Purchase
-- @sales: Sales
-- @saiko: Company TC
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
--	2022-04-26		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/26/2022
-- Description: sp_AddTc - Add the new tc every day
CREATE PROCEDURE sp_AddTc(
    @fix DECIMAL,
    @dof FLOAT,
    @pays FLOAT,
    @purchase FLOAT,
    @sales FLOAT,
    @saiko FLOAT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    
DECLARE @tranName NVARCHAR(30) ='AddTC';
DECLARE @idNoteCondition INT;

DECLARE @ErrorOccurred TINYINT;
DECLARE @Message NVARCHAR (256);
DECLARE @CodeNumber INT;

BEGIN TRY
    BEGIN TRANSACTION @tranName

        INSERT INTO TCP (
            [date],
            fix,
            DOF,
            pays,
            purchase,
            sales,
            saiko

        )
        VALUES (
            dbo.fn_MexicoLocalTime(GETDATE()),
            @fix,
            @dof,
            @pays,
            @purchase,
            @sales,
            @saiko
        )

            IF @@ERROR <>0
            BEGIN
                SET @ErrorOccurred= 1 -- Significa que fallo
                SELECT @Message= text FROM sys.messages WHERE message_id=@@ERROR
                SET @CodeNumber= @@ERROR
                ROLLBACK TRANSACTION @tranName
            END
        ELSE
            BEGIN
                SET @ErrorOccurred= 0
                SET @Message='Registros insertados correctamente'
                SET @CodeNumber= 200
                COMMIT TRANSACTION @tranName
            END

        SELECT @ErrorOccurred AS ErrorOccurred, @Message AS [Message], @CodeNumber AS CodeNumber
    END TRY

    BEGIN CATCH
        IF (XACT_STATE()= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (XACT_STATE()=1)
            BEGIN
                COMMIT TRANSACTION @tranName
            END

        IF @@TRANCOUNT > 0  
            BEGIN
                ROLLBACK TRANSACTION;   
            END
        SELECT 
            1 AS ErrorOccurred, 
            'Problemas con la Base de datos, no se pudo insertar los registros' AS [Message],
            ERROR_NUMBER() AS CodeNumber
    END CATCH

END
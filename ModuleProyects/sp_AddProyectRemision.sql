-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-25-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddProyectRemision
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
--	2024-07-25		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_AddProyectRemision')
    BEGIN 

        DROP PROCEDURE sp_AddProyectRemision;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/25/2024
-- Description: sp_AddProyectRemision - Some Notes
CREATE PROCEDURE sp_AddProyectRemision(
    @idPosition INT,
    @subTotal DECIMAL(14,4),
    @createdBy NVARCHAR(30),
    @idExecutive INT

) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    
    DECLARE @tranName NVARCHAR(50) = 'addRemisionProyects';
    DECLARE @trancount INT;
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
        DECLARE @tc DECIMAL(14,4) = 20;

        DECLARE @idProyect INT;
        DECLARE @idCustomer INT;

        DECLARE @idTypeDocument INT = 2;
        DECLARE @idStatus INT = 4;
        DECLARE @iva DECIMAL(14,4);
        DECLARE @idCurrency INT = 1;
        DECLARE @acreditedAmount DECIMAL(14,4)=0;
        DECLARE @ivaAmount DECIMAL(14,4);
        DECLARE @totalAmount DECIMAL(14,4);

        DECLARE @initialDate DATETIME = GETUTCDATE();
        DECLARE @expirationDate DATETIME = EOMONTH(@initialDate);
        DECLARE @reminderDate DATETIME = DATEADD(DAY, (DAY(EOMONTH(@initialDate))/2), EOMONTH(@initialDate, -1));
        
        DECLARE @remisionNumber INT;
        EXEC @remisionNumber = fn_getFolioV2 'pedido'

        SELECT 
            @iva = ivaSellRate,
            @idProyect = idProject
        FROM PositionsProyects 
        WHERE id = @idPosition;

        SELECT 
            @idCustomer = idClient
        FROM Proyects 
        WHERE id = @idProyect;
        
        SET @ivaAmount = @subTotal * @iva /100;
        SET @totalAmount = @subTotal + @ivaAmount;

        

    INSERT INTO Documents (
        amountToBeCredited,
        amountToPay,
        createdBy,
        expirationDate,
        idCurrency,
        idCustomer,
        idExecutive,
        idStatus,
        idTypeDocument,
        ivaAmount,
        lastUpdatedBy,
        protected,
        reminderDate,
        subTotalAmount,
        totalAcreditedAmount,
        totalAmount,
        initialDate,
        idPosition,
        UEN,
        documentNumber
    )
    VALUES (
        @totalAmount,
        @totalAmount,
        @createdBy,
        @expirationDate,
        @idCurrency,
        @idCustomer,
        @idExecutive,
        @idStatus,
        @idTypeDocument,
        @ivaAmount,
        @createdBy,
        @tc,
        @reminderDate,
        @subTotal,
        @acreditedAmount,
        @totalAmount,
        @initialDate,
        @idPosition,
        1,
        @remisionNumber
    )


    SELECT SCOPE_IDENTITY() AS idRemision;

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

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
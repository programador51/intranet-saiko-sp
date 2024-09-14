-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-26-2022
-- Description: Close period
-- STORED PROCEDURE NAME:	sp_AddClosePeriod
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
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
--	2022-09-26		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/26/2022
-- Description: sp_AddClosePeriod - Close period
CREATE PROCEDURE sp_AddClosePeriod(
    @currentBankAmount INT,
    @idAccount INT,
    @date DATETIME,
    @createdBy NVARCHAR(30)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @tranName NVARCHAR(50)='closePeriod';

    DECLARE @validDate BIT;
    DECLARE @movementsAreAvalible  BIT;
    DECLARE @ceroMovements BIT;


    DECLARE @beginDate DATETIME; -- FECHA INICIAL DEL FILTRO
    DECLARE @endDate DATETIME; -- FECHA FINAL DEL FILTRO

    DECLARE @errorMessage NVARCHAR(MAX)='';
    DECLARE @currentlKey NVARCHAR(6);
    DECLARE @key NVARCHAR(6);
    DECLARE @newKey NVARCHAR(6);

    DECLARE @newAmount DECIMAL (14,2)=0;
    DECLARE @currentAmount DECIMAL (14,2);

    BEGIN TRY
        BEGIN TRANSACTION @tranName;

        -- Validamos que la fecha actual sea valida.
        SELECT 
            @validDate=
            CASE 
                WHEN @date >= EOMONTH(GETUTCDATE()) THEN 1
                ELSE 0
            END;

        IF(@validDate=1)
            BEGIN 
                -- Se continua con el proceso de validación.
                SELECT @currentlKey= YEAR(@date) + MONTH(@date);
                IF EXISTS (SELECT [key] FROM MonthConsilation WHERE [key]=@currentlKey AND idAccount=@idAccount)
                    BEGIN
                        --SIGNIFICA QUE EL MES ANTERIOR SI ESTA CERRADO
                        SELECT @currentAmount = [amount] FROM MonthConsilation WHERE [key]=@currentlKey AND idAccount=@idAccount
                        SELECT 
                            @beginDate= DATEADD(DAY,1,EOMONTH(@date,-1)),
                            @endDate= EOMONTH(@date);

                        SELECT -- Busca si existen moviminetos
                            @ceroMovements= 
                                CASE
                                    WHEN COUNT(*) =0 THEN 1 -- No tiene moviminetos
                                    ELSE 0 -- Si tiene moviminetos
                                END 
                        FROM Movements 
                        WHERE 
                            movementDate>= @beginDate AND 
                            movementDate<= @endDate AND 
                            bankAccount=@idAccount

                        IF(@ceroMovements=0)
                            BEGIN
                                -- SIGNIFICA QUE EXISTE ALMENOS UN MOVIMIENTO
                                -------------    
                                SELECT -- Busca moviminetos que esten en proceso o activos, si encunetra almenos uno no puede cerrar
                                    @movementsAreAvalible= 
                                        CASE
                                            WHEN COUNT(*) >0 THEN 0
                                            ELSE 1
                                        END 
                                FROM Movements 
                                WHERE 
                                    movementDate>= @beginDate AND 
                                    movementDate<= @endDate AND 
                                    bankAccount=@idAccount AND
                                    [status] IN (1,2) 
                                
                                IF(@movementsAreAvalible=1)
                                    BEGIN 
                                            --LOS MOVIMIENTOS ESTAN EN ORDEN, FALTA REVISAR SI EL SALDO ES EL ADECUADO
                                            SELECT 
                                                @newAmount= 
                                                    CASE
                                                        WHEN movementType=1 THEN @newAmount + amount
                                                        ELSE @newAmount - amount
                                                    END
                                            FROM Movements 
                                            WHERE 
                                                movementDate>= @beginDate AND 
                                                movementDate<= @endDate AND 
                                                bankAccount=@idAccount AND
                                                [status] NOT IN(1,2,5);
                                            
                                            SET @newAmount += @currentAmount 
                                            IF(@newAmount =@currentBankAmount)
                                                BEGIN
                                                    SELECT @key = CONCAT(YEAR(@date),MONTH(@date)+1)
                                                    -- SE CONCILIA
                                                    INSERT INTO MonthConsilation (
                                                        [key],
                                                        amount,
                                                        createdBy,
                                                        idAccount,
                                                        lastUpdatedBy
                                                    )
                                                    VALUES(
                                                        @key,
                                                        @newAmount,
                                                        @createdBy,
                                                        @idAccount,
                                                        @createdBy
                                                    )
                                                    UPDATE Movements SET
                                                        [status]=6,
                                                        lastUpdatedBy=@createdBy,
                                                        lastUpdatedDate=GETUTCDATE()
                                                        
                                                    WHERE
                                                        movementDate>= @beginDate AND 
                                                        movementDate<= @endDate AND 
                                                        bankAccount=@idAccount AND
                                                        [status] NOT IN(1,2,5);
                                                END
                                            ELSE
                                                BEGIN 
                                                    SET @errorMessage += 'No se puede cerrar el mes, existe una diferencia de ' + (@currentBankAmount - @newAmount) + '.'+ CHAR(10) + CHAR(13)
                                                END
                                    END
                                ELSE
                                    BEGIN
                                        SET @errorMessage += 'No pudes cerrar el mes, existen movimientos activos o en proceso.'+ CHAR(10) + CHAR(13)
                                    END

                            END
                        ELSE
                            BEGIN
                                -- SI SE PERMITE CERRAR EL MES, CON EL SALDO ANTERIOR.
                                PRINT('CERRAR MES');
                                SELECT @key = CONCAT(YEAR(@date),MONTH(@date)+1)
                                -- SE CONCILIA
                                INSERT INTO MonthConsilation (
                                    [key],
                                    amount,
                                    createdBy,
                                    idAccount,
                                    lastUpdatedBy
                                )
                                VALUES(
                                    @key,
                                    @currentBankAmount,
                                    @createdBy,
                                    @idAccount,
                                    @createdBy
                                )
                            END


                    END
                ELSE
                    BEGIN
                        SET @errorMessage += 'El periodo anteorior no ha sido conciliado-cerrado.'+ CHAR(10) + CHAR(13)
                    END

            END
        ELSE
            BEGIN
                SET @errorMessage += 'La fecha para cerrar el mes no es valida.'+ CHAR(10) + CHAR(13)
            END

        SELECT @errorMessage AS error 
        COMMIT TRANSACTION @tranName;

    END TRY

    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)

        DECLARE @infoSended NVARCHAR(MAX)= 'Informacion que se trato de enviar en orden para el SP sp_AddClosePeriod,
            @currentBankAmount
            @idAccount
            @date';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
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
                ROLLBACK TRANSACTION @tranName;   
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------


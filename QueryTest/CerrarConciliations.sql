DECLARE @currentBankAmount DECIMAL (14,2);
DECLARE @idAccount INT;


DECLARE @validDate BIT;

DECLARE @date DATETIME; -- LA FEHCA QUE SE QUIERE CERRAR
DECLARE @beginDate DATETIME; -- FECHA INICIAL DEL FILTRO
DECLARE @endDate DATETIME; -- FECHA FINAL DEL FILTRO
DECLARE @currentlKey NVARCHAR(6);
DECLARE @key NVARCHAR(6);
DECLARE @newKey NVARCHAR(6);
DECLARE @createdBy NVARCHAR(30);
DECLARE @newAmount DECIMAL (14,2)=0;
DECLARE @currentAmount DECIMAL (14,2);
DECLARE @errorMessage NVARCHAR(MAX)='';

DECLARE @movementsAreAvalible  BIT;
DECLARE @ceroMovements BIT;

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
                                            SELECT @key = FORMAT(CONCAT(YEAR(@date),MONTH(@date)+1),'000000');
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
                                                [status]=6
                                            WHERE
                                                movementDate>= @beginDate AND 
                                                movementDate<= @endDate AND 
                                                bankAccount=@idAccount AND
                                                [status] NOT IN(1,2,5);
                                        END
                                    ELSE
                                        BEGIN 
                                            SET @errorMessage += 'No se puede cerrar el mes, existe una diferencia de ' + (@currentBankAmount - @newAmount) + '.'+ char(10) + char(13)
                                        END
                            END
                        ELSE
                            BEGIN
                                SET @errorMessage += 'No pudes cerrar el mes, existen movimientos activos o en proceso.'+ char(10) + char(13)
                            END

                    END
                ELSE
                    BEGIN
                        -- SI SE PERMITE CERRAR EL MES, CON EL SALDO ANTERIOR.
                        PRINT('CERRAR MES');
                        SELECT @key = FORMAT(CONCAT(YEAR(@date),MONTH(@date)+1),'000000');
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
                SET @errorMessage += 'El periodo anteorior no ha sido conciliado-cerrado.'+ char(10) + char(13)
            END

    END
ELSE
    BEGIN
        SET @errorMessage += 'La fecha para cerrar el mes no es valida.'+ char(10) + char(13)
    END

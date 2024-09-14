    
    DECLARE @currentBankAmount INT
    DECLARE @idAccount INT
    DECLARE @date DATETIME
    DECLARE @createdBy NVARCHAR(30)
    
    
    DECLARE @tranName NVARCHAR(50)='closePeriod';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;



    DECLARE @errorMessage NVARCHAR(MAX)='';
    DECLARE @previusKey NVARCHAR(6);
    DECLARE @key NVARCHAR(6);

    DECLARE @currentDate DATETIME;

    SELECT @currentDate = GETUTCDATE();

    DECLARE @newAmount DECIMAL (14,2)=0;
    DECLARE @currentAmount DECIMAL (14,2);



    DECLARE @newKeyYear NVARCHAR(4);
    DECLARE @newKeyMonth NVARCHAR(2);

    DECLARE @prevKeyYear NVARCHAR(4);
    DECLARE @prevKeyMonth NVARCHAR(2);

     IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName
            END

    SELECT @newKeyYear= 
        CASE 
            WHEN MONTH(@currentDate)-1<=0  THEN YEAR(@currentDate) -1 
            ELSE YEAR(@currentDate) 
        END 
    SELECT @newKeyMonth= 
        CASE 
            WHEN MONTH(@currentDate)-1<=0  THEN MONTH(@currentDate) +12 
            WHEN MONTH(@currentDate)-1 <10 THEN CONCAT('0',MONTH(@currentDate)-1 )
            ELSE MONTH(@currentDate)-1 
        END 
    SELECT @prevKeyYear= 
        CASE 
            WHEN MONTH(@currentDate)-2<=0  THEN YEAR(@currentDate) -1 
            ELSE YEAR(@currentDate) 
        END 
     SELECT @prevKeyMonth= 
        CASE 
            WHEN MONTH(@currentDate)-2<=0  THEN MONTH(@currentDate) +12 
            WHEN MONTH(@currentDate)-2 <10 THEN CONCAT('0',MONTH(@currentDate)-2 )
            ELSE MONTH(@currentDate)-2 
        END 
    


    -- La llave del mes que se va a conciliar es igual a la fecha inmediata anteriror del mes (hoy abril ayer marzo:se concilia marzo).
    SELECT @key= CONCAT(@newKeyYear,@newKeyMonth);

    --La llave del mes anterior que se supone esta conciliado (si es que existe, si no existe significa que no se puede conciliar el mes)
    SELECT @previusKey= CONCAT(@prevKeyYear,@prevKeyMonth);

       

            -- Si existe la key del mes anterior, significa que no puede cerrar el mes
        IF EXISTS (SELECT [key] FROM MonthConsilation WHERE [key] =@previusKey AND idAccount=@idAccount)
            BEGIN
                IF NOT EXISTS (SELECT [key] FROM MonthConsilation WHERE [key] = @key AND idAccount=@idAccount)
                    BEGIN
                        PRINT('El PERIODO ACTUAL NO HA SIDO CERRADO');
                        SELECT @currentAmount = amount  FROM MonthConsilation WHERE [key] = @previusKey AND idAccount=@idAccount
                        SELECT @currentAmount= @currentAmount + SUM(
                            CASE 
                                WHEN movementType=2 THEN amount * -1
                                ELSE amount
                            END
                        ) FROM Movements WHERE [status] IN (6,3)

                    IF(@currentAmount =@currentBankAmount)
                        BEGIN
                            PRINT('SE TRATA DE CERRAR EL PERIODO');
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
                                bankAccount=@idAccount AND
                                [status] =3;
                        END
                    ELSE
                        BEGIN
                            PRINT('NO SE PUDO CERRAR EL PERIODO. HAY DIFERENCIA EN EL SALDO');
                            PRINT('CURRENT BANK: '+ CAST(@currentBankAmount AS NVARCHAR));
                            PRINT('NEW SALDO: '+ CAST(@newAmount AS NVARCHAR));
                            SET @errorMessage += 'No se puede cerrar el mes, existe una diferencia de ' + CAST((@currentBankAmount - @newAmount) AS nvarchar) + '.'+ CHAR(10) + CHAR(13);
                            THROW 51000, @errorMessage,1;
                        
                        END

                    END
                ELSE
                    BEGIN
                        ;THROW 51000, 'El mes actual ya fue cerrado, no se puede volver a cerrar.',1;
                    END

            END
        ELSE
            BEGIN
                PRINT('EL PERIODO ANTERIOR NO HA SIDO CERRADO');
                THROW 51000, 'El periodo anterior no ha sido cerrado o el periodo actual ya fue cerrado. Para cerrar este periódo debes hacer los anteriores y revisar el estatus de los movimientos',1;
            END


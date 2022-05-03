--? VARIABLES GLOBALES
DECLARE @idContact INT = 999;
DECLARE @idTypeDocument INT = 1;
DECLARE @idCurrency INT = 1;
DECLARE @tc DECIMAL (14,2)= 20.21;
DECLARE @expirationDate DATETIME ='2022-12-12';
DECLARE @reminderDate DATETIME ='2022-12-01';
DECLARE @idProbability INT = 1
DECLARE @creditDays INT= 30
DECLARE @subtotal DECIMAL (14,4)= 500.00
DECLARE @iva DECIMAL (14,4)= 50.00
DECLARE @totalAmount DECIMAL (14,4)= 550.00
DECLARE @createdBy NVARCHAR (30)= 'Adrian Alardin Iracheta'
DECLARE @idCustomer INT = 63
DECLARE @idStatus INT = 1
DECLARE @idExecutive INT = 20
DECLARE @autorizationFlag INT = 1

DECLARE @idPeriocityType INT = 1
DECLARE @periocityValue INT = 3

--* VARIABLES LOCALES
DECLARE @idDocument INT

DECLARE @tranName NVARCHAR(30) ='addQuote';
DECLARE @tranName2 NVARCHAR(30) ='addNotes';
DECLARE @ErrorOccurred TINYINT;
DECLARE @Message NVARCHAR (256);
DECLARE @CodeNumber INT;

BEGIN TRY
    BEGIN TRANSACTION @tranName

    INSERT INTO Documents (
    idTypeDocument,
    idCustomer,
    idExecutive,
    idContact,
    idCurrency,
    protected,
    expirationDate,
    reminderDate,
    idProbability,
    creditDays,
    createdBy,
    lastUpdatedBy,
    totalAmount,
    subTotalAmount,
    ivaAmount,
    documentNumber,
    authorizationFlag,
    createdDate,
    idStatus

    ) VALUES (
        @idTypeDocument,
        @idCustomer,
        @idExecutive,
        @idContact,
        @idCurrency,
        @tc,
        @expirationDate,
        @reminderDate,
        @idProbability,
        @creditDays,
        @createdBy,
        @createdBy,
        @totalAmount,
        @subtotal,
        @iva,
        dbo.fn_NextDocumentNumber(@idTypeDocument),
        @autorizationFlag, -- authorization flag
        dbo.fn_MexicoLocalTime(GETDATE()),
        @idStatus
    )

    IF (@@ERROR <>0 AND @@ROWCOUNT <= 0)
        BEGIN
            SET @ErrorOccurred= 1 -- Significa que fallo
            SELECT @Message= text FROM sys.messages WHERE message_id=@@ERROR
            SET @CodeNumber= @@ERROR
            ROLLBACK TRANSACTION @tranName
        END
    ELSE
        BEGIN
            IF (@idPeriocityType IS NOT NULL AND @periocityValue IS NOT NULL)
                BEGIN
                    BEGIN TRANSACTION @tranName2
                    SELECT @idDocument= SCOPE_IDENTITY()
                    INSERT INTO Periocity (
                        createdBy,
                        idDocument,
                        idPeriocityType,
                        lastUpdatedBy,
                        [value]
                    )
                    VALUES (
                        @createdBy,
                        @idDocument,
                        @idPeriocityType,
                        @createdBy,
                        @periocityValue
                    )
                    IF (@@ERROR <>0 AND @@ROWCOUNT <= 0)
                        BEGIN
                            SET @ErrorOccurred= 1 -- Significa que fallo
                            SELECT @Message= text FROM sys.messages WHERE message_id=@@ERROR
                            SET @CodeNumber= @@ERROR
                            ROLLBACK TRANSACTION @tranName2
                        END
                    ELSE
                        BEGIN
                            SET @ErrorOccurred= 0
                            SET @Message='Registros insertados correctamente'
                            SET @CodeNumber= 200
                            COMMIT TRANSACTION @tranName2
                        END
                END
            
            SET @ErrorOccurred= 0
            SET @Message='Registros insertados correctamente'
            SET @CodeNumber= 200
            COMMIT TRANSACTION @tranName2
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
        ERROR_NUMBER() AS CodeNumber,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH

-- SELECT * FROM Documents WHERE createdBy= 'Adrian Alardin Iracheta' AND idTypeDocument=1 AND idContact=999 ORDER BY idDocument
-- SELECT * FROM Periocity ORDER BY id
-- DELETE FROM Documents WHERE idDocument IN (176,177,178,179)
-- DELETE FROM Periocity WHERE id IN (2,3,4)
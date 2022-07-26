
DECLARE @birthDay DATETIME;
DECLARE @createdBy NVARCHAR(30);
DECLARE @directChiefId INT;
DECLARE @email NVARCHAR(50);
DECLARE @ladaMovil NVARCHAR(10);
DECLARE @lastName1 NVARCHAR(30);
DECLARE @lastName2 NVARCHAR(30);
DECLARE @middleName NVARCHAR(30);
DECLARE @movil NVARCHAR(30);
DECLARE @name NVARCHAR(30);
DECLARE @password NVARCHAR(300);
DECLARE @rolId INT;
DECLARE @tempPassword NVARCHAR(300);
DECLARE @userName NVARCHAR(50);
-------------------------------------------------
DECLARE @tranName NVARCHAR(30)= 'AddUser'
DECLARE @day TINYINT;
DECLARE @month TINYINT;
DECLARE @year CHAR(4);
DECLARE @fullName NVARCHAR (256);

DECLARE @ErrorOccurred TINYINT=0

BEGIN TRY
    BEGIN TRANSACTION @tranName
    SELECT 
        @day= DAY(@birthDay),
        @month= MONTH(@birthDay),
        @year= CAST(YEAR(@birthDay) AS CHAR(4)),
        @fullName= CONCAT(@name,' ',@lastName1,' ',@lastName2);

    INSERT INTO Users (
                userName,
                temporalPassword,
                [password],
                email,
                initials,
                firstName,
                middleName,
                lastName1,
                lastName2,
                birthDay,
                birthMonth,
                birthYear,
                rol,
                [status],
                createdBy,
                createdDate,
                lastUpdatedBy,
                lastUpdatedDate,
                chiefId,
                movil,
                ladaMovil
            )
            VALUES (
                @userName,
                @tempPassword,
                @password,
                @email,
                dbo.fn_initialsName(@fullName),
                @name,
                @middleName,
                @lastName1,
                @lastName2,
                @day,
                @month,
                @year,
                @rolId,
                1,
                @createdBy,
                dbo.fn_MexicoLocalTime(GETDATE()),
                @createdBy,
                dbo.fn_MexicoLocalTime(GETDATE()),
                @directChiefId,
                @movil,
                @ladaMovil
            )
        COMMIT TRANSACTION @tranName
    END TRY
    BEGIN CATCH
        SET @ErrorOccurred=1;
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()

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
         IF ERROR_NUMBER()=547
            BEGIN
                SELECT 1 AS ErrorOccurred,
                ERROR_NUMBER() AS CodeNumber,
                'El usurio ya fue previamente registrado (Nombre de usuario o correo)' AS [Message]
            END
        ELSE
            BEGIN
                SELECT 1 AS ErrorOccurred,
                ERROR_NUMBER() AS CodeNumber,
                'Hubo un problema al crear el usuario' AS [Message]
            END

    END CATCH

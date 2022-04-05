--? Global variables
DECLARE @name NVARCHAR(30)='Name'
DECLARE @middleName NVARCHAR(30)='Middle'
DECLARE @lastName1 NVARCHAR(30)='Last1'
DECLARE @lastName2 NVARCHAR(30)='Last2'
DECLARE @email NVARCHAR(50)='email@email3.com'
DECLARE @userName NVARCHAR(50)='username'
DECLARE @tempPassword NVARCHAR(300)='$2a$10$quWg3fZEMM.5XclGo89NkuCiPoBlnXT..PWNXQyzrnTkFNoaMxRTC'
DECLARE @password NVARCHAR(300)='$2a$10$jghXmWwvHqdsglXlKNheH.uIsecj4OOsfqYZciiGFj4PcDIMe9GHi'
DECLARE @birthDay DATETIME = dbo.fn_MexicoLocalTime(GETDATE())
DECLARE @directChiefId INT = 100
DECLARE @rolId INT = 100
DECLARE @createdBy NVARCHAR(30)='Adrian Alardin Iracheta'

BEGIN TRY

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
        --* Variables locales
    DECLARE @day TINYINT;
    DECLARE @month TINYINT;
    DECLARE @year CHAR(4);
    DECLARE @fullName NVARCHAR (256);
    DECLARE @tranName NVARCHAR(30)= 'TranAddUser'
    DECLARE @ErrorOccurred TINYINT=0
    DECLARE @trancount  INT

    SET @trancount= @@TRANCOUNT

    SELECT 
        @day= DAY(@birthDay),
        @month= MONTH(@birthDay),
        @year= CAST(YEAR(@birthDay) AS CHAR(4)),
        @fullName= CONCAT(@name,' ',@lastName1,' ',@lastName2)
        
        IF @trancount= 0
            BEGIN TRANSACTION @tranName
        ELSE
            SAVE TRANSACTION sp_AddUserV2

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
                chiefId
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
                @directChiefId
            )

            IF @@ERROR> 0
                BEGIN
                    SET @ErrorOccurred= 1 -- Significa que fallo
                    ROLLBACK TRANSACTION @tranName
                END
            ELSE
                BEGIN
                    IF @@TRANCOUNT = 0	
                        SET @ErrorOccurred= 0 -- significa que no fallo
                        COMMIT;
                    -- COMMIT TRANSACTION @tranName
                END
            -- RETURN @ErrorOccurred
            SELECT 
                @ErrorOccurred AS ErrorOccurred,
                CASE 
                    WHEN @ErrorOccurred = 0 THEN 'Usuario creado correctamente'
                    ELSE 'No se pudo crear el usuario, intente mas tarde'
                END AS [Message],
                CASE 
                    WHEN @ErrorOccurred = 0 THEN 200
                    ELSE 500
                END AS CodeNumber
    END TRY
    BEGIN CATCH
    DECLARE @xstate INT
    SELECT @xstate= XACT_STATE();
        IF @xstate = -1
			rollback;
		IF @xstate = 1 and @trancount = 0
			rollback
		IF @xstate = 1 and @trancount > 0
			rollback transaction sp_AddUserV2;
        IF ERROR_NUMBER()=547
            BEGIN
                SELECT 1 AS ErrorOccurred,
                ERROR_NUMBER() AS CodeNumber,
                'El usurio ya fue previamente registrado (Nombre de usuario o correo)' AS Message
            END
        ELSE
            BEGIN
                SELECT 1 AS ErrorOccurred,
                ERROR_NUMBER() AS CodeNumber,
                'Hubo un problema al crear el usuario' AS Message
            END
    END CATCH

SELECT * FROM Users ORDER BY userID DESC
-- DELETE FROM Users WHERE userID=134

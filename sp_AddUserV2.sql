-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-01-2022
-- Description: Craete a new User
-- STORED PROCEDURE NAME:	sp_AddUserV2
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @name: The first name
-- @middleName: The middle name
-- @lastName1: The father's last name
-- @lastName2: The mother´s last name
-- @email: Email adress
-- @userName: User name
-- @tempPassword: Temporal password
-- @password: actual password
-- @birthDay: Birthday
-- @directChiefId: The chief id
-- @rolId: Rol id
-- @createdBy: User who create the record
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @day: Holds the day of birth
-- @month: Holds the month of birth
-- @year: Holds the year of birth
-- @fullName: The user Full name
-- @tranName: The trnasition name
-- @ErrorOccurred: Holds the error count (0: No error | >0: Was a error)
-- ===================================================================================================================================
-- Returns: 
-- Message
-- ErrorOccurred
-- CodeNumber
-- 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-04-01		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/01/2022
-- Description: sp_AddUserV2 - Add a new user
CREATE PROCEDURE sp_AddUserV2(
    @name NVARCHAR(30),
    @middleName NVARCHAR(30),
    @lastName1 NVARCHAR(30),
    @lastName2 NVARCHAR(30),
    @email NVARCHAR(50),
    @userName NVARCHAR(50),
    @tempPassword NVARCHAR(300),
    @password NVARCHAR(300),
    @birthDay DATETIME,
    @directChiefId INT,
    @rolId INT,
    @createdBy NVARCHAR(30)
) AS

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

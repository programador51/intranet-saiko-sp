-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-13-2022
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddUserV3
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
--	2022-07-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/13/2022
-- Description: sp_AddUserV3 - Some Notes
CREATE PROCEDURE sp_AddUserV3(
    @birthDay DATETIME,
    @createdBy NVARCHAR(30),
    @directChiefId INT,
    @email NVARCHAR(50),
    @ladaMovil NVARCHAR(10),
    @lastName1 NVARCHAR(30),
    @lastName2 NVARCHAR(30),
    @middleName NVARCHAR(30),
    @movil NVARCHAR(30),
    @name NVARCHAR(30),
    @password NVARCHAR(300),
    @rolId INT,
    @tempPassword NVARCHAR(300),
    @userName NVARCHAR(50)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

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

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
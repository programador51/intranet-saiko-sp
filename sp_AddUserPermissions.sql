-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-07-2022
-- Description: Add and update special user permissions
-- STORED PROCEDURE NAME:	sp_AddUserPermissions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @createdBy: User who create the record
-- @arrayNewUuid: Modified permissions
-- @arrayRemoveUuid: Permissions removed
-- @rolId: Rol id
-- @userId: User id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- @needRemovePermissions: Identifies if permissions need to be removed
-- @tranName: The name of the transition
-- @ErrorOccurred: Identify if any error occurred
-- @Message: The reply message
-- @CodeNumber: The error code
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
--	2022-04-07		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/07/2022
-- Description: sp_AddUserPermissions - Add and update special user permissions
CREATE PROCEDURE sp_AddUserPermissions(
    @arrayNewUuid NVARCHAR(MAX),
    @arrayRemoveUuid NVARCHAR(MAX),
    @createdBy NVARCHAR(30),
    @rolId INT,
    @userId INT
) AS 

BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @needRemovePermissions TINYINT
    DECLARE @tranName NVARCHAR(30)= 'upDatePermissionTran';


    DECLARE @ErrorOccurred TINYINT;
    DECLARE @Message NVARCHAR (256);
    DECLARE @CodeNumber INT;

    
    SELECT 
        @needRemovePermissions=
            CASE
                WHEN (SELECT LEN(@arrayRemoveUuid)) > 0 THEN 1
                ELSE 0
            END

    BEGIN TRY
        BEGIN TRANSACTION @tranName
            UPDATE Users SET isPermissionMod=1 WHERE userID=@userId
            INSERT INTO UsersPermissions (
                    createdBy,
                    createdDate,
                    lastUpdatedBy,
                    lastUpdatedDate,
                    rolId,
                    userId,
                    uuid,
                    [status]

                )
                    SELECT 
                        @createdBy,
                        dbo.fn_MexicoLocalTime(GETDATE()),
                        @createdBy,
                        dbo.fn_MexicoLocalTime(GETDATE()),
                        @rolId,
                        @userId,
                        value,
                        1
                    FROM STRING_SPLIT(@arrayNewUuid, ',')
                    WHERE RTRIM(value)<>''

            IF (@needRemovePermissions=1)
                BEGIN
                    DELETE FROM UsersPermissions WHERE uuid IN (
                        SELECT 
                            value
                        FROM STRING_SPLIT(@arrayRemoveUuid, ',')
                        WHERE RTRIM(value)<>''
                    )
                    IF @@ERROR >0
                        BEGIN 
                            SET @ErrorOccurred= 1 -- Significa que fallo
                            SET @Message='Hubo problemas con la base de datos, no se pudo actualizar los permisos del usuario'
                            SET @CodeNumber= 500
                            ROLLBACK TRANSACTION @tranName
                        END
                    ELSE
                        BEGIN
                            SET @ErrorOccurred= 0
                            SET @Message='Permisos actualizados correctamente'
                            SET @CodeNumber= 200
                            COMMIT TRANSACTION @tranName
                        END
                END
            ELSE
                BEGIN 
                    IF @@ERROR >0
                        BEGIN 
                            SET @ErrorOccurred= 1 -- Significa que fallo
                            SET @Message='Hubo problemas con la base de datos, no se pudo actualizar los permisos del usuario'
                            SET @CodeNumber= 500
                            ROLLBACK TRANSACTION @tranName
                        END
                    ELSE
                        BEGIN
                            SET @ErrorOccurred= 0
                            SET @Message='Permisos actualizados correctamente'
                            SET @CodeNumber= 200
                            COMMIT TRANSACTION @tranName
                        END
                    
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
            'Problemas con la Base de datos, no se pudo actualizar los permisos' AS [Message],
            ERROR_NUMBER() AS CodeNumber
    END CATCH

END

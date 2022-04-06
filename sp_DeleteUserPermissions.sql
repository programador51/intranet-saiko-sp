-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 04-06-2022
-- Description: Reset the user's permissions so that they have those of the role
-- STORED PROCEDURE NAME:	sp_DeleteUserPermissions
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @userID User id
-- ===================================================================================================================================
-- =============================================
-- VARIABLES:
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-04-06		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 04/06/2022
-- Description: sp_DeleteUserPermissions - Reset the user's permissions so that they have those of the role
CREATE PROCEDURE sp_DeleteUserPermissions(
    @userID INT,
    @updateBy NVARCHAR(30)
) AS 

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

DECLARE @isMod TINYINT;

    DECLARE @TranName NVARCHAR(30)= 'resetPermissions';

    BEGIN TRY
        BEGIN TRANSACTION @TranName
        SELECT @isMod= isPermissionMod  FROM Users

        IF @isMod = 1
            BEGIN
                UPDATE Users
                    SET lastUpdatedBy= @updateBy,
                    isPermissionMod=0,
                    lastUpdatedDate= dbo.fn_MexicoLocalTime(GETDATE())
                DELETE FROM UsersPermissions WHERE userId=@userID
                
                IF @@ERROR > 0
                    BEGIN
                        ROLLBACK TRANSACTION @TranName
                    END
                ELSE 
                    BEGIN 
                        SELECT 
                            1 AS ErrorOccurred, 
                            'Los permisos del usuario se han actualizado' AS [Message],
                            200 AS CodeNumber
                            COMMIT TRANSACTION @TranName
                    END
            END
        ELSE
            BEGIN
                SELECT 
                    1 AS ErrorOccurred, 
                    'El usuario no tiene permisos espicales del rol' AS [Message],
                    400 AS CodeNumber
                COMMIT TRANSACTION @TranName
            END
    END TRY

    BEGIN CATCH
    DECLARE @xstate INT
        IF @xstate = -1
			rollback;
		IF @xstate = 1 
			rollback
		IF @xstate = 1 
			rollback transaction @TranName

        IF @@TRANCOUNT > 0  
            BEGIN
                ROLLBACK TRANSACTION;   
            END
        SELECT 
            1 AS ErrorOccurred, 
            'Problemas con la Base de datos, no se pudo asignar los permisos' AS [Message],
            ERROR_NUMBER() AS CodeNumber
        COMMIT TRANSACTION @TranName
    END CATCH



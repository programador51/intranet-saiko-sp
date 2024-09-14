-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 09-15-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_AddToDoRobot
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
--	2023-09-15		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 09/15/2023
-- Description: sp_AddToDoRobot - Some Notes
CREATE PROCEDURE sp_AddToDoRobot AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tranName NVARCHAR(50)='addToDoRobot';
    DECLARE @trancount INT;
    SET @trancount = @@trancount;
    BEGIN TRY
        IF (@trancount= 0)
            BEGIN
                BEGIN TRANSACTION @tranName;
            END
        ELSE
            BEGIN
                SAVE TRANSACTION @tranName
            END
        IF (@trancount=0)
            BEGIN
                COMMIT TRANSACTION @tranName
            END     
        IF OBJECT_ID(N'tempdb..#TempToDos') IS NOT NULL
            BEGIN
                DROP TABLE #TempToDos
            END
        IF OBJECT_ID(N'tempdb..#ToDosToUpdate') IS NOT NULL
            BEGIN
                DROP TABLE #ToDosToUpdate
            END


        DECLARE @idSection INT =1 -- Documents
        DECLARE @tagDescription NVARCHAR(30)='Expiracion'
        DECLARE @notFinished TINYINT=0;

        -- Document Types
        DECLARE @quoteType INT =1;
        DECLARE @orderType INT =2;
        DECLARE @contractType INT =6;
        DECLARE @odcType INT =3;
        DECLARE @cxpType INT =4;
        DECLARE @cxcType INT =5;

        -- Active status
        DECLARE @quoteStatus INT =1;
        DECLARE @orderStatus INT =4;
        DECLARE @contractStatus INT =7;
        DECLARE @odcStatus INT =10;
        DECLARE @cxcStatus INT =16;
        DECLARE @cxpStatus INT =20;


        DECLARE @today DATETIME
        DECLARE @createdBy NVARCHAR(20)='SISTEMA'
        SELECT @today= GETUTCDATE();



        -- Tabla temporal para los Todos abiertos
        CREATE TABLE #TempToDos (
            id INT NOT NULL IDENTITY(1,1),
            idToDo INT NOT NULL,
            idDocument INT NOT NULL,
            toDoNote NVARCHAR(256),
            count INT
        )
        -- Tabla temporal para actualizar los todos abiertos validando el estado del documento
        CREATE TABLE #ToDosToUpdate(
            id INT NOT NULL IDENTITY(1,1),
            idToDo INT NOT NULL,
            toDoNote NVARCHAR(256) NOT NULL,
            closeToDo TINYINT NOT NULL
        )

        -- Se agregan todos los todos abiertos de los documentos a la tabla temporal
        INSERT INTO #TempToDos (
            idToDo,
            idDocument,
            toDoNote,
            count
        )
        SELECT 
            toDo.id,
            toDo.fromId,
            toDo.toDoNote,
            DATEDIFF(DAY,toDo.createdDate,GETUTCDATE())
        FROM ToDo AS toDo
        WHERE 
            toDo.idSection=@idSection AND
            toDo.tagDescription =@tagDescription AND
            toDo.isTaskFinished=@notFinished

        -- Se actualizna los todos abiertos y se almacenan en la siguiente tabla temporal
        INSERT INTO #ToDosToUpdate(
            idToDo,
            toDoNote,
            closeToDo
        )
        SELECT 
            tempToDos.idToDo,
            CASE
                WHEN document.idTypeDocument=@quoteType THEN 'Cotización '+ document.documentNumber + 'vencida Recordatorio hace '+ tempToDos.[count]+ ' días'
                WHEN document.idTypeDocument=@orderType THEN 'Pedido '+ document.documentNumber + 'vencida Recordatorio hace '+ tempToDos.[count]+ ' días'
                WHEN document.idTypeDocument=@contractType THEN 'Cotnrato '+ document.documentNumber + 'vencida Recordatorio hace '+ tempToDos.[count]+ ' días'
                WHEN document.idTypeDocument=@odcType THEN 'Orde de compra '+ document.documentNumber + 'vencida Recordatorio hace '+ tempToDos.[count]+ ' días'
                WHEN document.idTypeDocument=@cxpType THEN 'CxP '+ document.documentNumber + 'vencida Recordatorio hace '+ tempToDos.[count]+ ' días'
                WHEN document.idTypeDocument=@cxcType THEN 'CxC '+ document.documentNumber + 'vencida Recordatorio hace '+ tempToDos.[count]+ ' días'
            END,
            CASE
                WHEN document.idStatus=@quoteStatus THEN 0
                WHEN document.idStatus=@orderStatus THEN 0 
                WHEN document.idStatus=@contractStatus THEN 0
                WHEN document.idStatus=@odcStatus THEN 0
                WHEN document.idStatus=@cxcStatus THEN 0
                WHEN document.idStatus=@cxpStatus THEN 0
                ELSE 1
            END

        FROM Documents AS document
        LEFT JOIN #TempToDos AS tempToDos ON tempToDos.idDocument=document.idDocument
        WHERE 
            document.idDocument = tempToDos.idDocument

        -- Se actualizan todos los todos abiertos en la tabla real de Todos
        UPDATE toDo SET 
            toDo.toDoNote= toUpdate.toDoNote,
            toDo.isTaskFinished=toUpdate.closeToDo
        FROM ToDo AS toDo
        LEFT JOIN #ToDosToUpdate AS toUpdate ON toUpdate.idToDo = toDo.id
        WHERE 
            toDo.id=toUpdate.idToDo


        INSERT INTO ToDo (
            atentionDate,
            createdBy,
            createdDate,
            executiveWhoAttendsId,
            executiveWhoCreatedId,
            fromId,
            idSection,
            isTaskFinished,
            lastUpdateBy,
            lastUpdateDate,
            reminderDate,
            [status],
            tagDescription,
            title,
            toDoNote,
            parent
        )
        SELECT 
            @today,
            @createdBy,
            @today,
            document.idExecutive,
            document.idExecutive,
            document.idDocument,
            @idSection,
            @notFinished,
            @createdBy,
            @today,
            @today,
            1,
            @tagDescription,
            CASE
                WHEN document.idTypeDocument=@quoteType THEN CONCAT('Cotización ',document.documentNumber, ' expirada')
                WHEN document.idTypeDocument=@orderType THEN CONCAT('Orden ',document.documentNumber, ' expirada')
                WHEN document.idTypeDocument=@contractType THEN CONCAT('Contrato ',document.documentNumber, ' expirado')
                WHEN document.idTypeDocument=@odcType THEN CONCAT('Orden de compra ',document.documentNumber, ' expirada')
                WHEN document.idTypeDocument=@cxcType THEN CONCAT('CxC ',document.documentNumber, ' expirada')
                WHEN document.idTypeDocument=@cxpType THEN CONCAT('CxP ',document.documentNumber, ' expirada')
            END,
            'El documento acaba de expirar favor de antenderlo lo antes posible',
            'documents'

        FROM Documents AS document
        LEFT JOIN #TempToDos AS todoUpdated ON todoUpdated.idDocument = document.idDocument
        WHERE 
            document.idDocument NOT IN (todoUpdated.idDocument) AND
            document.idStatus IN (@quoteStatus,@orderStatus,@contractStatus,@odcStatus,@cxcStatus,@cxpStatus) AND
            document.expirationDate < @today
        IF OBJECT_ID(N'tempdb..#TempToDos') IS NOT NULL
            BEGIN
                DROP TABLE #TempToDos
            END
        IF OBJECT_ID(N'tempdb..#ToDosToUpdate') IS NOT NULL
            BEGIN
                DROP TABLE #ToDosToUpdate
            END

    END TRY
    BEGIN CATCH
        DECLARE @Severity  INT= ERROR_SEVERITY()
        DECLARE @State   SMALLINT = ERROR_SEVERITY()
        DECLARE @Message   NVARCHAR(MAX)
        DECLARE @xstate INT= XACT_STATE();

        DECLARE @infoSended NVARCHAR(MAX)= 'Sin informacion por el momento';
        DECLARE @wasAnError TINYINT=1;
        DECLARE @mustBeSyncManually TINYINT=1;
        DECLARE @provider TINYINT=4;

        SET @Message= ERROR_MESSAGE();
        IF (@xstate= -1)
            BEGIN
                ROLLBACK TRANSACTION @tranName
            END
        IF (@xstate=1 AND @trancount=0)
            BEGIN
                -- COMMIT TRANSACTION @tranName
                ROLLBACK TRANSACTION @tranName
            END

        IF (@xstate=1 AND @trancount > 0)
            BEGIN
                ROLLBACK TRANSACTION @tranName;
            END
        RAISERROR(@Message, @Severity, @State);
        EXEC sp_AddLog 'SISTEMA',@Message,@infoSended,@mustBeSyncManually,@provider,@Message,@wasAnError;

    END CATCH

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
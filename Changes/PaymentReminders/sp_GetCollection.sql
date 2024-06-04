-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 03-19-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetCollection
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
--	2024-03-19		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetCollection')
    BEGIN 

        DROP PROCEDURE sp_GetCollection;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 03/19/2024
-- Description: sp_GetCollection - Some Notes
CREATE PROCEDURE sp_GetCollection(
    @date DATE,
    @tag INT,
    @page INT,
    @columnOrder NVARCHAR(50),
    @orderBy NVARCHAR(4),
    @rowsPerPage INT = 100
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @offset INT;
    DECLARE @noRegisters INT;
    DECLARE @pages INT;

    -----------------------------------------------------------------------------------------------

    DECLARE @TAG_FILTER NVARCHAR(MAX);

    SET @TAG_FILTER = CASE
                          WHEN @tag IS NULL THEN
                              'NULL'
                          ELSE
                              CONVERT(NVARCHAR, @tag)
                      END;

    -----------------------------------------------------------------------------------------------

    DECLARE @WHERE_CLAUSE NVARCHAR(MAX)
        = CONCAT(
                    ' paymentReminder.indexDate = ''',
                    @date,
                    ''' AND (paymentReminder.idTag = ',
                    @TAG_FILTER,
                    ' OR ',
                    @TAG_FILTER,
                    ' IS NULL)'
                );

    -----------------------------------------------------------------------------------------------

    DECLARE @setOrder NVARCHAR(MAX);

    SELECT @setOrder = CASE
                           WHEN @columnOrder = 'folio' THEN
                               CONCAT('CONVERT(INT,paymentReminder.folio) ', @orderBy, ' ')
                           WHEN @columnOrder = 'expedicion' THEN
                               CONCAT('paymentReminder.emitedDate ', @orderBy, ' ')
                           WHEN @columnOrder = 'expiracion' OR @columnOrder = 'vencidos' THEN
                               CONCAT('paymentReminder.expirationDate ', @orderBy, ' ')
                           WHEN @columnOrder = 'regla' THEN
                               CONCAT('paymentReminder.idRule ', @orderBy, ' ')
                           WHEN @columnOrder = 'cliente' THEN
                               CONCAT('client.shortName ', @orderBy, ' ')
                           WHEN @columnOrder = 'total' THEN
                               CONCAT('paymentReminder.total ', @orderBy, ' ')
                           WHEN @columnOrder = 'tag' THEN
                               CONCAT('paymentReminder.idTag ', @orderBy, ' ')
                           ELSE
                               NULL
                       END;

    -----------------------------------------------------------------------------------------------

    DECLARE @QUERY_PAGINATION NVARCHAR(MAX)
        = CONCAT(
                    'SELECT DISTINCT
           @count = COUNT(*)
    FROM PaymentReminder AS paymentReminder
        LEFT JOIN Customers AS client
            ON client.customerID = paymentReminder.idClient
    WHERE',
                    @WHERE_CLAUSE
                );

    -----------------------------------------------------------------------------------------------

    EXEC sp_GetPagination @page,
                          @QUERY_PAGINATION,
                          @rowsPerPage,
                          @spOffset = @offset OUTPUT,
                          @spTotalPages = @pages OUTPUT;

    -----------------------------------------------------------------------------------------------

    DECLARE @sql NVARCHAR(MAX);

    SET @sql
        = '
SELECT 
    paymentReminder.id AS id,
    paymentReminder.folio AS [folio],
    paymentReminder.partiality AS [partialitie],
    paymentReminder.emitedDate AS [createdDate],
    paymentReminder.expirationDate AS [expiration],
    DATEDIFF(day,paymentReminder.expirationDate,paymentReminder.[indexDate]) AS [expirationDays],
    paymentReminder.idRule AS [rule],
    paymentReminder.idTag AS [idTag], 
    tags.description AS [tag], 
    paymentReminder.currency AS [currency],
    paymentReminder.total AS [total],
    paymentReminder.executive AS [executive],
    paymentReminder.idClient AS [customer.id],
    client.shortName AS [customer.shortName],
    client.socialReason AS [customer.socialReason],
    CONCAT(''+'',client.ladaPhone,'' '',client.phone) AS [customer.phone],
    client.email AS [customer.email],
    paymentReminder.contact AS [contact.fullName],
    paymentReminder.phone AS [contact.phone],
    paymentReminder.email AS [contact.email]
FROM PaymentReminder AS paymentReminder
LEFT JOIN Customers AS client ON client.customerID = paymentReminder.idClient
LEFT JOIN PaymentReminderTags AS tags ON tags.id = paymentReminder.idTag
WHERE 
    ' + @WHERE_CLAUSE + '
ORDER BY ' + @setOrder
          + '
OFFSET @offset ROWS FETCH NEXT @rowsPerPage ROWS ONLY
FOR JSON PATH, ROOT(''paymentReminder''), INCLUDE_NULL_VALUES;';

    PRINT (@sql);

    EXEC sp_executesql @sql,
                       N'@date DATE, @tag INT, @offset INT, @rowsPerPage INT',
                       @date,
                       @tag,
                       @offset,
                       @rowsPerPage;

    SELECT @pages AS pages;
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------


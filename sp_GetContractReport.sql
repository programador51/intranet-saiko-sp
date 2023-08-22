-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-21-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetContractReport
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
--	2023-08-21		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/21/2023
-- Description: sp_GetContractReport - Some Notes
ALTER PROCEDURE sp_GetContractReport(
    @idExecutive INT,
    @idSector INT,
    @socialReason NVARCHAR(256),
    @idUen INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @idDocumentType INT = 6 
    DECLARE @customerStatus TINYINT=1;
    DECLARE @quoteNoStatus INT = 1;

    IF OBJECT_ID(N'tempdb..#DocumentByUen') IS NOT NULL 
            BEGIN
            DROP TABLE #DocumentByUen
        END



    CREATE TABLE #DocumentByUen (
        id INT NOT NULL IDENTITY(1,1),
        idDocument INT NOT NULL
    )

    INSERT INTO #DocumentByUen (
        idDocument
    )
    SELECT DISTINCT
        idDocument
    FROM Documents AS contract
    LEFT JOIN Customers AS customer ON customer.customerID = contract.idCustomer
    LEFT JOIN Users AS executive ON executive.userID=contract.idExecutive
    LEFT JOIN DocumentItems AS items ON items.document = contract.idDocument
    LEFT JOIN Catalogue AS catalogue ON catalogue.id_code=items.idCatalogue
    LEFT JOIN UEN AS uen ON uen.UENID = catalogue.uen
    WHERE 
        contract.idTypeDocument=@idDocumentType AND
        contract.idExecutive IN (
            SELECT 
                CASE 
                    WHEN @idExecutive IS NULL THEN wUser.userID
                    ELSE @idExecutive
                END
            FROM Users AS wUser
            WHERE wUser.[status]=1
        ) AND 
        customer.idTypeOfCustomer IN (
            SELECT 
                CASE 
                    WHEN @idSector IS NULL THEN id
                    ELSE @idSector
                END
            FROM TypeOfCustomer
        ) AND
        customer.socialReason LIKE ISNULL(@socialReason,'') + '%' AND
        uen.UENID IN (
            SELECT 
                CASE
                    WHEN @idUen IS NULL THEN UENID
                    ELSE @idUen 
                END
            FROM UEN

        )



    SELECT 
        contract.documentNumber,
        customer.socialReason,
        (
            SELECT DISTINCT
                uen.[description],
                uen.UENID AS id
            FROM DocumentItems AS items
            LEFT JOIN Catalogue AS catalogue ON catalogue.id_code= items.idCatalogue
            LEFT JOIN UEN AS uen ON uen.UENID= catalogue.uen
            WHERE items.document=contract.idDocument
            FOR JSON PATH, INCLUDE_NULL_VALUES
        ) AS uen,
        --uen va a ser un arreglo de uens, en el servidor se corrige para que sea una concatenacion
        contract.initialDate AS beginDate,
        contract.expirationDate AS endDate,
        currency.code AS currency,
        contract.subTotalAmount AS subTotal,
        executive.initials AS executive,
        (
                    SELECT
                        contractItems.quantity,
                        contractItems.[description]
                    FROM DocumentItems AS contractItems
                    WHERE contractItems.document = contract.idDocument
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ) AS products,
        (
            SELECT 
                quotes.createdDate AS beginDate,
                quotes.expirationDate AS endDate,
                quotes.subTotalAmount AS subTotal,
                currency.code AS currency,
                quoteExecutive.initials AS executive,
                quoteStatus.[description] AS [status],
                (
                    SELECT
                        quoteItems.quantity,
                        quoteItems.[description]
                    FROM DocumentItems AS quoteItems
                    WHERE quoteItems.document = quotes.idDocument
                    FOR JSON PATH, INCLUDE_NULL_VALUES
                ) AS products




            FROM Documents AS quotes
            LEFT JOIN Currencies AS quoteCurrency ON quoteCurrency.currencyID = quotes.idCurrency
            LEFT JOIN Users AS quoteExecutive ON quoteExecutive.userID=quotes.idExecutive
            LEFT JOIN DocumentNewStatus AS quoteStatus ON quoteStatus.id=quotes.idStatus
            WHERE 
                quotes.idContractParent = contract.idDocument AND
                quotes.idStatus != @quoteNoStatus
            FOR JSON PATH, INCLUDE_NULL_VALUES
        )AS history,
        documentStatus.[description] AS [status]

    FROM Documents AS contract
    LEFT JOIN Customers AS customer ON customer.customerID = contract.idCustomer
    LEFT JOIN Currencies AS currency ON currency.currencyID=contract.idCurrency
    LEFT JOIN Users AS executive ON executive.userID=contract.idExecutive
    LEFT JOIN DocumentNewStatus AS documentStatus ON documentStatus.id=contract.idStatus
    WHERE 
        contract.idTypeDocument=@idDocumentType AND
        contract.idExecutive IN (
            SELECT 
                CASE 
                    WHEN @idExecutive IS NULL THEN wUser.userID
                    ELSE @idExecutive
                END
            FROM Users AS wUser
            WHERE wUser.[status]=1
        ) AND 
        customer.idTypeOfCustomer IN (
            SELECT 
                CASE 
                    WHEN @idSector IS NULL THEN id
                    ELSE @idSector
                END
            FROM TypeOfCustomer
        ) AND
        customer.socialReason LIKE ISNULL(@socialReason,'') + '%' AND
        contract.idDocument IN (
            SELECT idDocument FROM #DocumentByUen
        )
        --Filtrar por UEN lo haria demasiado lento.

    FOR JSON PATH,INCLUDE_NULL_VALUES, ROOT('ContractHistory')


    IF OBJECT_ID(N'tempdb..#DocumentByUen') IS NOT NULL 
            BEGIN
            DROP TABLE #DocumentByUen
        END

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
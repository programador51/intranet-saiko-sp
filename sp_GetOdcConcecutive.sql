-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-13-2023
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetOdcConcecutive
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
--	2023-07-13		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/13/2023
-- Description: sp_GetOdcConcecutive - Some Notes
ALTER PROCEDURE sp_GetOdcConcecutive(
    @beginDate DATETIME,
    @endDate DATETIME,
    @status INT,
    @search NVARCHAR(256)
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    IF(@beginDate IS NULL OR @endDate IS NULL)
        BEGIN
        SELECT
            @beginDate =FIRST_VALUE(createdDate) 
            OVER (ORDER BY createdDate)
        FROM Documents
        WHERE 
                idTypeDocument=@idDocumentType

        SELECT
            @endDate =FIRST_VALUE(createdDate) 
            OVER (ORDER BY createdDate DESC)
        FROM Documents
        WHERE 
                idTypeDocument=@idDocumentType
    END

    SELECT
        odc.idDocument AS id,
        odc.documentNumber AS documentNumber,
        odc.createdDate AS emitedDate,
        odc.sentDate AS sendDate,
        odcStatus.[description] AS [status],
        currency.code AS currency,
        odc.totalAmount AS total,
        provaider.shortName AS providerSocialReason,
        ISNULL(client.socialReason,'ND') AS clientSocialReason

    FROM Documents AS odc
        LEFT JOIN DocumentNewStatus AS odcStatus ON odcStatus.id=odc.idStatus
        LEFT JOIN Currencies AS currency ON currency.currencyID=odc.idCurrency
        LEFT JOIN Customers AS provaider ON provaider.customerID=odc.idCustomer
        LEFT JOIN Documents AS orden ON orden.idDocument=odc.idInvoice
        LEFT JOIN Customers AS client ON client.customerID = orden.idCUstomer
    WHERE 
        odc.idStatus IN (
            SELECT
            CASE 
                    WHEN @status IS NULL THEN id
                    ELSE @status
                END
        FROM DocumentNewStatus
        WHERE 
                idDocumentType=@idDocumentType AND
            [status] =1
        ) AND
        (odc.createdDate>=@beginDate AND odc.createdDate <= @endDate ) AND
        (
            provaider.socialReason LIKE ISNULL(@search,'')+'%' OR
        client.socialReason LIKE ISNULL(@search,'')+'%' OR
        odc.documentNumber LIKE ISNULL(@search,'')+'%'
        )
    ORDER BY 
        odc.documentNumber

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------



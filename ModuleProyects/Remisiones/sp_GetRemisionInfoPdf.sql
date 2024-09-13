
-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-27-2024
-- Description: 
-- STORED PROCEDURE NAME:	sp_GetRemisionInfoPdf
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
--	2024-08-27		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetRemisionInfoPdf')
    BEGIN 

        DROP PROCEDURE sp_GetRemisionInfoPdf;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/27/2024
-- Description: sp_GetRemisionInfoPdf - Some Notes

CREATE PROCEDURE sp_GetRemisionInfoPdf(
    @idRemision INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON

    DECLARE @idPosition INT;
    DECLARE @idProyect INT
    DECLARE @idProposal INT;

    SELECT 
        @idPosition = idPosition
    FROM Documents AS remision
    WHERE
        remision.idDocument = @idRemision
        AND remision.idTypeDocument = 2
        AND remision.idPosition IS NOT NULL

    SELECT 
        @idProyect = idProject
    FROM PositionsProyects
    WHERE
        id = @idPosition

    SELECT 
        @idProposal = id
    FROM ProyectProposals
    WHERE 
        idProyect = @idProyect
        AND proposalStatus = 'Activa'

    SELECT 
        remision.idDocument AS idRemision,
        remision.documentNumber AS documentNumber,
        remision.createdDate AS createdDate,
        corporative.rfc AS rfc,
        corporative.socialReason AS socialReason,
        CONCAT(corporative.street,' ',corporative.exteriorNumber,' ',corporative.suburb,' ',corporative.city,' ',corporative.polity,' ',corporative.cp, ' ',corporative.country) AS [address],
        ISNULL(client.shortName,corporative.shortName) AS plant,
        proyect.[user] AS [user],
        proyect.solped AS solped,
        position.pos AS position,
        position.ocCustomer AS ocCustomer,
        items.quantity AS quantity,
        uen.[description] AS unity,
        items.description AS [itemDescription],
        remision.subTotalAmount AS subTotalAmount,
        remision.ivaAmount AS ivaAmount,
        remision.totalAmount AS totalAmount,
        ISNULL(CONCAT(UPPER(LEFT(client.shortName,3)),'',@idProposal),'ND') AS proposalFolio

    FROM Documents AS remision
    LEFT JOIN Customers AS client ON client.customerID= remision.idCustomer
    LEFT JOIN Customers AS corporative ON corporative.customerID = client.corporative
    LEFT JOIN Proyects AS proyect ON proyect.id = @idProyect
    LEFT JOIN PositionsProyects AS position ON position.id = @idPosition
    LEFT JOIN DocumentItems AS items ON items.document = remision.idDocument
    LEFT JOIN UEN AS uen ON uen.UENID = position.idUen
    WHERE 
        remision.idDocument = @idRemision
        AND remision.idTypeDocument = 2
        AND remision.idPosition IS NOT NULL
    EXEC sp_GetCompanyDetails;


END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
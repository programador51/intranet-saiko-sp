-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-17-2024
-- Description: Get the information of a proposal to generate a PDF
-- STORED PROCEDURE NAME:	sp_GetPdfProposalInfo
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @idProposal: The proposal id
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
--	2024-08-17		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name ='sp_GetPdfProposalInfo')
    BEGIN 

        DROP PROCEDURE sp_GetPdfProposalInfo;
    END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/17/2024
-- Description: sp_GetPdfProposalInfo - Get the information of a proposal to generate a PDF
CREATE PROCEDURE sp_GetPdfProposalInfo(
    @idProposal INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    -- CREATE TABLE #CompanyDetails (
    --     socialReason VARCHAR(256),
    --     rfc VARCHAR(15),
    --     fiscalRegimen VARCHAR(256),
    --     street VARCHAR(256),
    --     city VARCHAR(256),
    --     phone VARCHAR(15)
    -- );
    -- INSERT INTO #CompanyDetails (socialReason, rfc, fiscalRegimen, street, city, phone)
    EXEC sp_GetCompanyDetails;

    DECLARE @idProject INT;
    SELECT 
        @idProject = idProyect
    FROM ProyectProposals
    WHERE id = @idProposal;

    SELECT 
        ISNULL(corporative.socialReason,customer.socialReason) AS customerSocialReason,
        customer.socialReason AS customerPlant,
        ISNULL(corporative.rfc,customer.rfc) AS customerRFC,
        CONCAT(customer.street,' ',customer.exteriorNumber,' ',customer.suburb,' ',customer.city,' ',customer.polity,' ',customer.cp, ' ',customer.country) AS customerAddress,
        ISNULL(CONCAT(UPPER(LEFT(customer.shortName,3)),'',@idProposal),'ND') AS folio
    FROM Customers AS customer
    LEFT JOIN Proyects AS porject ON customer.customerID = porject.idClient
    LEFT JOIN Customers AS corporative ON corporative.customerID = customer.corporative
    WHERE
        porject.id = @idProject;


    SELECT
        project.solped AS solped,
        REPLACE(REPLACE(project.comments, '<p>', ''), '</p>', '') AS projectDescrtiption,
        proposal.expirationDate AS expirationDate,
        proposal.paymentTerms AS paymentTerms,
        proposal.subTotal AS subTotal,
        proposal.iva AS iva,
        proposal.total AS total,
        ISNULL(project.buyerEmail,'ND') AS buyerEmail,
        proposal.termsAndConditions,
        proposal.attn AS attn
    FROM ProyectProposals AS proposal
    LEFT JOIN Proyects AS project ON proposal.idProyect = project.id
    WHERE 
        proposal.id = @idProposal;

    SELECT 
        positionPryects.pos AS position,
        proposalIndex.positionDescription AS [description],
        positionPryects.sell AS [subTotal]
    FROM 
        ProposalPositionIndex AS proposalIndex
        LEFT JOIN PositionsProyects AS positionPryects ON proposalIndex.idPosition = positionPryects.id
    WHERE
        proposalIndex.idProposal = @idProposal;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
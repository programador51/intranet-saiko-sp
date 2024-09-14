-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 08-17-2022
-- Description: Get the associated files from doucments
-- STORED PROCEDURE NAME:	sp_GetAssociatedFiles
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
--	2022-08-17		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 08/17/2022
-- Description: sp_GetAssociatedFiles - Get the associated files from doucments
CREATE PROCEDURE sp_GetAssociatedFiles(
    @typeAssociatedFile INT,
    @pageRequested INT,
    @idEntity INT,
    @status INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    -- Number of registers founded
      DECLARE @noRegisters INT;
  
      -- Since which register start searching the information
      DECLARE @offsetValue INT;
  
      -- Total pages founded on the query
      DECLARE @totalPages DECIMAL;
  
      -- LIMIT of registers that can be returned per query
      DECLARE @rowsPerPage INT = 10;
  
      SELECT @noRegisters = COUNT(*)
      FROM AssociatedFiles
      WHERE
      idDocument = @idEntity AND
      idEntityFile = @typeAssociatedFile AND
          (status = @status OR @status IS NULL);
  
      SELECT @offsetValue = (@pageRequested - 1) * @rowsPerPage;
  
      SELECT @totalPages = CEILING((@noRegisters*1.0)/@rowsPerPage);
  
      SELECT
          @totalPages AS pages,
          @pageRequested AS actualPage,
          @noRegisters AS noRegisters;
    
    SELECT 
    
    id AS idAssocaitedFile,
    dbo.FormatDate(associatedDate) AS uploadedDate,
    dbo.fn_initialsName(AssociatedFiles.createdBy) AS createdBy,
    AssociatedFiles.fileName AS fileName,
    AssociatedFiles.typeFile AS fileExtension,
    AssociatedFiles.urlBlob AS url,
    CONVERT(BIT,AssociatedFiles.hasComments) AS hasComments,
    CONVERT(BIT,AssociatedFiles.status) AS isAvailable,
    isFileRemovable AS isFileRemovable
    

    FROM AssociatedFiles WHERE idDocument = @idEntity AND (status = @status OR @status IS NULL) AND idEntityFile = @typeAssociatedFile
    ORDER BY id DESC OFFSET @offsetValue ROWS FETCH NEXT @rowsPerPage ROWS ONLY;

END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
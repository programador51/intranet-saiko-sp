-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 06-08-2022
-- Description: Creates a Tag
-- STORED PROCEDURE NAME:	sp_AddTags
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
--  @createdBy:User who create the record
--  @description: Tag description
--  @idExecutive: Executive id
--  @idType: Type of tag
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
--	2022-06-08		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 06/08/2022
-- Description: sp_AddTags - Creates a Tag
CREATE PROCEDURE sp_AddTags(
    @createdBy NVARCHAR(30),
    @description NVARCHAR(30),
    @idExecutive INT,
    @idType INT
) AS 
BEGIN

    SET LANGUAGE Spanish;
    SET NOCOUNT ON
    DECLARE @tagId INT;
    INSERT INTO Tags (
    createdBy,
    createdDate,
    [description],
    idExecutive,
    idType,
    lastUpdateBy,
    lastUpdateDate,
    [status]
    )
    VALUES(
        @createdBy,
        dbo.fn_MexicoLocalTime(GETDATE()),
        @description,
        @idExecutive,
        @idType,
        @createdBy,
        dbo.fn_MexicoLocalTime(GETDATE()),
        1
    )
SELECT @tagId=SCOPE_IDENTITY();
RETURN @tagId;
END

-- ----------------- ↓↓↓ BEGIN ↓↓↓ -----------------------
-- ----------------- ↑↑↑ END ↑↑↑ -----------------------
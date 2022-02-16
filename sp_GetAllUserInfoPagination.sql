-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: gets all the users on the sistem
-- STORED PROCEDURE NAME:	sp_GetAllUserInfoPagination
-- **************************************************************************************************************************************************
-- =============================================
-- PARAMETERS:
-- @sinceRegister 
-- @limitRegisters
-- ===================================================================================================================================
-- Returns: 
-- =============================================
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2022-01-20		Adrian Alardin   			1.0.0.0			Initial Revision	
-- *****************************************************************************************************************************
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      Adrian Alardin Iracheta
-- Create Date: 07/02/2021
-- Description: sp_getAllUsers permite obtener todos los usuarios del sistema
-- =============================================
CREATE PROCEDURE sp_GetAllUserInfoPagination (
    @search NVARCHAR(30)
)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    DECLARE  @WHERE_CLAUSE NVARCHAR (MAX);
    DECLARE  @SELECT_CLAUSE NVARCHAR (MAX);
    DECLARE  @FROM_CLAUSE NVARCHAR (MAX);
    DECLARE  @SP_STATEMENT NVARCHAR (MAX);
    DECLARE @PARAMS NVARCHAR (MAX);

    SET @PARAMS ='@search NVARCHAR(30) ';
    SET @SELECT_CLAUSE='SELECT COUNT(*) AS noRegisters ';
    SET @FROM_CLAUSE='FROM Users ';
    SET @search= @search +'%'
    IF @search IS NULL OR @search= '%'
        BEGIN   
            SET @WHERE_CLAUSE=''
        END
    ELSE 
        BEGIN
            SET @WHERE_CLAUSE='WHERE Users.firstName LIKE @search OR 
            Users.userName LIKE @search OR 
            Users.email LIKE @search '
        END

SET @SP_STATEMENT= @SELECT_CLAUSE +@FROM_CLAUSE+ @WHERE_CLAUSE;
EXEC SP_EXECUTESQL @SP_STATEMENT,@PARAMS, @search
END
GO

-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
-- =============================================
-- Author:      Adrian Alardin
-- Create date: 07-02-2021
-- Description: gets all the users on the sistem
-- STORED PROCEDURE NAME:	sp_GetAllUserInfo
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
--	2022-01-19		Adrian Alardin   			1.0.0.0			Initial Revision	
--	2022-01-20		Adrian Alardin   			1.0.0.2			Optimizado	
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
CREATE PROCEDURE sp_GetAllUserInfo (
    @sinceRegister INT ,
    @limitRegisters INT,
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
    DECLARE  @JOIN_CLAUSE NVARCHAR (MAX);
    DECLARE  @SP_STATEMENT NVARCHAR (MAX);
    DECLARE @PARAMS NVARCHAR (MAX);

    SET @PARAMS ='@sinceRegister INT, @limitRegisters INT, @search NVARCHAR(30) ';
    SET @SELECT_CLAUSE='
        SELECT 
            Users.userID AS userID,
            Users.userName AS userName,
            dbo.fn_initialsName(CONCAT(Users.firstName,'' '',Users.middleName,'' '',Users.lastName1,'' '',Users.lastName2)) AS initials,
            CONCAT(Users.firstName,'' '',Users.middleName,'' '',Users.lastName1,'' '',Users.lastName2) AS fullName, 
            Users.email AS email,
            Roles.description AS rolDescription,
            Users.firstName AS firstName,
            Users.middleName AS middleName,
            Users.lastName1 AS lastName1,
            Users.lastName2 AS lastName2 ';
    SET @FROM_CLAUSE='FROM Users ';
    SET @JOIN_CLAUSE='LEFT JOIN Roles on Users.rol = Roles.rolID ';
    SET @search= @search +'%'
    IF @search IS NULL OR @search= '%'
        BEGIN   
            SET @WHERE_CLAUSE='ORDER BY userID ASC OFFSET @sinceRegister ROWS FETCH NEXT @limitRegisters ROWS ONLY '
        END
    ELSE 
        BEGIN
            SET @WHERE_CLAUSE='WHERE Users.firstName LIKE @search OR 
            Users.userName LIKE @search OR 
            Users.email LIKE @search
            ORDER BY userID ASC OFFSET @sinceRegister ROWS FETCH NEXT @limitRegisters ROWS ONLY '
        END

SET @SP_STATEMENT= @SELECT_CLAUSE +@FROM_CLAUSE+@JOIN_CLAUSE+ @WHERE_CLAUSE;
EXEC SP_EXECUTESQL @SP_STATEMENT,@PARAMS, @sinceRegister,@limitRegisters,@search
END
GO

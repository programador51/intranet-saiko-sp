-- **************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************
-- Author:      Jose Luis Perez Olguin
-- Create date: 11-11-2021

-- Description: Function to get the first letter after each space. Works for the initials name

-- PARAMETERS:
-- @name: Name of the person. For instance: Jose Luis Perez Olguin -> JLPO

-- **************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--  11-11-2021     Jose Luis Perez             1.0.0.0         Documentation and query		
-- **************************************************************************************************************************


/****** Object:  UserDefinedFunction [dbo].[fn_initialsName]    Script Date: 11/10/2021 12:51:27 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fn_initialsName](@name NVARCHAR(4000))
RETURNS NVARCHAR(2000)

AS BEGIN

	DECLARE @retval NVARCHAR(2000);

    SET @name=RTRIM(LTRIM(@name));
    SET @retval=LEFT(@name,1);

    WHILE CHARINDEX(' ',@name,1)>0 BEGIN
        SET @name=LTRIM(RIGHT(@name,LEN(@name)-CHARINDEX(' ',@name,1)));
        SET @retval+=LEFT(@name,1);
    END

    RETURN @retval;

END
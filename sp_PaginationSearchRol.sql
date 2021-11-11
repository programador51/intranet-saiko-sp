-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_PaginationSearchRol
--
--	DESCRIPTION:			This SP retrieves the count of roles for a given free description
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ==================================================================================================================================================
--	2021-11-10		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************

/****** Object:  StoredProcedure [dbo].[sp_PaginationSearchRol]    Script Date: 09/07/2021 03:06:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_PaginationSearchRol(

	@textSearch NVARCHAR(50)

)

AS BEGIN

	SELECT Count(*) FROM Roles
    WHERE description LIKE @textSearch

END

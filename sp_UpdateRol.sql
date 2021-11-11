-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_UpdateRol
--
--	DESCRIPTION:			This SP updates the rol description and status
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ==================================================================================================================================================
--	2021-11-10		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************

/****** Object:  StoredProcedure [dbo].[sp_UpdateRol]    Script Date: 09/07/2021 03:06:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_UpdateRol(

	@rolId INT,
	@description NVARCHAR(50),
	@status TINYINT,
	@lastUpdatedBy NVARCHAR(30)

)

AS BEGIN

UPDATE Roles 
SET
    description = @description,
    status = @status,
    lastUpdatedBy = @lastUpdatedBy,
    lastUpadatedDate = GETDATE()
    
WHERE rolID = @rolId

END

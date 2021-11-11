-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_UpdateAssociatedCustomerToExecutive
--
--	DESCRIPTION:			This SP updates the associated executive for a given PK
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- ==================================================================================================================================================
--	2021-11-10		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************

/****** Object:  StoredProcedure [dbo].[sp_UpdateAssociatedCustomerToExecutive]    Script Date: 09/07/2021 03:06:40 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE sp_UpdateAssociatedCustomerToExecutive(

	@idExecutive INT,
	@pkRow INT

)

AS BEGIN

	UPDATE Customer_Executive SET 
        executiveID = @idExecutive WHERE customerExecutiveID = @pkRow

END

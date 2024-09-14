/****** Object:  StoredProcedure [dbo].[sp_InsertAdvertisementType]    Script Date: 26/07/2021 07:22:45 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_AddAdvertisementType 
--  STORED PROCEDURE OLD NAME: sp_InsertAdvertisementType

--
--	DESCRIPTION:			This SP inserts a new advertisement type
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-06-09		Iván Díaz   				1.0.0.0			Initial Revision		
--	2021-07-22		Iván Díaz   				1.0.0.0			Change name sp		

-- **************************************************************************************************************************************************

ALTER PROCEDURE [dbo].[sp_AddAdvertisementType]
	@nameAdvertisement VARCHAR(256),
	@iconName VARCHAR(30)

AS
BEGIN
-- **************************************************************************************************************************************************                    
-- RETURN DATA                   
-- **************************************************************************************************************************************************                    
INSERT INTO [dbo].[AdvertisementTypes]
           ([description]
           ,[icon]
           ,[color]
           ,[createdBy]
           ,[createdDate]
           ,[lastUpdatedBy]
           ,[lastUpdatedDate])
     VALUES
           (@nameAdvertisement
           ,@iconName
           ,NULL
           ,'Administrator'
           ,getdate()
           ,'Administrator'
           ,getdate())

END


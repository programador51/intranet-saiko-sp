/****** Object:  StoredProcedure [dbo].[sp_InsertAdvertisement]    Script Date: 26/07/2021 07:15:27 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- **************************************************************************************************************************************************
--	STORED PROCEDURE OVERVIEW INFORMATION
-- **************************************************************************************************************************************************
--
--	STORED PROCEDURE NAME:	sp_AddAdvertisement 
--
--	DESCRIPTION:			This SP inserts a new advertisement
--
-- **************************************************************************************************************************************************
--	REVISION HISTORY/LOG
-- **************************************************************************************************************************************************
--	Date			Programmer					Revision	    Revision Notes			
-- =================================================================================================
--	2021-06-09		Iván Díaz   				1.0.0.0			Initial Revision		
--	2021-07-22		Iván Díaz   				1.0.0.0			Initial Revision		
-- **************************************************************************************************************************************************

ALTER PROCEDURE [dbo].[sp_AddAdvertisement]
	@userIdCreated INT,
	@startDate DATETIME,
	@endDate DATETIME,
	@message NVARCHAR (255),
	@type INT,
	@createdBy NVARCHAR (30)

AS
BEGIN
-- **************************************************************************************************************************************************                    
-- RETURN DATA                   
-- **************************************************************************************************************************************************                    
INSERT INTO [dbo].[Advertisements]
           ([registrationUserID]
           ,[registrationDate]
           ,[startDate]
           ,[endDate]
           ,[message]
           ,[messageTypeID]
           ,[status]
           ,[createdBy]
           ,[createdDate]
           ,[lastUpdatedBy]
           ,[lastUpadatedDate])
     VALUES
	       (@userIdCreated
           ,getdate()
           ,@startDate
           ,@endDate
           ,@message
           ,@type
           ,1
           ,@createdBy
           ,getdate()
           ,@createdBy
           ,getdate())

END


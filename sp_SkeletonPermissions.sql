/****** Object:  StoredProcedure [dbo].[sp_SkeletonPermissions]    Script Date: 08/07/2021 09:13:04 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_SkeletonPermissions]

AS BEGIN

SELECT * FROM Sections ORDER BY orderElement

END

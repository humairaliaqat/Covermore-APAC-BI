USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_extractlist]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[rawsp_extractlist]
as
begin

	select
		[ID],
		[Name],
		[Country],
		[AgencyGroup]
	from usrRawExtract
	where [isActive] = 1
	order by [Name]

end

GO

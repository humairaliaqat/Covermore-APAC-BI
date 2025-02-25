USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[tmp_fn_GetConsultantName]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[tmp_fn_GetConsultantName](@ConsultantKey varchar(13))
returns varchar(50)
as
begin

  declare @cname varchar(13)
  
  select top 1 @cname = ConsultantName
  from Consultant c
  where c.ConsultantKey = @ConsultantKey

  return @cname 
  
end

GO

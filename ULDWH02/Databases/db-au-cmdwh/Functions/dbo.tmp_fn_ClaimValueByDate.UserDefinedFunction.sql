USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[tmp_fn_ClaimValueByDate]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[tmp_fn_ClaimValueByDate] (@ClaimKey varchar(9), @ReferenceDate date) returns int
as
begin

	return 0

end
GO

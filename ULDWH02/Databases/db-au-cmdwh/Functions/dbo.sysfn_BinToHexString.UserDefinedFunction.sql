USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[sysfn_BinToHexString]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[sysfn_BinToHexString] (@bin varbinary(max))
returns varchar(max)
as
begin

  return convert(varchar(max), @bin, 1)
  
end  

GO

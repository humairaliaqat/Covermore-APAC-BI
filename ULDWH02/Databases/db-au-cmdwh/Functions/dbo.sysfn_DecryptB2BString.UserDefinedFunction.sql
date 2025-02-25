USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[sysfn_DecryptB2BString]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[sysfn_DecryptB2BString](@EncryptedString varbinary(128))
returns varchar(50)
as
begin

  declare @output varchar(50)
  
  select @output = AlphaCode
  from usrSHAOutlet
  where HashedAlphaCode = convert(varchar(max), @EncryptedString, 1)

  return @output
  
end  


GO

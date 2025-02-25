USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[sysfn_EncryptB2BString]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[sysfn_EncryptB2BString](@String varchar(64))
returns varbinary(max)
as
begin

  return hashbytes('SHA1', 'R8>D$)q}' + @String)
  
end  
GO

USE [db-au-stage]
GO
/****** Object:  UserDefinedFunction [dbo].[sysfn_DecryptClaimsString]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[sysfn_DecryptClaimsString](@EncryptedString varbinary(max))
returns varbinary(max)
as
begin

    return [db-au-log].dbo.[sysfn_DecryptClaimsString](@EncryptedString)

end
GO

USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[sysfn_DecryptEMCString]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[sysfn_DecryptEMCString](@EncryptedString varbinary(max))
returns varbinary(max)
as
begin

    return decryptbykeyautocert(cert_id('EMCCertificate'), null, @EncryptedString, 0, null)
    
end
GO

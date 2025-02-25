USE [db-au-atlas]
GO
/****** Object:  StoredProcedure [atlas].[UpdateLastDatetime]    Script Date: 21/02/2025 11:28:24 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [atlas].[UpdateLastDatetime] --'atlas.[CASE]'
@EntityName varchar(100)

AS 
BEGIN


DECLARE @LastDatetime datetime

DECLARE @SQL nvarchar(max) 

SET @SQL= 'SELECT @LastDatetime= Max(SystemModstamp)  from ' +@EntityName

EXECUTE sp_executesql  @SQL,  N'@EntityName varchar(100), @LastDatetime datetime out', @EntityName =@EntityName,@LastDatetime=@LastDatetime output
 

UPDATE [atlas].[JobConfig] SET LastDatetime=@LastDatetime WHERE EntityName=@EntityName


END
GO

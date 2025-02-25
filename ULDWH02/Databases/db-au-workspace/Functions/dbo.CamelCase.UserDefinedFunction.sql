USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [dbo].[CamelCase]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CamelCase]    
(@Str varchar(8000))    
RETURNS varchar(8000) AS    
BEGIN    
  DECLARE @Result varchar(2000)    
  SET @Str = LOWER(@Str) + ' '    
  SET @Result = ''    
  WHILE 1=1    
  BEGIN    
    IF PATINDEX('% %',@Str) = 0 BREAK    
    SET @Result = @Result + UPPER(Left(@Str,1))+    
    SubString  (@Str,2,CharIndex(' ',@Str)-1)    
    SET @Str = SubString(@Str,    
      CharIndex(' ',@Str)+1,Len(@Str))    
  END    
  SET @Result = Left(@Result,Len(@Result))    
  RETURN @Result    
END 
GO

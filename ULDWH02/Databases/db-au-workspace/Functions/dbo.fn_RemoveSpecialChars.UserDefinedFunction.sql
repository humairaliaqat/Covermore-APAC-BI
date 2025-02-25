USE [db-au-workspace]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_RemoveSpecialChars]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_RemoveSpecialChars] (@s nvarchar(256)) returns nvarchar(256)
   with schemabinding

/************************************************************************************/
-- This function removes ASCII characters that are not:
--		 between 65 and 90 (A to Z)
--		 between 97 and 122 (a to z)
/************************************************************************************/

begin
   if @s is null
      return null

   declare @s2 varchar(256)
   set @s2 = ''

   declare @l int
   set @l = len(@s)
   
   declare @p int
   set @p = 1
   
   while @p <= @l 
   begin
      declare @c int
      set @c = ascii(substring(@s, @p, 1))
      
	  if @c between 65 and 90				--A to Z
         set @s2 = @s2 + char(@c)
	  else if @c between 97 and 122			--a to z
		set @s2 = @s2 + char(@c)
	  else if @c between 48 and 57			--0 to 9
		set @s2 = @s2 + char(@c)
	  else if @c = 45						-- - (dash/minus sign)
		set @s2 = @s2 + char(@c)
	  else if @c = 32						-- - (space)
		set @s2 = @s2 + char(@c)

	  set @p = @p + 1
   end
   
   if len(@s2) = 0
      return null
   return @s2
end

GO

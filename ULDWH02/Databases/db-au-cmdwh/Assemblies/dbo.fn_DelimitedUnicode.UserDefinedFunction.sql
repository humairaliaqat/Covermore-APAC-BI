USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_DelimitedUnicode]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_DelimitedUnicode] 
(
    @String nvarchar(4000), 
    @Delimiter char(1)
)
returns table with schemabinding
as
return
 
/*******************************************************************************************************************
 Purpose:
 Split a given string at a given delimiter and return a list of the split elements (items).

 Notes:
 1.  Leading a trailing delimiters are treated as if an empty string element were present.
 2.  Consecutive delimiters are treated as if an empty string element were present between them.
 3.  Except when spaces are used as a delimiter, all spaces present in each element are preserved.

 Returns:
 iTVF containing the following:
 ItemNumber = Element position of Item as a BIGINT (not converted to INT to eliminate a CAST)
 Item       = Element value as a VARCHAR(8000)

*******************************************************************************************************************/

with 
e1(n) as 
( 
    select 1 
    union all 
    select 1 
    union all 
    select 1 
    union all
	select 1 
    union all 
    select 1 
    union all 
    select 1 
    union all
	select 1 
    union all 
    select 1 
    union all 
    select 1 
    union all
	select 1
), --10E+1 or 10 rows
e2(n) as 
(
    select 1 
    from 
        e1 a, 
        e1 b
), --10E+2 or 100 rows
e4(n) as 
(
    select 1 
    from 
        e2 a, 
        e2 b
), --10E+4 or 10,000 rows max
cteTally(n) as 
(
--This provides the "base" CTE and limits the number of rows right up front
--for both a performance gain and prevention of accidental "overruns"
    select top (isnull(len(@String), 0)) 
        row_number() over (order by (select null)) 
    from 
        e4
),
cteStart(N1) as 
(				--This returns N+1 (starting position of each "element" just once for each delimiter)
					select 1 union all
					select t.N+1 from cteTally t where substring(@String,t.N,1) = @Delimiter
					),
	cteLen(N1,L1) as(				--Return start and length (for use in substring)
					select s.N1,
						   isnull(nullif(charindex(@Delimiter,@String,s.N1),0) - s.N1,4000)
                    from cteStart s
					)
	--Do the actual split. The ISNULL/NULLIF combo handles the length for the final element when no delimiter is found.
	select ItemNumber = row_number() over (order by l.N1),
		   Item = substring(@String, l.N1, l.L1)
    from cteLen l
GO

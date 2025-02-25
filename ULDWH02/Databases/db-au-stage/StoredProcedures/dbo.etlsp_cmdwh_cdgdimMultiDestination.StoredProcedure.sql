USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgdimMultiDestination]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cdgdimMultiDestination]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180227
Prerequisite:   
Description:    Innate Impulse2 version 2 multi destination table denormalisation, and load data to [db-au-cmdwh].dbo.cdgdimMultiDestination
Change History:
                20180227 - LT - Procedure created
						
*************************************************************************************************************************************/

if object_id('tempdb..#cdgdimMultiDestination') is not null drop table #cdgdimMultiDestination

;with cte_destination
as
(
	select									--combine unpivot and destination name
		a.*,
		b.Destination
	from
	(
		select								--unpivot to get columns to rows
			dimCovermoreCountryListID,
			CMCountryID
		from
			cdg_dimCovermoreCountryList_AU
		unpivot
		(
			CMCountryID
			for [Value] in (CMCountryID1, CMCountryID2, CMCountryID3, CMCountryID4, CMCountryID5, CMCountryID6, CMCountryID7, CMCountryID8, CMCountryID9, CMCountryID10)
		) unpiv
		where
			CMCountryID <> -1
	) a
	outer apply								--get destination name
	(
		select CovermoreCountryName as Destination
		from
			cdg_dimCovermoreCountry_AU		
		where
			dimCovermoreCountryID = a.CMCountryID
	) b
)
select distinct								--concat text from multiple rows into single text string
	x1.dimCovermoreCountryListID,
	(
		select x2.Destination + '; ' as [text()]
		from
			cte_destination x2
		where
			x1.dimCovermoreCountryListID = x2.dimCovermoreCountryListID
		order by x1.dimCovermoreCountryListID
		for xml path ('')
	) Destination
into #cdgdimMultiDestination
from
	cte_destination x1


if object_id('[db-au-cmdwh].dbo.cdgdimMultiDestination') is null
begin
	create table [db-au-cmdwh].dbo.cdgdimMultiDestination
	(
		dimCovermoreCountryListID int not null,
		MultiDestination varchar(8000) null
	)
end
else
	truncate table [db-au-cmdwh].dbo.cdgdimMultiDestination

insert [db-au-cmdwh].dbo.cdgdimMultiDestination with(tablock)
(
	dimCovermoreCountryListID,
	MultiDestination
)
select
	c.dimCovermoreCountryListID,
	left(c.Destination,len(c.Destination)-1) as MultiDestination
from
	#cdgdimMultiDestination c
GO

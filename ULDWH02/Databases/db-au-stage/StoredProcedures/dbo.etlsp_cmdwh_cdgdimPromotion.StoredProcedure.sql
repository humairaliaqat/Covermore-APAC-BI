USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgdimPromotion]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_cdgdimPromotion]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180227
Prerequisite:   
Description:    Innate Impulse2 version 2 promotion table denormalisation, and load data to [db-au-cmdwh].dbo.cdgdimPromotion
Change History:
                20180227 - LT - Procedure created
						
*************************************************************************************************************************************/

if object_id('tempdb..#cdgdimPromotion') is not null drop table #cdgdimPromotion

;with cte_promotion
as
(
	select									--combine unpivot and destination name
		a.dimPromoCodeListID,
		b.PromoCode,
		b.PromoType
	from
	(
		select								--unpivot to get columns to rows
			dimPromoCodeListID,
			PromoCodeID
		from
			cdg_dimPromoCodeList_AU
		unpivot
		(
			PromoCodeID
			for [Value] in (PromoCodeID1, PromoCodeID2, PromoCodeID3, PromoCodeID4, PromoCodeID5)
		) unpiv
		where
			PromoCodeID <> -1
	) a
	outer apply								--get destination name
	(
		select top 1
			Code as PromoCode,
			[Type] as PromoType
		from
			cdg_dimPromoCode_AU		
		where
			dimPromoCodeID = a.PromoCodeID
	) b
)
select distinct								--concat text from multiple rows into single text string
	x1.dimPromoCodeListID,
	(
		select x2.PromoCode + '; ' as [text()]
		from
			cte_promotion x2
		where
			x1.dimPromoCodeListID = x2.dimPromoCodeListID
		order by x1.dimPromoCodeListID
		for xml path ('')
	) PromoCode,
	x1.PromoType
into #cdgdimPromotion
from
	cte_promotion x1


if object_id('[db-au-cmdwh].dbo.cdgdimPromotion') is null
begin
	create table [db-au-cmdwh].dbo.cdgdimPromotion
	(
		dimPromoCodeListID int not null,
		PromoCode varchar(8000) null,
		PromoType varchar(100) null
	)
end
else
	truncate table [db-au-cmdwh].dbo.cdgdimPromotion

insert [db-au-cmdwh].dbo.cdgdimPromotion with(tablock)
(
		dimPromoCodeListID,
		PromoCode,
		PromoType
)
select
	p.dimPromoCodeListID,
	left(p.PromoCode,len(p.PromoCode)-1) as PromoCode,
	p.PromoType
from
	#cdgdimPromotion p


GO

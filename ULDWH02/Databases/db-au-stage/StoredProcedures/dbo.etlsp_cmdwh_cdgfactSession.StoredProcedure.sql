USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgfactSession]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cdgfactSession]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180227
Prerequisite:   
Description:    Innate Impulse2 version 2 fact session table denormalisation, and load data to [db-au-cmdwh].dbo.cdgfactSession
Change History:
                20180227 - LT - Procedure created
						
*************************************************************************************************************************************/

if object_id('[db-au-stage].dbo.etl_cdgfactSession') is not null drop table [db-au-stage].dbo.etl_cdgfactSession

select
	q.factSessionID,
	q.BusinessUnitID,
	q.CampaignID,
	q.ParentFactSessionID,
	convert(datetime,qdate.SessionCreateDate + ' ' + qtime.SessionCreateTime) as SessionCreateDate,
	convert(datetime,cdate.SessionCloseDate + ' ' + ctime.SessionCloseTime) as SessionCloseDate,
	alpha.AffiliateCode,
	q.IsClosed,
	q.IsPolicyPurchased,
	q.Domain,
	q.SessionToken,
	q.GigyaID,
	q.TotalPoliciesSold
into [db-au-stage].dbo.etl_cdgfactSession
from
	[dbo].[cdg_factSession_AU] q
	outer apply
	(
		select top 1 AffiliateCode
		from 
			cdg_dimAffiliateCode_AU 
		where
			dimAffiliateCodeID = q.AffiliateCodeID
	) alpha
	outer apply
	(
		select top 1 [Date] as SessionCreateDate
		from dbo.cdg_dimDate_AU 
		where DimDateID = q.SessionCreateDateID
	) qdate
	outer apply
	(
		select top 1 [Time] as SessionCreateTime
		from dbo.cdg_dimTime_AU 
		where dimTimeID = q.SessionCreateTimeID
	) qtime
	outer apply
	(
		select top 1 [Date] as SessionCloseDate
		from dbo.cdg_dimDate_AU 
		where DimDateID = q.SessionCloseDateID
	) cdate
	outer apply
	(
		select top 1 [Time] as SessionCloseTime
		from dbo.cdg_dimTime_AU 
		where dimTimeID = q.SessionCloseTimeID
	) ctime


if object_id('[db-au-cmdwh].dbo.cdgfactSession') is null
begin
	create table [db-au-cmdwh].dbo.cdgfactSession
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[factSessionID] [int] NOT NULL,
		[BusinessUnitID] [int] NOT NULL,
		[CampaignID] [int] NOT NULL,
		[ParentFactSessionID] [int] NULL,
		[SessionCreateDate] [datetime] NULL,
		[SessionCloseDate] [datetime] NULL,
		[AffiliateCode] [varchar](100) NULL,
		[IsClosed] [int] NULL,
		[IsPolicyPurchased] [int] NOT NULL,
		[Domain] [nvarchar](2) NOT NULL,
		[SessionToken] [uniqueidentifier] NOT NULL,
		[GigyaID] [nvarchar](40) NULL,
		[TotalPoliciesSold] [int] NOT NULL
	)
	create clustered index idx_cdgfactSession_BIRowID on [db-au-cmdwh].dbo.cdgfactSession(BIRowID)
	create nonclustered index idx_cdgfactSession_factSessionID on [db-au-cmdwh].dbo.cdgfactSession(factSessionID)
	create nonclustered index idx_cdgfactSession_SessionCreateDate on [db-au-cmdwh].dbo.cdgfactSession(SessionCreateDate ASC) include
	(
		factSessionID,
		BusinessUnitID,
		Domain,
		AffiliateCode
	)
	create nonclustered index idx_cdgfactSession_businessunitid on [db-au-cmdwh].dbo.cdgfactSession(BusinessUnitID,SessionCreateDate) include
	(
		[factSessionID],
		[IsPolicyPurchased]
	)
	create nonclustered index idx_cdgfactSession_SessionToken on [db-au-cmdwh].dbo.cdgfactSession(SessionToken)
end
else
	delete a
	from
		[db-au-cmdwh].dbo.cdgfactSession a
		inner join etl_cdgfactSession b on 
			a.factSessionID = b.FactSessionID

insert [db-au-cmdwh].dbo.cdgfactSession with(tablock)
(	
	[factSessionID],
	[BusinessUnitID],
	[CampaignID],
	[ParentFactSessionID],
	[SessionCreateDate],
	[SessionCloseDate],
	[AffiliateCode],
	[IsClosed],
	[IsPolicyPurchased],
	[Domain],
	[SessionToken],
	[GigyaID],
	[TotalPoliciesSold]
)
select
	[factSessionID],
	[BusinessUnitID],
	[CampaignID],
	[ParentFactSessionID],
	[SessionCreateDate],
	[SessionCloseDate],
	[AffiliateCode],
	[IsClosed],
	[IsPolicyPurchased],
	[Domain],
	[SessionToken],
	[GigyaID],
	[TotalPoliciesSold]
from
	etl_cdgfactSession

	





GO

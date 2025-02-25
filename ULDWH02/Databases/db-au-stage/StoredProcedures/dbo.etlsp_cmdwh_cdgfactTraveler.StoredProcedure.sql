USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_cdgfactTraveler]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_cdgfactTraveler]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180227
Prerequisite:   
Description:    Innate Impulse2 version 2 fact traveler table denormalisation, and load data to [db-au-cmdwh].dbo.cdgfactTraveler
Change History:
                20180227 - LT - Procedure created
						
*************************************************************************************************************************************/


if object_id('[db-au-stage].dbo.etl_cdgfactTraveler') is not null drop table [db-au-stage].dbo.etl_cdgfactTraveler

select
	q.factTravelerID,
	q.SessionID,
	qDate.DOB,
	q.IsAdult,
	q.IsChild,
	q.IsInfant,
	q.TreatAsAdultIndicator,
	q.AcceptedOfferIndicator,
	q.EMCAccepted,
	q.Age,
	q.FirstName,
	q.LastName,
	q.Gender
into [db-au-stage].dbo.etl_cdgfactTraveler
from
	cdg_factTraveler_AU q
	outer apply
	(
		select top 1 [Date] as DOB
		from dbo.cdg_dimDate_AU 
		where DimDateID = q.BirthDateDimDateID
	) qdate



if object_id('[db-au-cmdwh].dbo.cdgfactTraveler') is null
begin
	create table [db-au-cmdwh].[dbo].[cdgfactTraveler]
	(
		[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
		[factTravelerID] [int] NOT NULL,
		[SessionID] [int] NOT NULL,
		[DOB] [datetime] NULL,
		[IsAdult] [int] NOT NULL,
		[IsChild] [int] NOT NULL,
		[IsInfant] [int] NOT NULL,
		[TreatAsAdultIndicator] [int] NOT NULL,
		[AcceptedOfferIndicator] [int] NOT NULL,
		[EMCAccepted] [int] NOT NULL,
		[Age] [int] NOT NULL,
		[FirstName] [nvarchar](20) NULL,
		[LastName] [nvarchar](20) NULL,
		[Gender] [nvarchar](1) NULL
	)
	create clustered index idx_cdgfactTraveler_BIRowID on [db-au-cmdwh].dbo.cdgfactTraveler(BIRowID)
	create nonclustered index idx_cdgfactTraveler_factTravelerID on [db-au-cmdwh].dbo.cdgfactTraveler(factTravelerID)
	create nonclustered index idx_cdgfactTraveler_SessionID on [db-au-cmdwh].dbo.cdgfactTraveler(SessionID) include
	(
		[BIRowID],
		[factTravelerID],
		[DOB],
		[IsAdult],
		[IsChild],
		[IsInfant],
		[TreatAsAdultIndicator],
		[AcceptedOfferIndicator],
		[EMCAccepted],
		[Age],
		[FirstName],
		[LastName],
		[Gender]
	)
end
else
	delete a
	from
		[db-au-cmdwh].dbo.cdgfactTraveler a
		inner join etl_cdgfactTraveler b on 
			a.factTravelerID = b.factTravelerID 


insert [db-au-cmdwh].dbo.cdgfactTraveler with(tablock)
(
	[factTravelerID],
	[SessionID],
	[DOB],
	[IsAdult],
	[IsChild],
	[IsInfant],
	[TreatAsAdultIndicator],
	[AcceptedOfferIndicator],
	[EMCAccepted],
	[Age],
	[FirstName],
	[LastName],
	[Gender]
)
select
	[factTravelerID],
	[SessionID],
	[DOB],
	[IsAdult],
	[IsChild],
	[IsInfant],
	[TreatAsAdultIndicator],
	[AcceptedOfferIndicator],
	[EMCAccepted],
	[Age],
	[FirstName],
	[LastName],
	[Gender]
from
	etl_cdgfactTraveler



	





GO

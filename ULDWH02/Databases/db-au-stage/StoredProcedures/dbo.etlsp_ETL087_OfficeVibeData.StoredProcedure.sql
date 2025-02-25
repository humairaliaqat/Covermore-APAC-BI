USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL087_OfficeVibeData]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_ETL087_OfficeVibeData]
as

/************************************************************************************************************************************
Author:         Linus Tor
Date:           20170717
Prerequisite:   Office vibe data file is available.
Description:    Transform and insert office vibe data.
Parameters:		
				
Change History:
                20170717 - LT - Procedure created

*************************************************************************************************************************************/

SET NOCOUNT ON


update etl_OfficeVibesData
set [Month] = convert(varchar(10),dateadd(m,-1,convert(datetime,convert(varchar(8),getdate(),120)+'01')),120)


if object_id('[db-au-cmdwh].dbo.usrOfficeVibesEngagement') is null
begin
	create table [db-au-cmdwh].dbo.usrOfficeVibesEngagement
	(
		[Month] datetime null,
		[Team] varchar(200) null,
		Participation float null,
		Engagement float null,
		eNPS float null,
		Recognition float null,
		Ambassadorship float null,
		Feedback float null,
		RelationshipWithColleagues float null,
		RelationshipWithManagers float null,
		Satisfaction float null,
		CompanyAlignment float null,
		Happiness float null,
		Wellness float null,
		PersonalGrowth float null
	)
end
else 
	delete a
	from [db-au-cmdwh].dbo.usrOfficeVibesEngagement a
		inner join [db-au-stage].dbo.etl_OfficeVibesData b on 
			a.[Month] = b.[Month] and
			a.[Team] = b.[Groups]


insert [db-au-cmdwh].dbo.usrOfficeVibesEngagement
select
	convert(datetime,[Month]) as [Month],
	Groups as Team,
	convert(float,isnull(case when Participation = 'N/A' then NULL else Participation end,0)) as Participation,
	convert(float,isnull(case when Engagement = 'N/A' then NULL else Engagement end,0)) as Engagement,
	convert(float,isnull(case when eNPS = 'N/A' then NULL else eNPS end,0)) as eNPS,
	convert(float,isnull(case when Recognition = 'N/A' then NULL else Recognition end,0)) as Recognition,
	convert(float,isnull(case when Ambassadorship = 'N/A' then NULL else Ambassadorship end,0)) as Ambassadorship,
	convert(float,isnull(case when Feedback = 'N/A' then NULL else Feedback end,0)) as Feedback,
	convert(float,isnull(case when RelationshipWithColleagues = 'N/A' then NULL else RelationshipWithColleagues end,0)) as RelationshipWithColleagues,
	convert(float,isnull(case when RelationshipWithManagers = 'N/A' then NULL else RelationshipWithManagers end,0)) as RelationshipWithManagers,
	convert(float,isnull(case when Satisfaction = 'N/A' then NULL else Satisfaction end,0)) as Satisfaction,
	convert(float,isnull(case when CompanyAlignment = 'N/A' then NULL else CompanyAlignment end,0)) as CompanyAlignment,
	convert(float,isnull(case when Happiness = 'N/A' then NULL else Happiness end,0)) as Happiness,
	convert(float,isnull(case when Wellness = 'N/A' then NULL else Wellness end,0)) as Wellness,
	convert(float,isnull(case when PersonalGrowth = 'N/A' then NULL else PersonalGrowth end,0)) as PersonalGrowth
from  [db-au-stage].dbo.etl_OfficeVibesData
order by 1,2
GO

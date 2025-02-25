USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vOfficeVibesEngagement]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vOfficeVibesEngagement]
as

select
	c.Company,
	c.Division,
	c.Department,
	c.SubDepartment,	
	e.[Month],
	e.Team,
	e.Participation,
	e.Engagement,
	e.eNPS,
	e.Recognition,
	e.Ambassadorship,
	e.Feedback,
	e.RelationshipWithColleagues,
	e.RelationshipWithManagers,
	e.Satisfaction,
	e.CompanyAlignment,
	e.Happiness,
	e.Wellness,
	e.PersonalGrowth
from
	usrOfficeVibesEngagement e
	outer apply
	(
		select top 1 Company, Division, Department, SubDepartment
		from usrOfficeVibesCompany
		where Team = e.Team
	) c

GO

USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vpenGlobalSIMEmailAndAcceptance]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vpenGlobalSIMEmailAndAcceptance] as 
	with GlobalSimRequestSent as (        
		select dq.CountryKey, 
				dq.CompanyKey, 
				dq.DataID as PolicyID, 
				convert(datetime, dq.CreateDateTime) as GlobalSIMEmailDate, 
				row_number() over (partition by dq.CountryKey, dq.CompanyKey, dq.DataID order by dq.createDateTime) as ranked
		from penDataQueue dq
		inner join penJob j on dq.JobKey = j.JobKey
		where j.JobCode in
		(
			'AU_GLOBALSIM_CM',
			'AU_GLOBALSIM-EMAIL1_CM',
			'AU_GLOBALSIM-EMAIL2_CM',  
			'AU_GLOBALSIM_TIP',
			'AU_GLOBALSIM-EMAIL1_TIP',
			'AU_GLOBALSIM-EMAIL2_TIP',
			'NZ_GlobalSIM_CM',
			'NZ_GlobalSIM-EMAIL1_CM',
			'NZ_GlobalSIM-EMAIL2_CM'
		)
	) 
	select P.PolicyNumber, 
			O.AlphaCode, 
			gs.GlobalSIMEmailDate, 
			1 as EmailSent, 
			P.IssueDateNoTime,
			P.TripStart, 
			P.TripEnd, 
			P.TripDuration,
			CASE WHEN ags.PolicyKey IS NULL THEN 0 ELSE 1 END as GlobalSimOfferAccepted,
			ags.CreateDateTime as GlobalSimOfferAcceptedDate
	from GlobalSimRequestSent gs
	inner join penPolicy p on
		gs.CountryKey = p.CountryKey and
		gs.CompanyKey = p.CompanyKey and
		gs.PolicyID = p.PolicyID
	inner join penOutlet o on
		o.OutletAlphaKey = p.OutletAlphaKey and
		o.OutletStatus = 'Current'
	left join penPolicyGlobalSIM ags on 
		p.PolicyKey = ags.PolicyKey
	where gs.ranked = 1
GO

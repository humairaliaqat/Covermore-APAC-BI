USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt1073]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--/****************************************************************************************************/
----  Name				:	rptsp_rpt1073
----  Description		:	Age of Complaints Report
----  Author			:	Yi Yang
----  Date Created		:	20190712
----  Parameters		:	
----  Change History	:	
--/****************************************************************************************************/

create PROCEDURE [dbo].[rptsp_rpt1073]
AS 

begin

    set nocount on


select 
	w.ClaimNumber,
	w.Reference as e5Reference,
	w.PolicyNumber,
	case when w.WorkClassName = 'Complaints' then 'New' 
		when w.WorkClassName = 'IDR' then 'IDR' 
		else 'Unknown' end 
	as ProcessType,
	w.StatusName as Status,
	case when wp.EDRReferral = '1' then 'Yes' else 'No' end as HasEDRRef,
	convert(date, wp.ComplaintDateLodged) as ComplaintDateLodged,
	datediff(day, wp.ComplaintDateLodged, GETDATE()) as AgeOfComplaint

from 
	e5Work as w 

	outer apply 
		(
			select 
				max(case
                        when wp.Property_ID = 'ComplaintDateLodged' then convert(datetime, PropertyValue)
                        else null
                    end
                ) ComplaintDateLodged,	
				 max(
                    case
                        when wp.Property_ID = 'EDRReferral' then convert(varchar, PropertyValue)
                        else null
                    end
                ) EDRReferral
				
			from 
				e5WorkProperties wp with(nolock)
			where 
				w.Work_ID = wp.Work_ID
				and wp.Property_ID in
					('ComplaintDateLodged',
					'EDRReferral')
             ) wp

where 
	w.Country = 'AU'
	and w.WorkType = 'Complaints'
	and w.StatusName in ('Active', 'Diarised')

order by 
	AgeOfComplaint desc,
	w.StatusName,
	w.ClaimNumber

end
GO

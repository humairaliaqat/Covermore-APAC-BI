USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0445]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0445]
as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0445
--  Author:         Leonardus S
--  Date Created:   20130703
--  Description:    This stored procedure returns case with no contact in the last 48 hours
--  Parameters:     
--   
--  Change History: 20130703 - LS - Created
--                  20130806 - LS - Case 18810, exclude cases opened in the last 48 hours
--                  20130816 - LS - Case 18925, add more incident types
--
/****************************************************************************************************/

    select
        cc.CaseNo,
        cc.FirstName,
        cc.Surname,
        datediff(year, convert(datetime, decryptbykeyautocert(cert_id('EMCCertificate'), null, cc.DOB, 0, null)), cc.OpenDate) Age,
        cc.OpenDate,
        cc.TotalEstimate,
        cc.IncidentType,
        cc.ClaimNo,
        cc.Location,
        cc.Country,
        ln.Notes,
        ln.CreateTime,
        cc.ClientName,
        cc.CountryKey
    from
        cbCase cc
        --no note in the last 48 hour
        left join cbNote cn on
            cn.CaseKey = cc.CaseKey and
            cn.CreateDate >= convert(date, dateadd(day, -2, getdate())) and
            cn.CreateTime >= dateadd(hour, -48, getdate())
        --last note
        outer apply
        (
            select top 1 
                cn.Notes,
                cn.CreateTime
            from
                cbNote cn
            where
                cn.CaseKey = cc.CaseKey
            order by
                cn.CreateTime desc
        ) ln
    where
        cc.CaseStatus = 'Open' and
        cc.OpenDate < convert(date, dateadd(day, -2, getdate())) and
        cn.CaseKey is null and
        cc.ClientName in 
        (
            'CHUBB  INSURANCE',
            'COVERMORE INSUR. SERVICES',
            'COVERMORE -  NEW ZEALAND',
            'AAA AUTO CLUBS',
            'AUSTRALIA POST',
            'MEDIBANK',
            'ZURICH',
            'ACE INSURANCE',
            'CUST CARE CORP PROTECTION'
        ) and
        (
            (
                --Hospital / Evacuation
                cc.IncidentType like 'hos%' and 
                cc.IncidentType like '%eva%'
            ) or
            (
                --> $500 Claim/Incapacitation
                cc.IncidentType like '>%500 %' and
                cc.IncidentType like '%claim%' and
                cc.IncidentType like '%inc%'
            ) or
            (
                --Death O/S
                cc.IncidentType like 'death%' and
                (
                    cc.IncidentType like '%o/s%' or
                    cc.IncidentType like '%overseas%'
                )
            ) or
            --Disruption of Travel
            cc.IncidentType like 'disruption __ travel%' or
            cc.IncidentType in
            (
                'EMERGENCY ASSISTANCE',
                'EMERGENCY ASSISTANCE-DEATH',
                'EMERGENCY ASSISTANCE-SENSITIVE',
                'EVACUATION / REPATRIATION ',
                'EVACUATION/ REPATRIATION',
                'EVACUATION/REPATRIATION',
                'EVAC/REPAT',
                'MEDICAL ASSISTANCE'
            )
        ) and
        not
        (
            FirstName = 'Delete' and
            Surname = 'Delete'
        ) and
        cc.IsDeleted = 0

end



GO

USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vpenGlobalSIM]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE view [dbo].[vpenGlobalSIM] as
/****************************************************************************************************/  
--  Name:           vpenGlobalSIM
--  Author:         Leonardus S  
--  Date Created:   20131219
--  Description:    This view returns Global SIM distribution information
--  Change History:     
--                  20131219 - LS - Created 
--                                  at last, a unified business rule shareable between RPT0370 & RPT0428
--                                  this can also be consumed by universe and allow report bursting.
--                                  die 40+ schedules .. die
--                                  add IAL
--                  20131220 - LS - Case 19963, include the no-cover groups
--                  20140115 - LS - Case 20090, add outlet name
--                  20140204 - LS - consider cancellation date after trip start
--					20140206 - MS - Case 20215 , include helloworld custoes to CM, CM Nano, CM Italy, CM Italy Nano
--                  20140311 - LS - Case 20215, move all helloworld to it's own set
--                  20140312 - LS - TFS 11466, include Family & Friends (IU) in CM's file set
--                  20140513 - LS - Case 20827, replace null address
--					20141117 - LT - Case 22387, added JTN group to helloworld report set
--                  
/****************************************************************************************************/  

select
    o.CountryKey,
    o.AlphaCode,
    o.OutletName,
    o.GroupCode,
    o.GroupName,
    o.SubGroupCode,
    o.SubGroupName,
    p.PolicyKey,
    p.PolicyID,
    p.PolicyNumber,
    p.TripStart,
    p.TripEnd,
    gs.CreateDateTime OrderDate,
    rs.InclusionDate,
    rs.ReportSet,
    rsn.ReportSetName,
    gs.Status,
    gs.Comments,
    gs.FirstName,
    gs.Surname,
    CorrectAddress Address,
    CorrectSuburb Suburb,
    gs.State,
    gs.Postcode,
    gs.Email,
    gs.Mobile,
    gst.ItalyVisit,
    gst.NanoSIM
from
    penPolicyGlobalSIM gs
    inner join penPolicy p on
        p.PolicyKey = gs.PolicyKey
    outer apply 
    (
        select top 1
            ltrim(rtrim(ptv.AddressLine1)) PolicyAddress,
            ltrim(rtrim(ptv.Suburb)) PolicySuburb
        from
            penPolicyTraveller ptv
        where
            ptv.PolicyKey = p.PolicyKey and
            ptv.isPrimary = 1
    ) ptv
    cross apply
    (
        select
            case
                when ltrim(rtrim(gs.Address)) = 'null' or ltrim(rtrim(gs.Suburb)) = 'null' then ptv.PolicyAddress
                else ltrim(rtrim(gs.Address))
            end CorrectAddress,
            case
                when ltrim(rtrim(gs.Address)) = 'null' or ltrim(rtrim(gs.Suburb)) = 'null' then ptv.PolicySuburb
                else ltrim(rtrim(gs.Suburb))
            end CorrectSuburb
    ) ca
    inner join penOutlet o on
        o.OutletAlphaKey = p.OutletAlphaKey and
        o.OutletStatus = 'Current'
    cross apply
    (
        select
            isnull(gs.ItalyVisit, 'No') ItalyVisit,
            case
                when gs.TypeOfSimCard = 'Nano' then 'Yes'
                else 'No'
            end NanoSIM
    ) gst
    cross apply
    (
        select
            case
-- ----------------------------------------------------------------------------------------------- CM
                when 
                    o.CountryKey = 'AU' and
                    (
                        o.GroupCode in  ('CM', 'AA', 'CT', 'TT', 'TW', 'XA', 'ZA', 'YG', 'AR', 'IU') or
                        (
                            o.GroupCode = 'FL' and
                            o.SubGroupName in
                            (
                                'Campus Travel',
                                'Conference & Incentive Services (CIS)',
                                'Cruiseabout',
                                'The Corporate Traveller',
                                'Travel Money Oz',
                                'FCm Travel Solutions',
                                'FC Intrepid',
                                'Stage and Screen'
                            )
                        ) or
                        (
                            o.GroupCode = 'HW' and
                            o.SubGroupName in ('Travelex')
                        )
                    ) and
                    gst.ItalyVisit = 'No' and
                    gst.NanoSIM = 'No'
                then 5
-- ----------------------------------------------------------------------------------------------- CM Nano
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode in ('CM', 'AA', 'CT', 'TT', 'TW', 'XA', 'ZA', 'YG', 'TI', 'XA', 'FL', 'AR', 'HW', 'IU') and
                    o.SubGroupName not in ('Flight Centre', 'Flight Centre Website Sales') and
                    gst.ItalyVisit = 'No' and
                    gst.NanoSIM = 'Yes'
                then 7
-- ----------------------------------------------------------------------------------------------- CM Italy
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode in ('CM', 'AA', 'CT', 'TT', 'TW', 'XA', 'ZA', 'YG', 'TI', 'XA', 'FL', 'AR', 'HW', 'IU') and
                    o.SubGroupName not in ('Flight Centre', 'Flight Centre Website Sales') and
                    gst.ItalyVisit = 'Yes' and
                    gst.NanoSIM = 'No'
                then 8
-- ----------------------------------------------------------------------------------------------- CM Italy Nano
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode in ('CM', 'AA', 'CT', 'TT', 'TW', 'XA', 'ZA', 'YG', 'TI', 'XA', 'FL', 'AR', 'HW', 'IU') and
                    o.SubGroupName not in ('Flight Centre', 'Flight Centre Website Sales') and
                    gst.ItalyVisit = 'Yes' and
                    gst.NanoSIM = 'Yes'
                then 14
-- ----------------------------------------------------------------------------------------------- FL
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'FL' and
                    o.SubGroupName in ('Flight Centre', 'Flight Centre Website Sales')
                then 
                    case
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 1
-- ----------------------------------------------------------------------------------------------- FL Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 6
-- ----------------------------------------------------------------------------------------------- FL Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 15
-- ----------------------------------------------------------------------------------------------- FL Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 13
                    end
-- ----------------------------------------------------------------------------------------------- SF
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'FL' and
                    o.SubGroupName in ('Student Flights') and
                    gst.ItalyVisit = 'No' and
                    gst.NanoSIM = 'No'
                then 2
-- ----------------------------------------------------------------------------------------------- ET
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'FL' and
                    o.SubGroupName in ('Escape Travel', 'Escape Franchise') and
                    gst.ItalyVisit = 'No' and
                    gst.NanoSIM = 'No'
                then 3
-- ----------------------------------------------------------------------------------------------- TA
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'FL' and
                    o.SubGroupName in ('Travel Associates') and
                    gst.ItalyVisit = 'No' and
                    gst.NanoSIM = 'No'
                then 4
-- ----------------------------------------------------------------------------------------------- HW
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode in ('HW') and
                    o.SubGroupName in ('Harvey World Non-Branded', 'Harvey World Travel') and
                    gst.ItalyVisit = 'No' and
                    gst.NanoSIM = 'No'
                then 10
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode in ('TI') and
                    gst.ItalyVisit = 'No' and
                    gst.NanoSIM = 'No'
                then 
                    case
-- ----------------------------------------------------------------------------------------------- TI
                        when
                            o.SubGroupName in ('Cedar Jet Travel', 'Travelscene Insurance') and
                            o.AlphaCode not in 
                            (
                                'AESP100', 
                                'AESP110', 
                                'TIS1000', 
                                'TIS1032', 
                                'TIS1037', 
                                'TIS1038', 
                                'TIS1042', 
                                'TIS1043'
                            )
                        then 11
-- ----------------------------------------------------------------------------------------------- Hoffman
                        when 
                            o.AlphaCode in 
                            (
                                'AESP100', 
                                'AESP110', 
                                'TIS1000', 
                                'TIS1032', 
                                'TIS1037', 
                                'TIS1038', 
                                'TIS1042', 
                                'TIS1043'
                            )
                        then 12
                    end
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'MB'
                then
                    case
-- ----------------------------------------------------------------------------------------------- MB
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 16
-- ----------------------------------------------------------------------------------------------- MB Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 17
-- ----------------------------------------------------------------------------------------------- MB Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 18
-- ----------------------------------------------------------------------------------------------- MB Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 19
                    end
                when 
                    o.CountryKey = 'NZ' and
                    o.GroupCode = 'FL'
                then
                    case
-- ----------------------------------------------------------------------------------------------- NZ FC
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 20
-- ----------------------------------------------------------------------------------------------- NZ FC Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 21
-- ----------------------------------------------------------------------------------------------- NZ FC Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 22
-- ----------------------------------------------------------------------------------------------- NZ FC Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 23
                    end
                when 
                    o.CountryKey = 'NZ' and
                    o.GroupCode in ('CM', 'GH', 'AA', 'GO', 'HS', 'HW', 'TM', 'TS', 'UT', 'WA', 'CI', 'BK')
                then
                    case
-- ----------------------------------------------------------------------------------------------- NZ CM
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 24
-- ----------------------------------------------------------------------------------------------- NZ CM Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 25
-- ----------------------------------------------------------------------------------------------- NZ CM Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 26
-- ----------------------------------------------------------------------------------------------- NZ CM Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 27
                    end
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'AZ'
                then
                    case
-- ----------------------------------------------------------------------------------------------- AZ
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 29
-- ----------------------------------------------------------------------------------------------- AZ Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 30
-- ----------------------------------------------------------------------------------------------- AZ Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 31
-- ----------------------------------------------------------------------------------------------- AZ Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 32
                    end
                when 
                    o.CountryKey = 'NZ' and
                    o.GroupCode = 'AZ'
                then
                    case
-- ----------------------------------------------------------------------------------------------- NZ AZ
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 33
-- ----------------------------------------------------------------------------------------------- NZ AZ Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 34
-- ----------------------------------------------------------------------------------------------- NZ AZ Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 35
-- ----------------------------------------------------------------------------------------------- NZ AZ Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 36
                    end
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'RC'
                then
                    case
-- ----------------------------------------------------------------------------------------------- RC
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 37
-- ----------------------------------------------------------------------------------------------- RC Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 38
-- ----------------------------------------------------------------------------------------------- RC Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 39
-- ----------------------------------------------------------------------------------------------- RC Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 40
                    end
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'NI'
                then
                    case
-- ----------------------------------------------------------------------------------------------- NI
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 41
-- ----------------------------------------------------------------------------------------------- NI Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 42
-- ----------------------------------------------------------------------------------------------- NI Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 43
-- ----------------------------------------------------------------------------------------------- NI Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 44
                    end
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'SO'
                then
                    case
-- ----------------------------------------------------------------------------------------------- SO
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 45
-- ----------------------------------------------------------------------------------------------- SO Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 46
-- ----------------------------------------------------------------------------------------------- SO Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 47
-- ----------------------------------------------------------------------------------------------- SO Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 48
                    end
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode = 'SE'
                then
                    case
-- ----------------------------------------------------------------------------------------------- SE
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 49
-- ----------------------------------------------------------------------------------------------- SE Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 50
-- ----------------------------------------------------------------------------------------------- SE Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 51
-- ----------------------------------------------------------------------------------------------- SE Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 52
                    end
                when 
                    o.CountryKey = 'AU' and
                    o.GroupCode in ('HA', 'HF', 'HL', 'JT')
                then
                    case
-- ----------------------------------------------------------------------------------------------- helloworld
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'No'
                        then 53
-- ----------------------------------------------------------------------------------------------- helloworld Nano
                        when
                            gst.ItalyVisit = 'No' and
                            gst.NanoSIM = 'Yes'
                        then 54
-- ----------------------------------------------------------------------------------------------- helloworld Italy
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'No'
                        then 55
-- ----------------------------------------------------------------------------------------------- helloworld Italy Nano
                        when
                            gst.ItalyVisit = 'Yes' and
                            gst.NanoSIM = 'Yes'
                        then 56
                    end
                else null
            end ReportSet,
            case
                --sim ordered more than 15 days, only include on the 15 days prior to departure date
                when datediff(day, convert(date, gs.CreateDateTime), p.TripStart) > 15 then convert(date, dateadd(day, -15, p.TripStart))
                --sim ordered between 7 to 15 days prior departure date, include on next day
                else convert(date, dateadd(day, 1, gs.CreateDateTime))
            end InclusionDate
    ) rs
    cross apply
    (
        select
            case rs.ReportSet
                when 1 then 'FL'
                when 2 then 'SF'
                when 3 then 'ET'
                when 4 then 'TA'
                when 5 then 'CM'
                when 6 then 'FL Nano'
                when 7 then 'CM Nano'
                when 8 then 'Italy'
                when 9 then 'ULG'
                when 10 then 'HW'
                when 11 then 'TI'
                when 12 then 'Hoffman'
                when 13 then 'FL Italy Nano'
                when 14 then 'CM Italy Nano'
                when 15 then 'FL Italy'
                when 16 then 'MB'
                when 17 then 'MB Nano'
                when 18 then 'MB Italy'
                when 19 then 'MB Italy Nano'
                when 20 then 'NZ FC'
                when 21 then 'NZ FC Nano'
                when 22 then 'NZ FC Italy'
                when 23 then 'NZ FC Italy Nano'
                when 24 then 'NZ CM'
                when 25 then 'NZ CM Nano'
                when 26 then 'NZ CM Italy'
                when 27 then 'NZ CM Italy Nano'
                when 28 then 'NZ ULG'
                when 29 then 'AZ' --Air NZ
                when 30 then 'AZ Nano'
                when 31 then 'AZ Italy'
                when 32 then 'AZ Italy Nano'
                when 33 then 'NZ AZ'
                when 34 then 'NZ AZ Nano'
                when 35 then 'NZ AZ Italy'
                when 36 then 'NZ AZ Italy Nano'
                when 37 then 'RC' --RAC
                when 38 then 'RC Nano'
                when 39 then 'RC Italy'
                when 40 then 'RC Italy Nano'
                when 41 then 'NI' --NRMA
                when 42 then 'NI Nano'
                when 43 then 'NI Italy'
                when 44 then 'NI Italy Nano'
                when 45 then 'SO' --SGIO
                when 46 then 'SO Nano'
                when 47 then 'SO Italy'
                when 48 then 'SO Italy Nano'
                when 49 then 'SE' --SGIC
                when 50 then 'SE Nano'
                when 51 then 'SE Italy'
                when 52 then 'SE Italy Nano'
                when 53 then 'helloworld' --helloworld
                when 54 then 'helloworld Nano'
                when 55 then 'helloworld Italy'
                when 56 then 'helloworld Italy Nano'
            end ReportSetName
    ) rsn
where
    -- Active policies
    (
        p.StatusDescription = 'Active' or
        p.CancelledDate >= p.TripStart
    ) and

    -- International policies only
    p.AreaType = 'International' and
    p.Area not like '%inbound%' and

    -- Departure date must >= 7 days away
    p.TripStart >= dateadd(day, 7, convert(date, gs.CreateDateTime)) and

    -- Duration of trip >= 7 days
    p.TripDuration >= 7 
    
    -- non null addresses
    --and
    --CorrectAddress <> 'null' and
    --CorrectSuburb <> 'null'



GO

USE [db-au-star]
GO
/****** Object:  View [dbo].[vfactTicket]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO













CREATE view [dbo].[vfactTicket] as
select 
    OutletReference +
    convert(varchar(max), t.DateSK) + '-' +
    convert(varchar(max), t.DepartureDateSK) + '-' + 
    convert(varchar(max), t.DomainSK) + '-' +
    convert(varchar(max), t.OutletSK) + '-' +
    convert(varchar(max), t.DestinationSK) + '-' +
    convert(varchar(max), t.OriginSK) + '-' +
    convert(varchar(max), t.DurationSK) + '-' +
    convert(varchar(max), isnull(a.AreaSK, -1)) TicketSK,
    t.DateSK, 
    t.DepartureDateSK, 
    t.DomainSK, 
    t.OutletSK, 
    t.DestinationSK, 
    t.DurationSK, 
    t.OriginSK,
    isnull(a.AreaSK, -1) AreaSK,
    t.TicketCount, 
    --factTicket is International & TransTasman only
    --case
    --    when do.CountryCode = 'AU' and dd.Destination = 'Australia' and isnull(dddd.Destination, '') <> 'Australia' then t.TicketCount
    --    when do.CountryCode = 'NZ' and dd.Destination = 'New Zealand' and isnull(dddd.Destination, '') <> 'New Zealand' then t.TicketCount
    --    else 0
    --end InternationalTicketCount,
    case
        when do.CountryCode = 'AU' and dd.Destination = 'Australia' then t.TicketCount
        when do.CountryCode = 'NZ' and dd.Destination = 'New Zealand' then t.TicketCount
        else 0
    end InternationalTicketCount,
    t.InternationalTravellersCount, 
    t.Source,
    t.ReferenceNumber SourceReference,
    t.factTicketSK * 10 + 
    case
        when OutletReference = 'Point in time' then 0
        else 1
    end BIRowID,
    t.Gross_Fare GrossFare,
    t.Net_Fare NetFare,
    dd.Destination Origin, 
    dd.Continent, 
    dd.SubContinent, 
    dd.ABSArea, 
    dd.ABSCountry, 
    r.OutletReference,
    ltb.LeadTimeBandKey,
    ltb.LeadTimeBand,
    case
        when lt.LeadTime < -1 then -1
        when lt.LeadTime > 2000 then -1
        else lt.LeadTime
    end LeadTime
from
    factTicket t
    outer apply
    (
        select top 1 
            [Date]
        from
            Dim_Date id
        where
            id.Date_SK = t.DateSK
    ) id
    outer apply
    (
        select top 1
            ddd.[Date]
        from
            Dim_Date ddd
        where
            ddd.Date_SK = t.DepartureDateSK
    ) ddd
    outer apply
    (
        select  
            isnull(datediff(day, id.[Date], ddd.[Date]), -1) LeadTime
    ) lt
    outer apply
    (
        select
            case 
                when lt.LeadTime < 0 then 99999999
                when lt.LeadTime between 0 and 2 then 2
                when lt.LeadTime between 3 and 5 then 5
                when lt.LeadTime between 6 and 8 then 8
                when lt.LeadTime between 9 and 11 then 11
                when lt.LeadTime between 12 and 14 then 14
                when lt.LeadTime between 15 and 17 then 17
                when lt.LeadTime between 18 and 20 then 20
                when lt.LeadTime between 21 and 23 then 23
                when lt.LeadTime between 24 and 26 then 26
                when lt.LeadTime between 27 and 29 then 29
                when lt.LeadTime between 30 and 32 then 32
                when lt.LeadTime between 33 and 35 then 35
                when lt.LeadTime between 36 and 42 then 42
                when lt.LeadTime between 43 and 49 then 49 
                when lt.LeadTime between 50 and 56 then 56
                when lt.LeadTime between 57 and 63 then 63
                when lt.LeadTime between 64 and 70 then 70
                when lt.LeadTime between 71 and 92 then 92
                when lt.LeadTime between 93 and 123 then 123
                when lt.LeadTime between 124 and 153 then 153
                when lt.LeadTime between 154 and 183 then 183
                when lt.LeadTime between 184 and 213 then 213
                when lt.LeadTime between 214 and 243 then 243
                when lt.LeadTime between 244 and 274 then 274
                when lt.LeadTime between 275 and 304 then 304
                when lt.LeadTime between 305 and 335 then 335
                when lt.LeadTime between 336 and 359 then 359
                when lt.LeadTime between 360 and 366 then 366
                else 367
            end LeadTimeBandKey,
            case 
                when lt.LeadTime < 0 then 'Unknown'
                when lt.LeadTime between 0 and 2 then '2 days'
                when lt.LeadTime between 3 and 5 then '5 days'
                when lt.LeadTime between 6 and 8 then '8 days'
                when lt.LeadTime between 9 and 11 then '11 days'
                when lt.LeadTime between 12 and 14 then '14 days'
                when lt.LeadTime between 15 and 17 then '17 days'
                when lt.LeadTime between 18 and 20 then '20 days'
                when lt.LeadTime between 21 and 23 then '23 days'
                when lt.LeadTime between 24 and 26 then '26 days'
                when lt.LeadTime between 27 and 29 then '29 days'
                when lt.LeadTime between 30 and 32 then '32 days'
                when lt.LeadTime between 33 and 35 then '5 weeks'
                when lt.LeadTime between 36 and 42 then '6 weeks'
                when lt.LeadTime between 43 and 49 then '7 weeks' 
                when lt.LeadTime between 50 and 56 then '8 weeks'
                when lt.LeadTime between 57 and 63 then '9 weeks'
                when lt.LeadTime between 64 and 70 then '9 weeks'
                when lt.LeadTime between 71 and 92 then '10 weeks'
                when lt.LeadTime between 93 and 123 then '3 months'
                when lt.LeadTime between 124 and 153 then '4 months'
                when lt.LeadTime between 154 and 183 then '5 months'
                when lt.LeadTime between 184 and 213 then '6 months'
                when lt.LeadTime between 214 and 243 then '7 months'
                when lt.LeadTime between 244 and 274 then '8 months'
                when lt.LeadTime between 275 and 304 then '9 months'
                when lt.LeadTime between 305 and 335 then '10 months'
                when lt.LeadTime between 336 and 359 then '11 months'
                when lt.LeadTime between 360 and 366 then '12 months'
                else 'Greater than 12 months'
            end LeadTimeBand
    ) ltb
    left join dimDestination dd on 
        dd.DestinationSK = t.OriginSK
    --left join dimDestination dddd on 
    --    dddd.DestinationSK = t.DestinationSK
    left join dimDomain do on
        do.DomainSK = t.DomainSK
    outer apply
    (
        select
            case
                when dd.Destination = 'Afghanistan' then 'Area 2'
                when dd.Destination = 'Albania' then 'Area 2'
                when dd.Destination = 'Algeria' then 'Area 1'
                when dd.Destination = 'American Samoa' then 'Area 4'
                when dd.Destination = 'Andorra' then 'Area 2'
                when dd.Destination = 'Angola' then 'Area 1'
                when dd.Destination = 'Anguilla' then 'Area 1'
                when dd.Destination = 'Antarctica (Cruising)' then 'Area 1'
                when dd.Destination = 'Antarctica-Sightseeing Flight' then 'Area 5'
                when dd.Destination = 'Antigua and Barbuda' then 'Area 1'
                when dd.Destination = 'Antilles' then 'Area 1'
                when dd.Destination = 'Argentina' then 'Area 1'
                when dd.Destination = 'Armenia' then 'Area 2'
                when dd.Destination = 'Aruba' then 'Area 1'
                when dd.Destination = 'Ascension Island' then 'Area 1'
                when dd.Destination = 'Australia' then 'Area 5'
                when dd.Destination = 'Austria' then 'Area 2'
                when dd.Destination = 'Azerbaijan' then 'Area 2'
                when dd.Destination = 'Azores' then 'Area 1'
                when dd.Destination = 'Bahamas' then 'Area 1'
                when dd.Destination = 'Bahrain' then 'Area 2'
                when dd.Destination = 'Bangladesh' then 'Area 2'
                when dd.Destination = 'Barbados' then 'Area 1'
                when dd.Destination = 'Belarus' then 'Area 2'
                when dd.Destination = 'Belgium' then 'Area 2'
                when dd.Destination = 'Belize' then 'Area 1'
                when dd.Destination = 'Benin' then 'Area 1'
                when dd.Destination = 'Bermuda' then 'Area 1'
                when dd.Destination = 'Bhutan' then 'Area 2'
                when dd.Destination = 'Bolivia' then 'Area 1'
                when dd.Destination = 'Bosnia' then 'Area 2'
                when dd.Destination = 'Botswana' then 'Area 1'
                when dd.Destination = 'Brazil' then 'Area 1'
                when dd.Destination = 'Brunei' then 'Area 3'
                when dd.Destination = 'Bulgaria' then 'Area 2'
                when dd.Destination = 'Burkina Faso' then 'Area 1'
                when dd.Destination = 'Burundi' then 'Area 1'
                when dd.Destination = 'Cambodia' then 'Area 3'
                when dd.Destination = 'Cameroon' then 'Area 1'
                when dd.Destination = 'Canada' then 'Area 1'
                when dd.Destination = 'Canary Islands' then 'Area 2'
                when dd.Destination = 'Cape Verde' then 'Area 1'
                when dd.Destination = 'Cayman Islands' then 'Area 1'
                when dd.Destination = 'Central African Republic' then 'Area 1'
                when dd.Destination = 'Chad' then 'Area 1'
                when dd.Destination = 'Chile' then 'Area 1'
                when dd.Destination = 'China' then 'Area 2'
                when dd.Destination = 'Colombia' then 'Area 1'
                when dd.Destination = 'Congo (Republic of)' then 'Area 1'
                when dd.Destination = 'Cook Islands' then 'Area 4'
                when dd.Destination = 'Costa Rica' then 'Area 1'
                when dd.Destination = 'Croatia' then 'Area 2'
                when dd.Destination = 'Cuba' then 'Area 1'
                when dd.Destination = 'Cyprus' then 'Area 2'
                when dd.Destination = 'Czech Republic' then 'Area 2'
                when dd.Destination = 'Denmark' then 'Area 2'
                when dd.Destination = 'Djibouti' then 'Area 1'
                when dd.Destination = 'Domestic Cruise' then 'Area 4'
                when dd.Destination = 'Dominica' then 'Area 1'
                when dd.Destination = 'Dominican Rep.' then 'Area 1'
                when dd.Destination = 'East Timor' then 'Area 4'
                when dd.Destination = 'Ecuador' then 'Area 1'
                when dd.Destination = 'Egypt' then 'Area 1'
                when dd.Destination = 'El Salvador' then 'Area 1'
                when dd.Destination = 'England' then 'Area 3'
                when dd.Destination = 'Equatorial Guinea' then 'Area 1'
                when dd.Destination = 'Eritrea' then 'Area 1'
                when dd.Destination = 'Estonia' then 'Area 2'
                when dd.Destination = 'Ethiopia' then 'Area 1'
                when dd.Destination = 'Falkland Islands' then 'Area 1'
                when dd.Destination = 'Faroe Islands' then 'Area 2'
                when dd.Destination = 'Federated States of Micronesia' then 'Area 3'
                when dd.Destination = 'Fiji' then 'Area 4'
                when dd.Destination = 'Finland' then 'Area 2'
                when dd.Destination = 'France' then 'Area 2'
                when dd.Destination = 'French Polynesia' then 'Area 4'
                when dd.Destination = 'Gabon' then 'Area 1'
                when dd.Destination = 'Gambia' then 'Area 1'
                when dd.Destination = 'Georgia' then 'Area 2'
                when dd.Destination = 'Germany' then 'Area 2'
                when dd.Destination = 'Ghana' then 'Area 1'
                when dd.Destination = 'Gibraltar' then 'Area 2'
                when dd.Destination = 'Greece' then 'Area 2'
                when dd.Destination = 'Greenland' then 'Area 1'
                when dd.Destination = 'Grenada' then 'Area 1'
                when dd.Destination = 'Guam' then 'Area 1'
                when dd.Destination = 'Guatemala' then 'Area 1'
                when dd.Destination = 'Guernsey (Channel Islands)' then 'Area 3'
                when dd.Destination = 'Guinea' then 'Area 1'
                when dd.Destination = 'Guinea-Bissau' then 'Area 1'
                when dd.Destination = 'Guyana' then 'Area 1'
                when dd.Destination = 'Haiti' then 'Area 1'
                when dd.Destination = 'Herzegovina' then 'Area 2'
                when dd.Destination = 'Honduras' then 'Area 1'
                when dd.Destination = 'Hong Kong' then 'Area 2'
                when dd.Destination = 'Hungary' then 'Area 2'
                when dd.Destination = 'Iceland' then 'Area 2'
                when dd.Destination = 'India' then 'Area 2'
                when dd.Destination = 'Indonesia' then 'Area 4'
                when dd.Destination = 'Iran' then 'Area 2'
                when dd.Destination = 'Iraq' then 'Area 2'
                when dd.Destination = 'Israel' then 'Area 2'
                when dd.Destination = 'Italy' then 'Area 2'
                when dd.Destination = 'Ivory Coast' then 'Area 1'
                when dd.Destination = 'Jamaica' then 'Area 1'
                when dd.Destination = 'Japan' then 'Area 2'
                when dd.Destination = 'Jersey (Channel Island)' then 'Area 3'
                when dd.Destination = 'Jordan' then 'Area 2'
                when dd.Destination = 'Kazakhstan' then 'Area 2'
                when dd.Destination = 'Kenya' then 'Area 1'
                when dd.Destination = 'Kiribati' then 'Area 4'
                when dd.Destination = 'Korea (north)' then 'Area 2'
                when dd.Destination = 'Korea (south)' then 'Area 2'
                when dd.Destination = 'Kosovo' then 'Area 2'
                when dd.Destination = 'Kuwait' then 'Area 2'
                when dd.Destination = 'Kyrgyzstan' then 'Area 2'
                when dd.Destination = 'Laos' then 'Area 3'
                when dd.Destination = 'Latvia' then 'Area 2'
                when dd.Destination = 'Lebanon' then 'Area 2'
                when dd.Destination = 'Lesotho' then 'Area 1'
                when dd.Destination = 'Liberia' then 'Area 1'
                when dd.Destination = 'Libya' then 'Area 1'
                when dd.Destination = 'Liechtenstein' then 'Area 2'
                when dd.Destination = 'Lithuania' then 'Area 2'
                when dd.Destination = 'Luxembourg' then 'Area 2'
                when dd.Destination = 'Macau' then 'Area 2'
                when dd.Destination = 'Macedonia' then 'Area 2'
                when dd.Destination = 'Madagascar' then 'Area 1'
                when dd.Destination = 'Madeira' then 'Area 2'
                when dd.Destination = 'Malawi' then 'Area 1'
                when dd.Destination = 'Malaysia' then 'Area 3'
                when dd.Destination = 'Maldives' then 'Area 2'
                when dd.Destination = 'Mali' then 'Area 1'
                when dd.Destination = 'Malta' then 'Area 2'
                when dd.Destination = 'Marshall Islands' then 'Area 3'
                when dd.Destination = 'Martinique' then 'Area 1'
                when dd.Destination = 'Mauritania' then 'Area 1'
                when dd.Destination = 'Mauritius' then 'Area 1'
                when dd.Destination = 'Mexico' then 'Area 1'
                when dd.Destination = 'Moldova' then 'Area 2'
                when dd.Destination = 'Monaco' then 'Area 2'
                when dd.Destination = 'Mongolia' then 'Area 2'
                when dd.Destination = 'Montenegro' then 'Area 2'
                when dd.Destination = 'Morocco' then 'Area 1'
                when dd.Destination = 'Mozambique' then 'Area 1'
                when dd.Destination = 'Myanmar (Burma)' then 'Area 3'
                when dd.Destination = 'Namibia' then 'Area 1'
                when dd.Destination = 'Nauru' then 'Area 4'
                when dd.Destination = 'Nepal' then 'Area 2'
                when dd.Destination = 'Netherlands' then 'Area 2'
                when dd.Destination = 'Netherlands Antilles' then 'Area 1'
                when dd.Destination = 'New Caledonia' then 'Area 4'
                when dd.Destination = 'New Zealand' then 'Area 4'
                when dd.Destination = 'Nicaragua' then 'Area 1'
                when dd.Destination = 'Niger' then 'Area 1'
                when dd.Destination = 'Nigeria' then 'Area 1'
                when dd.Destination = 'Norfolk Island' then 'Area 4'
                when dd.Destination = 'Northern Ireland' then 'Area 3'
                when dd.Destination = 'Northern Marianas' then 'Area 3'
                when dd.Destination = 'Norway' then 'Area 2'
                when dd.Destination = 'Oman' then 'Area 2'
                when dd.Destination = 'Pakistan' then 'Area 2'
                when dd.Destination = 'Palau' then 'Area 3'
                when dd.Destination = 'Palestine' then 'Area 2'
                when dd.Destination = 'Panama' then 'Area 1'
                when dd.Destination = 'Papua New Guinea' then 'Area 4'
                when dd.Destination = 'Paraguay' then 'Area 1'
                when dd.Destination = 'Peru' then 'Area 1'
                when dd.Destination = 'Philippines' then 'Area 3'
                when dd.Destination = 'Poland' then 'Area 2'
                when dd.Destination = 'Portugal' then 'Area 2'
                when dd.Destination = 'Puerto Rico' then 'Area 1'
                when dd.Destination = 'Qatar' then 'Area 2'
                when dd.Destination = 'Republic of Ireland' then 'Area 3'
                when dd.Destination = 'Reunion' then 'Area 1'
                when dd.Destination = 'Romania' then 'Area 2'
                when dd.Destination = 'Russia' then 'Area 2'
                when dd.Destination = 'Rwanda' then 'Area 1'
                when dd.Destination = 'Samoa' then 'Area 4'
                when dd.Destination = 'São Tomé and Príncipe' then 'Area 1'
                when dd.Destination = 'Saudi Arabia' then 'Area 2'
                when dd.Destination = 'Scotland' then 'Area 3'
                when dd.Destination = 'Senegal' then 'Area 1'
                when dd.Destination = 'Serbia' then 'Area 2'
                when dd.Destination = 'Seychelles' then 'Area 1'
                when dd.Destination = 'Sierra Leone' then 'Area 1'
                when dd.Destination = 'Singapore' then 'Area 3'
                when dd.Destination = 'Slovakia' then 'Area 2'
                when dd.Destination = 'Slovenia' then 'Area 2'
                when dd.Destination = 'Solomon Islands' then 'Area 4'
                when dd.Destination = 'Somalia' then 'Area 1'
                when dd.Destination = 'South Africa' then 'Area 1'
                when dd.Destination = 'South Korea' then 'Area 2'
                when dd.Destination = 'South West Pacific Cruise' then 'Area 4'
                when dd.Destination = 'Spain' then 'Area 2'
                when dd.Destination = 'Sri Lanka' then 'Area 2'
                when dd.Destination = 'St. Kitts-Nevis' then 'Area 1'
                when dd.Destination = 'St. Lucia' then 'Area 1'
                when dd.Destination = 'St. Vincent & Grenadines' then 'Area 1'
                when dd.Destination = 'Sudan' then 'Area 1'
                when dd.Destination = 'Suriname' then 'Area 1'
                when dd.Destination = 'Swaziland' then 'Area 1'
                when dd.Destination = 'Sweden' then 'Area 2'
                when dd.Destination = 'Switzerland' then 'Area 2'
                when dd.Destination = 'Syria' then 'Area 2'
                when dd.Destination = 'Taiwan' then 'Area 2'
                when dd.Destination = 'Tajikistan' then 'Area 2'
                when dd.Destination = 'Tanzania' then 'Area 1'
                when dd.Destination = 'Thailand' then 'Area 3'
                when dd.Destination = 'Togo' then 'Area 1'
                when dd.Destination = 'Tonga' then 'Area 4'
                when dd.Destination = 'Trinidad & Tobago' then 'Area 1'
                when dd.Destination = 'Tunisia' then 'Area 1'
                when dd.Destination = 'Turkey' then 'Area 2'
                when dd.Destination = 'Turkmenistan' then 'Area 2'
                when dd.Destination = 'Tuvalu' then 'Area 4'
                when dd.Destination = 'Uganda' then 'Area 1'
                when dd.Destination = 'Ukraine' then 'Area 2'
                when dd.Destination = 'United Arab Emirates' then 'Area 2'
                when dd.Destination = 'United Kingdom' then 'Area 3'
                when dd.Destination = 'United States of America' then 'Area 1'
                when dd.Destination = 'Uruguay' then 'Area 1'
                when dd.Destination = 'Uzbekistan' then 'Area 2'
                when dd.Destination = 'Vanuatu' then 'Area 4'
                when dd.Destination = 'Vatican City' then 'Area 2'
                when dd.Destination = 'Venezuela' then 'Area 1'
                when dd.Destination = 'Vietnam' then 'Area 3'
                when dd.Destination = 'Virgin Islands' then 'Area 1'
                when dd.Destination = 'Wales' then 'Area 3'
                when dd.Destination = 'Western Samoa' then 'Area 4'
                when dd.Destination = 'Yemen' then 'Area 2'
                when dd.Destination = 'Zambia' then 'Area 1'
                when dd.Destination = 'Zimbabwe' then 'Area 1'
            end AreaNumber
    ) da
    outer apply
    (
        select top 1 
            AreaSK
        from
            dimArea a
        where
            a.Country = do.CountryCode and
            a.AreaNumber = da.AreaNumber
        order by
            AreaSK
    ) a
    cross apply
    (
        select 'Point in time' OutletReference
        union all
        select 'Latest alpha' OutletReference
    ) r
where
    t.DateSK >= 20130101














GO

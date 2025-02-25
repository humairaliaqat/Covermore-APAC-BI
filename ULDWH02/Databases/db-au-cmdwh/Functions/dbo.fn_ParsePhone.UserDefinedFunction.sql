USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_ParsePhone]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fn_ParsePhone] 
(
    @Domain varchar(5),
    @Country varchar(max), 
    @State varchar(max), 
    @Phone varchar(max)
)
returns @formatted table 
(
    CountryCode varchar(2),
    AreaCode varchar(5),
    PhoneNumber varchar(50),
    Formatted varchar(100),
    FullNumber varchar(100),
    Valid bit
)
as
begin

    declare 
        @length int,
        @countrycode varchar(2),
        @areacode varchar(5),
        @phonenumber varchar(50),
        @valid bit

    set @Phone = nullif(rtrim(ltrim(@Phone)), '')
    set @Phone = replace(replace(replace(replace(replace(replace(@Phone, ' ', ''), '(', ''), ')', ''), '-', ''), '+', ''), '.', '')


    set @length = len(@Phone)
    set @State = ltrim(rtrim(@State))
    
    select 
        @countrycode =
        case
            when @Country in ('Australia', 'AU', 'AUS') or (@Domain = 'AU' and isnull(@Country, '') = '') then
                case
                    when @Phone like '0011%' then substring(@Phone, 5, 2) --this is wrong, lookup valid country code
                    when @Phone like '61%' then '61'

                    when @length = 12 and @Phone like '0_04%' then '61'
                    when @length = 12 and @Phone like '610%' then '61'
                    when @length = 12 and @Phone like '061%' then '61'
                    when @length = 13 and @Phone like '6161%' then '61'
                    when @length <= 9 then '61'
                    when @length = 10 and @Phone like '0%' then '61'
                    when @length = 10 and @Phone like '22%' then '61'
                    when @length > 8 and @Phone like '1300%' then '61'
                    else ''
                end
            when @Country in ('New Zealand', 'NZ', 'NZL') or (@Domain = 'NZ' and isnull(@Country, '') = '') then
                case
                    when @Phone like '0011%' then substring(@Phone, 5, 2) --this is wrong, lookup valid country code

                    when @length >= 10 and @Phone like '64%' then '64'
                    when @length >= 11 and @Phone like '064%' then '64'
                    when @length <= 8 then '64'
                    when @length in (9, 10) and @Phone like '0%' then '64'
                    when @Phone not like '0%' and @length in (9, 10) then '64'

                    else ''
                end
            else ''
        end,
        @areacode =
        case
            when @Country in ('Australia', 'AU', 'AUS') or (@Domain = 'AU' and isnull(@Country, '') = '') then
                case
                    when @Phone like '0%' and @length <= 10 then left(@Phone, 2)
                    when @Phone not like '0%' and @length = 9 then '0' + left(@Phone, 1)
                    when @length = 11 then '0' + substring(@Phone, 3, 1)
                    when @length = 10 then left(@Phone, 2)
                    when @length = 9 then left(@Phone, 1)
                    when @Phone like '0011%' then ''
                    when @length = 12 and @Phone like '0_04%' then '04'
                    when @length = 12 and @Phone like '610%' then substring(@Phone, 3, 2)
                    when @length = 12 and @Phone like '061%' then '0' + substring(@Phone, 3, 1)
                    when @length = 13 and @Phone like '6161%' then '0' + substring(@Phone, 5, 1)

                    --state code lookup
                    when @length = 8 then 
                        case
                            when @State in ('NEW SOUTH WALES', 'NSW') then '02'
                            when @State in ('AUSTRALIAN CAPITAL TERRITORY', 'ACT') then '02'
                            when @State in ('VICTORIA', 'VIC') then '03'
                            when @State in ('TASMANIA', 'TAS') then '03'
                            when @State in ('QUEENSLAND', 'QLD') then '07'
                            when @State in ('WESTERN AUSTRALIA', 'WA') then '08'
                            when @State in ('SOUTH AUSTRALIA', 'SA') then '08'
                            when @State in ('NORTHERN TERRITORY', 'NT') then '08'
                            else ''
                        end
                    else ''
                end
            when @Country in ('New Zealand', 'NZ', 'NZL') or (@Domain = 'NZ' and isnull(@Country, '') = '') then
                case
                    when @Phone like '0011%' then ''

                    when @length >= 10 and @Phone like '640%' then '0' + substring(@Phone, 4, 1)
                    when @length >= 10 and @Phone like '64[1-9]%' then '0' + substring(@Phone, 3, 1)
                    when @length >= 11 and @Phone like '0640%' then '0' + substring(@Phone, 5, 1)
                    when @length >= 11 and @Phone like '064[1-9]%' then '0' + substring(@Phone, 4, 1)
                    when @length <= 11 and @Phone like '0%' then left(@Phone, 2)
                    when @length <= 9 then '0' + left(@Phone, 1)

                    else ''
                end
        end,
        @phonenumber =
        case
            when @Country in ('Australia', 'AU', 'AUS') or (@Domain = 'AU' and isnull(@Country, '') = '') then
                case
                    when @length = 12 and @Phone like '061%' then right(@Phone, 8)
                    when @length = 13 and @Phone like '6161%' then right(@Phone, 8)
                    when @length = 12 and @Phone like '610%' then right(@Phone, 8)
                    when @length = 12 and @Phone like '0_04%' then right(@Phone, 8)
                    when @length > 11 then @Phone
                    else right(@Phone, 8)
                end 
            when @Country in ('New Zealand', 'NZ', 'NZL') or (@Domain = 'NZ' and isnull(@Country, '') = '') then
                case
                    when @Phone like '64%' and @length = 10 then right(@Phone, 7)
                    when @Phone like '64%' and @length = 11 then right(@Phone, 8)
                    when @Phone like '0%' and @length = 10 then right(@Phone, 8)
                    when @Phone like '0%' and @length = 9 then right(@Phone, 7)
                    when @Phone not like '0%' and @length = 9 then right(@Phone, 8)
                    when @Phone not like '0%' and @length = 8 then right(@Phone, 7)


                    else ''
                end
        end,
        @valid =
        case
            when @Phone is null then 0

            --too short
            when @length < 7 then 0 

            --no number
            when @Phone not like '%[0-9]%' then 0 

            --repeated numbers
            when 
                len(replace(@Phone, '0', '')) < 4 or
                len(replace(@Phone, '1', '')) < 4 or
                len(replace(@Phone, '2', '')) < 4 or
                len(replace(@Phone, '3', '')) < 4 or
                len(replace(@Phone, '4', '')) < 4 or
                len(replace(@Phone, '5', '')) < 4 or
                len(replace(@Phone, '6', '')) < 4 or
                len(replace(@Phone, '7', '')) < 4 or
                len(replace(@Phone, '8', '')) < 4 or
                len(replace(@Phone, '9', '')) < 4 
            then 0

            --bogus
            when 
                @Phone like '%12345%' or
                @Phone like '%12121%' 
            then 0

        end 


    insert into @formatted
    (
        CountryCode,
        AreaCode,
        PhoneNumber,
        Formatted,
        FullNumber,
        Valid
    )
    select
        nullif(@countrycode, ''),
        nullif(@areacode, ''),
        nullif(@phonenumber, ''),
        case
            when @countrycode = '61' then @countrycode + ' ' + replace(@areacode, '0', '') + ' ' + left(@phonenumber, 4) + ' ' + right(@phonenumber, 4)
            when @countrycode = '64' then 
                @countrycode + ' ' + replace(@areacode, '0', '') + ' ' + left(@phonenumber, 4) + ' ' + 
                case 
                    when len(@phonenumber) = 7 then right(@phonenumber, 3)
                    when len(@phonenumber) = 8 then right(@phonenumber, 4)
                    else nullif(@phonenumber, '')
                end
            else nullif(@phonenumber, '')
        end,
        @Phone,
        case
            when nullif(@countrycode, '') is null then 0
            when nullif(@areacode, '') is null then 0
            else @valid
        end

    return

end




GO

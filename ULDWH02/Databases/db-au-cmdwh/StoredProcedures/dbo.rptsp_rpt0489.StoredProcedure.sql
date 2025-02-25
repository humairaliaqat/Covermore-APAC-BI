USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0489]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0489]
    @Country varchar(2) = 'NZ',
    @DateRange varchar(30) = 'Last Week',
    @StartDate date = null,
    @EndDate date = null,
    @AutoRun bit = 0

as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0489
--  Author:         Leonardus S
--  Date Created:   20131213
--  Description:    This stored procedure extracts Air NZ policies with Air Point calculation
--  Parameters:     @AgencyGroup: agency group code
--                  @ProductCode: policy product code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--
--  Change History: 20131213 - LS - Created
--                  20131216 - LS - member number validation, NZ (Dougall's) email
--                                  move logger to raw extractor
--                  20131227 - LS - include failed transfer
--                  20140225 - LS - fix APD rate
--                                  0-99    = 1 APD
--                                  100-149 = 2 APD
--                                  150-199 = 3 APD 
--                                  >=200     divide purchase price by 50 and round down to whole number.
--                                  Koru gets 50
--
/****************************************************************************************************/

--uncomment to debug
--declare 
--    @Country varchar(2),
--    @DateRange varchar(30),
--    @StartDate date,
--    @EndDate date,
--    @AutoRun bit
--select
--    @Country = 'NZ',
--    @DateRange = 'Fiscal Year-to-Date',
--    @SaveToLog = 1,
--    @AutoRun = 1

    set nocount on  
    
    declare 
        @dataStartDate date,
        @dataEndDate date,
        @dlt varchar(1),
        @timestamp datetime,
        @apdratio int,
        @filename varchar(31)
    declare
        @dump table
            (
                LineID int not null identity(1,1),
                Data nvarchar(max),
                PolicyTransactionKey varchar(41),
                PolicyNo int,
                MemberNumber varchar(25),
                GrossPremium money,
                OriginalGrossPremium money,
                APD decimal(7,2)
            )
            
    --constants
    set @dlt = '|'
    set @timestamp = getdate()
    set @apdratio = 50
    set @filename = 
        'NAL_Accrual.CVMR.' + 
        replace(
            replace(
                replace(
                    convert(varchar, @timestamp, 120), 
                    '-', 
                    ''
                ), 
                ':', 
                ''
            ),
            ' ',
            ''
        )
    
    /* get reporting dates */  
    if @DateRange = '_User Defined'  
        select   
            @dataStartDate = @StartDate,   
            @dataEndDate = @EndDate  
  
    else  
        select   
            @dataStartDate = StartDate,   
            @dataEndDate = EndDate  
        from   
            vDateRange  
        where   
            DateRange = @DateRange  

    --header
    insert into @dump(Data)
    select
        'H' + @dlt +                                                    --header flag
        'CVMR' + @dlt +                                                 --CM Business Partner Identifier
        'AP' + @dlt +                                                   --Air NZ programme code
        @Country + @dlt +                                               --Location code
        replace(convert(varchar, @timestamp, 103), '/', '') + @dlt +    --date generated
        right(replace(convert(varchar, @timestamp, 120), ':', ''), 6)   --date generated
        
    --detail definition
    insert into @dump(Data)
    select
        'C' + @dlt +                                                    --record type
        'INDEX' + @dlt +                                                --row index
        'AP_NUM' + @dlt +                                               --airpoints member id
        'TRAN_DATE' + @dlt +                                            --transaction date
        'POINT_CODE' + @dlt +                                           --point code
        'AP_AMT' + @dlt +                                               --APD amount
        'BPC_ID' + @dlt +                                               --business partner cutomer id
        'FIRST_NAME' + @dlt +                                           
        'LAST_NAME' + @dlt + 
        'TRAN_ID'                                                       --transaction id

    --detail
    insert into @dump(
        Data, 
        PolicyTransactionKey,
        PolicyNo,
        MemberNumber,
        OriginalGrossPremium,
        GrossPremium,
        APD
    )
    select 
        'D' + @dlt +                                                    --record type
        convert(
            varchar, 
            row_number() over (order by PolicyTransactionID)
        ) + @dlt +                                                      --row index
        isnull(ptv.MemberNumber, '') + @dlt +                           --airpoints member id
        replace(convert(varchar, pt.IssueDate, 103), '/', '') + @dlt +  --transaction date
        case
            when TransactionStatus like 'Cancelled%' then 'CVRA'
            else 'CVMA'
        end + @dlt +                                                    --point code
        convert(
            varchar,
            case
                when TransactionStatus = 'Active' and p.ProductCode = 'ANK' then 50
                when TransactionStatus = 'Active' then 
                    case
                        when GrossPremium < 100 then 1
                        when GrossPremium < 150 then 2
                        when GrossPremium < 200 then 3
                        else floor(GrossPremium / @apdratio)
                    end
                when 
                    TransactionStatus like 'Cancelled%' and 
                    round(OriginalGrossPremium + GrossPremium, 0) = 0 and
                    p.ProductCode = 'ANK' 
                then -50
                when 
                    TransactionStatus like 'Cancelled%' and 
                    round(OriginalGrossPremium + GrossPremium, 0) = 0 
                then 
                    case
                        when OriginalGrossPremium < 100 then -1
                        when OriginalGrossPremium < 150 then -2
                        when OriginalGrossPremium < 200 then -3
                        else -floor(OriginalGrossPremium / @apdratio)
                    end
                else 0
            end 
        ) + @dlt +                                                      --APD amount
        '' + @dlt +                                                     --business partner cutomer id
        isnull(ptv.FirstName, '') + @dlt +                              --first name                                           
        isnull(ptv.LastName, '') + @dlt +                               --last name                                           
        convert(varchar, pt.PolicyNumber),                              --transaction id
        PolicyTransactionKey,
        pt.PolicyNumber,
        MemberNumber,
        OriginalGrossPremium,
        GrossPremium,
        case
            when TransactionStatus = 'Active' and p.ProductCode = 'ANK' then 50
            when TransactionStatus = 'Active' then 
                case
                    when GrossPremium < 100 then 1
                    when GrossPremium < 150 then 2
                    when GrossPremium < 200 then 3
                    else floor(GrossPremium / @apdratio)
                end
            when 
                TransactionStatus like 'Cancelled%' and 
                round(OriginalGrossPremium + GrossPremium, 0) = 0 and
                p.ProductCode = 'ANK' 
            then -50
            when 
                TransactionStatus like 'Cancelled%' and 
                round(OriginalGrossPremium + GrossPremium, 0) = 0 
            then 
                case
                    when OriginalGrossPremium < 100 then -1
                    when OriginalGrossPremium < 150 then -2
                    when OriginalGrossPremium < 200 then -3
                    else -floor(OriginalGrossPremium / @apdratio)
                end
            else 0
        end APD
        
        
        --debug
        --,
        --TransactionType,
        --TransactionStatus,
        --replace(convert(varchar, pt.IssueDate, 103), '/', '') transactiondate,
        --case
        --    when TransactionStatus like 'Cancelled%' then 'CVRA'
        --    else 'CVMA'
        --end pointcode,
        --GrossPremium,
        --OriginalGrossPremium,
        --case
        --    when TransactionStatus = 'Active' then floor(GrossPremium / @apdratio)
        --    when TransactionStatus like 'Cancelled%' and round(OriginalGrossPremium + GrossPremium, 0) = 0 then -floor(OriginalGrossPremium / @apdratio)
        --    else 0
        --end apd,
        --'' businesspartnercstomerid,
        --ptv.FirstName,
        --ptv.LastName,
        --PolicyNumber
        
    from
        penOutlet o
        inner join penPolicyTransSummary pt on
            o.OutletAlphaKey = pt.OutletAlphaKey
        inner join penPolicy p on
            p.PolicyKey = pt.PolicyKey
        cross apply
        (
            select top 1
                FirstName,
                LastName,
                rtrim(ltrim(MemberNumber)) MemberNumber
            from
                penPolicyTraveller ptv
            where
                ptv.PolicyKey = p.PolicyKey and
                ptv.isPrimary = 1
            order by
                ptv.PolicyKey
        ) ptv
        outer apply
        (
            select 
                sum(r.GrossPremium) OriginalGrossPremium
            from
                penPolicyTransSummary r
            where
                r.PolicyKey = pt.PolicyKey and
                r.PolicyTransactionID = pt.ParentID
        ) r
    where
        OutletStatus = 'Current' and
        o.GroupCode = 'AZ' and
        o.CountryKey = @Country and
        p.AreaType = 'International' and
        pt.PostingDate <  dateadd(day, 1, @dataEndDate) and
        (
            (
                @AutoRun = 1 and
                not exists
                (
                    select 
                        null
                    from
                        usrRPT0489 l
                    where
                        l.xDataIDx = pt.PolicyTransactionKey and
                        l.xFailx = 0
                )
            ) or
            pt.PostingDate >= @dataStartDate
        ) and
        (
            @AutoRun = 0 or
            not exists
            (
                select 
                    null
                from
                    usrRPT0489 l
                where
                    l.xDataIDx = pt.PolicyTransactionKey and
                    l.xFailx = 0
            )
        ) and
        /* member number validation */
        MemberNumber is not null and
        MemberNumber <> '' and
        len(MemberNumber) <= 8 and
        isnumeric(MemberNumber + '.e0') = 1 and
        MemberNumber not like '%[^0-9]%'
    order by 
        PolicyTransactionID

    --tail
    insert into @dump(Data)
    select
        'T' + @dlt +                                                    --tail flag
        convert(
            varchar,
            sum(
                case
                    when PolicyTransactionKey is not null then 1
                    else 0
                end
            )
        ) + @dlt +                                                      --record counts
        convert(
            varchar,
            sum(
                case
                    when isnumeric(MemberNumber) = 1 then convert(bigint, MemberNumber)
                    else 0
                end
            )
        ) + @dlt +                                                    --member id checksum
        convert(
            varchar,
            sum(
                case
                    when PolicyTransactionKey is not null then APD
                    else 0
                end
            )
        )                                                               --total apd
    from
        @dump


    --log
    --if object_id('usrRPT0489') is null
    --begin

    --    create table usrRPT0489
    --    (
    --        BIRowID bigint identity(1,1) not null,
    --        xOutputFileNamex varchar(31) null,
    --        xDataIDx varchar(41) null,
    --        Data nvarchar(max) null
    --    )

    --    create clustered index idx_usrRPT0489_BIRowID on usrRPT0489(BIRowID)
    --    create nonclustered index idx_usrRPT0489_xDataIDx on usrRPT0489(xDataIDx)

    --end

    --return output
    select 
        Data,
        @filename xOutputFileNamex,
        PolicyTransactionKey xDataIDx
    from
        @dump
    order by
        LineID
    
end
GO

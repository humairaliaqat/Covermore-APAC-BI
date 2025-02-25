USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_dimPolicy_test007]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
  
CREATE procedure [dbo].[etlsp_ETL032_dimPolicy_test007]      
    @DateRange nvarchar(30),  
    @StartDate nvarchar(10),  
    @EndDate nvarchar(10)  
      
as  
begin  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20131115  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
                Requires [db-au-cmdwh].dbo.penPolicy table available  
Description:    dimPolicy dimension table contains Policy attributes.  
Parameters:        @DateRange:    Required. Standard date range or _User Defined  
                @StartDate:    Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01  
                @EndDate:    Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01  
Change History:  
                20131115 - LT - Procedure created  
                20140725 - LT - Amended merged statement  
                20140822 - PW - Added TripStart date clause to reduce orphaned travellers due to Posting Date differences  
                20140827 - LT - updated PolicyNumber to varchar(50)  
                20140905 - LS - refactoring  
                20141027 - PW - Cleaned string for excess, tripcost and cancellation cover  
                20150204 - LS - replace batch codes with standard batch logging  
                20160321 - LS - additional attributes, remove excess overhead from vDimPolicy  
                20160510 - LS - additional attributes, remove excess overhead from vDimPolicy  
                20160927 - LS - additional attributes on addons flags (based on latest premium)  
                20180307 - LL - add Underwriter  
                20180413 - LL - move UW to function  
    20211113 - VS - Add additional identifier in hashkey  
  
*************************************************************************************************************************************/  
  
--uncomment to debug  
/*  
declare @DateRange nvarchar(30)  
declare @StartDate nvarchar(10)  
declare @EndDate nvarchar(10)  
select @DateRange = '_User Defined', @StartDate = '2014-08-01', @EndDate = '2014-08-31'  
*/  
  
    set nocount on  
  
    declare  
        @batchid int,  
        @start date,  
        @end date,  
        @rptStartDate date,  
        @rptEndDate date,  
        @name varchar(50),  
        @sourcecount int,  
        @insertcount int,  
        @updatecount int  
  
    declare @mergeoutput table (MergeAction varchar(20))  
  
    select  
        @name = object_name(@@procid)  
  
    begin try  
      
        --check if this is running on batch  
  
        exec syssp_getrunningbatch  
            @SubjectArea = 'Policy Star',  
            @BatchID = @batchid out,  
            @StartDate = @start out,  
            @EndDate = @end out  
  
        exec syssp_genericerrorhandler  
            @LogToTable = 1,  
            @ErrorCode = '0',  
            @BatchID = @batchid,  
            @PackageID = @name,  
            @LogStatus = 'Running'  
  
        select   
            @rptStartDate = @start,   
            @rptEndDate = @end  
  
    end try  
      
    begin catch  
      
        --or manually  
      
        set @batchid = -1  
  
        --get date range  
        if @DateRange = '_User Defined'  
            select   
                @rptStartDate = @StartDate,   
                @rptEndDate = @EndDate  
        else  
            select   
                @rptStartDate = StartDate,  
                @rptEndDate = EndDate  
            from   
                [db-au-cmdwh].dbo.vDateRange  
            where   
                DateRange = @DateRange  
  
    end catch  
  
  
    --create dimPolicy if table does not exist  
    if object_id('[db-au-star].dbo.dimPolicy_test007') is null  
    begin  
      
        create table [db-au-star].dbo.dimPolicy_test007  
        (  
            PolicySK int identity(1,1) not null,  
            Country nvarchar(10) not null,  
            PolicyKey nvarchar(50) not null,  
            PolicyNumber varchar(50) not null,  
            PolicyStatus nvarchar(50) null,  
            IssueDate datetime null,  
            CancelledDate datetime null,  
            TripStart datetime null,  
            TripEnd datetime null,  
            GroupName nvarchar(100) null,  
            CompanyName nvarchar(100) null,  
            PolicyStart datetime null,  
            PolicyEnd datetime null,  
            Excess decimal(18,2) not null,  
            TripType nvarchar(50) null,  
            TripCost nvarchar(50) null,  
            isCancellation nvarchar(1) null,  
            CancellationCover nvarchar(50) null,  
            LoadDate datetime not null,  
            updateDate datetime null,  
            LoadID int not null,  
            updateID int null,  
            HashKey varbinary(30) null,  
            PurchasePath nvarchar(50) null,  
            MaxDuration int null,  
            TravellerCount int null,  
            AdultCount int null,  
            ChargedAdultCount int null,  
            TotalPremium float,  
            EMCFlag varchar(10),  
            MaxEMCScore decimal(18,2),  
            TotalEMCScore decimal(18,2),  
            CancellationFlag varchar(25),  
            CruiseFlag varchar(25),  
            ElectronicsFlag varchar(25),  
            LuggageFlag varchar(25),  
            MotorcycleFlag varchar(25),  
            RentalCarFlag varchar(25),  
            WinterSportFlag varchar(25),  
            Underwriter varchar(100),  
   CancellationPlusFlag varchar(100)  
        )  
  
        create clustered index idx_dimPolicy_PolicySK on [db-au-star].dbo.dimPolicy_test007(PolicySK)  
        create nonclustered index idx_dimPolicy_Country on [db-au-star].dbo.dimPolicy_test007(Country)  
        create nonclustered index idx_dimPolicy_PolicyKey on [db-au-star].dbo.dimPolicy_test007(PolicyKey)  
        create nonclustered index idx_dimPolicy_IssueDate on [db-au-star].dbo.dimPolicy_test007(IssueDate)  
        create nonclustered index idx_dimPolicy_PolicyStatus on [db-au-star].dbo.dimPolicy_test007(PolicyStatus)  
        create nonclustered index idx_dimPolicy_TripType on [db-au-star].dbo.dimPolicy_test007(TripType)  
        create nonclustered index idx_dimPolicy_HashKey on [db-au-star].dbo.dimPolicy_test007(HashKey)  
  
        set identity_insert [db-au-star].dbo.dimPolicy_test007 on  
  
        --populate dimension with default unknown values  
        insert [db-au-star].[dbo].[dimPolicy_test007]  
        (  
            PolicySK,  
            Country,  
            PolicyKey,  
            PolicyNumber,  
            PolicyStatus,  
            IssueDate,  
            CancelledDate,  
            TripStart,  
            TripEnd,  
            GroupName,  
            CompanyName,  
            PolicyStart,  
            PolicyEnd,  
            Excess,  
            TripType,  
            TripCost,  
            isCancellation,  
            CancellationCover,  
            LoadDate,  
            updateDate,  
            LoadID,  
            updateID,  
            HashKey  
        )  
        values  
        (  
            -1,  
            'UNKNOWN',  
            'UNKNOWN',  
            0,  
            'UNKNOWN',  
            null,  
            null,  
            null,  
            null,  
            'UNKNOWN',  
            'UNKNOWN',  
            null,  
            null,  
            0,  
            'UNKNOWN',  
            'UNKNOWN',  
            'N',  
            'UNKNOWN',  
            getdate(),  
            null,  
            @batchid,  
            null,  
            binary_checksum('UNKNOWN', 'UNKNOWN', '0', 'UNKNOWN', null, null, null, null, 'UNKNOWN', 'UNKNOWN', null, null, 0, 'UNKNOWN', 'UNKNOWN', 'N', 'UNKNOWN')  
        )  
  
        set identity_insert [db-au-star].dbo.dimPolicy_test007 off  
          
    end  
  
  
    if object_id('[db-au-stage].dbo.etl_dimPolicy') is not null   
        drop table [db-au-stage].dbo.etl_dimPolicy  
          
    select  
        isnull(d.CountryCode,'UNKNOWN') as Country,  
        p.PolicyKey,  
        p.PolicyNumber,  
        p.StatusDescription as PolicyStatus,  
        p.IssueDate,  
        p.CancelledDate,  
        p.TripStart,  
        p.TripEnd,  
        isnull(p.GroupName,'') GroupName,  
        isnull(p.CompanyName,'') CompanyName,  
        p.PolicyStart,  
        p.PolicyEnd,  
        [db-au-cmdwh].dbo.fn_StrToInt(REPLACE(ISNULL(p.Excess,''),'.00','')) Excess,  
        isnull(p.TripType,'UNKNOWN') TripType,  
        case when p.TripCost like '%unlimited%' THEN 1000000 ELSE [db-au-cmdwh].dbo.fn_StrToInt(REPLACE(ISNULL(p.TripCost,''),'.00',''))  
        end as TripCost,  
        case when p.isCancellation = 0 then 'N'  
             when p.isCancellation = 1 then 'Y'  
        end as isCancellation,  
        case when p.CancellationCover like '%unlimited%' THEN 1000000 ELSE [db-au-cmdwh].dbo.fn_StrToInt(REPLACE(ISNULL(p.CancellationCover,''),'.00',''))  
        end as CancellationCover,  
        convert(datetime,null) as LoadDate,  
        convert(datetime,null) as updateDate,  
        convert(int,null) as LoadID,  
        convert(int,null) as updateID,  
        convert(varbinary,null) as HashKey,  
        isnull(p.PurchasePath, 'Leisure') PurchasePath,  
        isnull(p.MaxDuration, 0) MaxDuration,  
        isnull(ptv.TravellerCount, 0) TravellerCount,  
        isnull(ptv.AdultCount, 0) AdultCount,  
        isnull(ptv.ChargedAdultCount, 0) ChargedAdultCount,  
        isnull(pt.TotalPremium, 0) TotalPremium,  
        case  
            when isnull(emc.HasEMC, 0) > 0 then 'Has EMC'  
            else 'No EMC'  
        end EMCFlag,  
        isnull(emc.TotalEMCScore, 0) TotalEMCScore,  
        isnull(emc.MaxEMCScore, 0) MaxEMCScore,  
        case   
            when isnull(pt.CancellationPremium, 0) = 0 then 'No Cancellation'  
            else 'Has Cancellation'  
        end CancellationFlag,  
        case   
            when isnull(pt.CruisePremium, 0) = 0 then 'No Cruise'  
            else 'Has Cruise'  
        end CruiseFlag,  
        case   
            when isnull(pt.ElectronicsPremium, 0) = 0 then 'No Electronics'  
            else 'Has Electronics'  
        end ElectronicsFlag,  
        case   
            when isnull(pt.LuggagePremium, 0) = 0 then 'No Luggage'  
            else 'Has Luggage'  
        end LuggageFlag,  
        case   
            when isnull(pt.MotorcyclePremium, 0) = 0 then 'No Motorcycle'  
            else 'Has Motorcycle'  
        end MotorcycleFlag,  
        case   
            when isnull(pt.RentalCarPremium, 0) = 0 then 'No Rental Car'  
            else 'Has Rental Car'  
        end RentalCarFlag,  
        case   
            when isnull(pt.WinterSportPremium, 0) = 0 then 'No Winter Sport'  
            else 'Has Winter Sport'  
        end WinterSportFlag,  
  
  case   
            when isnull(pt.CancellationPlusPremium, 0) = 0 then 'No CancellationPlusCover'  
            else 'Has CancellationPlusCover'  
        end CancellationPlusFlag,  
  
        [db-au-cmdwh].dbo.fn_GetUnderWriterCode  
        (  
            p.CompanyName,   
            p.CountryKey,   
            p.AlphaCode,   
            p.IssueDate  
        ) Underwriter  
  
        --case   
        --    when p.CompanyName = 'TIP' and (p.IssueDate < '2017-06-01' or (p.AlphaCode in ('APN0004', 'APN0005') and p.IssueDate < '2017-07-01')) then 'TIP-GLA'  
        --    when p.CompanyName = 'TIP' and (p.IssueDate >= '2017-06-01' or (p.AlphaCode in ('APN0004', 'APN0005') and p.IssueDate >= '2017-07-01')) then 'TIP-ZURICH'  
        --    when p.CountryKey in ('AU', 'NZ') and p.IssueDate >= '2009-07-01' and p.IssueDate < '2017-06-01' then 'GLA'  
        --    when p.CountryKey in ('AU', 'NZ') and p.IssueDate >= '2017-06-01' then 'ZURICH'   
        --    when p.CountryKey in ('AU', 'NZ') and p.IssueDate <= '2009-06-30' then 'VERO'   
        --    when p.CountryKey in ('UK') and p.IssueDate >= '2009-09-01' then 'ETI'   
        --    when p.CountryKey in ('UK') and p.IssueDate < '2009-09-01' then 'UKU'   
        --    when p.CountryKey in ('MY', 'SG') then 'ETIQA'   
        --    when p.CountryKey in ('CN') then 'CCIC'   
        --    when p.CountryKey in ('ID') then 'Simas Net'   
        --    when p.CountryKey in ('US') then 'AON'  
        --    else 'OTHER'   
        --end Underwriter  
  
    into [db-au-stage].dbo.etl_dimPolicy  
    from  
        [db-au-cmdwh].dbo.penPolicy p  
        left join [db-au-star].dbo.dimDomain d on  
            p.DomainID = d.DomainID  
        outer apply  
        (  
            select   
                sum(1) TravellerCount,  
                sum(  
                    case  
                        when ptv.isAdult = 1 then 1  
                        else 0  
                    end  
                ) AdultCount,  
                sum(  
                    case  
                        when ptv.AdultCharge >= 1 then 1  
                        else 0  
                    end  
                ) ChargedAdultCount  
            from  
                [db-au-cmdwh]..penPolicyTraveller ptv with(nolock)  
            where  
                ptv.PolicyKey = p.PolicyKey   
        ) ptv  
        outer apply  
        (  
            select   
                sum(pp.Premium) TotalPremium,  
                sum(isnull(CancellationPremium, 0)) CancellationPremium,  
                sum(isnull(CruisePremium, 0)) CruisePremium,  
                sum(isnull(ElectronicsPremium, 0)) ElectronicsPremium,  
                sum(isnull(LuggagePremium, 0)) LuggagePremium,  
                sum(isnull(MotorcyclePremium, 0)) MotorcyclePremium,  
                sum(isnull(RentalCarPremium, 0)) RentalCarPremium,  
                sum(isnull(WinterSportPremium, 0)) WinterSportPremium,  
    sum(isnull(CancellationPlusPremium, 0)) CancellationPlusPremium  
            from  
                [db-au-cmdwh].dbo.penPolicyTransSummary pt  
                inner join [db-au-cmdwh].dbo.vPenguinPolicyPremiums pp on  
                    pp.PolicyTransactionKey = pt.PolicyTransactionKey  
                outer apply  
                (  
                    select   
                        sum(  
                            case  
                                when pta.AddOnGroup = 'Cancellation' then pta.GrossPremium  
                                else 0  
                            end  
                        ) CancellationPremium,  
                        sum(  
                            case  
                                when pta.AddOnGroup = 'Cruise' then pta.GrossPremium  
                                else 0  
                            end  
                        ) CruisePremium,  
                        sum(  
                            case  
                                when pta.AddOnGroup = 'Electronics' then pta.GrossPremium  
                                else 0  
                            end  
                        ) ElectronicsPremium,  
                        sum(  
                            case  
                                when pta.AddOnGroup = 'Luggage' then pta.GrossPremium  
                                else 0  
                            end  
                        ) LuggagePremium,  
                        sum(  
                            case  
                                when pta.AddOnGroup = 'Motorcycle' then pta.GrossPremium  
                                else 0  
                            end  
                        ) MotorcyclePremium,  
                        sum(  
                            case  
                                when pta.AddOnGroup = 'Rental Car' then pta.GrossPremium  
                                else 0  
                            end  
                        ) RentalCarPremium,  
                        sum(  
                            case  
                                when pta.AddOnGroup = 'Winter Sport' then pta.GrossPremium  
                                else 0  
                            end  
                        ) WinterSportPremium,  
  
      sum(  
                            case  
                               when pta.AddOnGroup = 'Cancellation Plus Cover' then pta.GrossPremium  
                                else 0  
                            end  
                        ) CancellationPlusPremium  
  
                    from  
                        [db-au-cmdwh]..penPolicyTransAddOn pta  
                    where  
                        pta.PolicyTransactionKey = pt.PolicyTransactionKey  
                ) pta  
            where  
                pt.PolicyKey = p.PolicyKey  
        ) pt  
        outer apply  
        (  
            select   
                sum(1) HasEMC,  
                sum(ea.MedicalRisk) TotalEMCScore,  
                max(ea.MedicalRisk) MaxEMCScore  
            from  
                [db-au-cmdwh]..penPolicyTraveller ptv  
                inner join [db-au-cmdwh]..penPolicyTravellerTransaction ptt on  
                    ptt.PolicyTravellerKey = ptv.PolicyTravellerKey  
                inner join [db-au-cmdwh]..penPolicyEMC pe on  
                    pe.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey  
                inner join [db-au-cmdwh]..emcApplications ea on  
                    ea.ApplicationKey = pe.EMCApplicationKey  
            where  
                ptv.PolicyKey = p.PolicyKey and  
                ApprovalStatus = 'Covered'  
        ) emc  
    where  
        p.PolicyKey in   
        (  
            select distinct   
                PolicyKey  
            from   
                [db-au-cmdwh].dbo.penPolicyTransSummary  
            where   
                PostingDate between @rptStartDate and @rptEndDate  
                or p.TripStart between @rptStartDate and @rptEndDate  
        )  
  
  
    --Update HashKey value  
    update [db-au-stage].dbo.etl_dimPolicy  
    set   
        HashKey =   
            binary_checksum(  
                Country,   
                PolicyKey,   
                PolicyNumber,   
                PolicyStatus,   
                IssueDate,   
                CancelledDate,  
                TripStart,   
                TripEnd,   
                GroupName,   
                CompanyName,   
                PolicyStart,   
                PolicyEnd,   
                Excess,  
                TripType,   
                TripCost,   
                isCancellation,   
                CancellationCover,  
                TotalPremium,  
    EMCFlag,---- CHG0034974  
    TotalEMCScore, ---- CHG0034974  
     MaxEMCScore,---- CHG0034974  
    CancellationFlag, ---- CHG0034974  
    CruiseFlag,---- CHG0034974  
    ElectronicsFlag,---- CHG0034974  
    LuggageFlag,---- CHG0034974  
    MotorcycleFlag,---- CHG0034974  
    RentalCarFlag,---- CHG0034974  
    WinterSportFlag,---- CHG0034974  
       CancellationPlusFlag  
            )  
  
  
    select  
        @sourcecount = count(*)  
    from  
        [db-au-stage].dbo.etl_dimPolicy  
  
    begin transaction  
    begin try  
  
        -- Merge statement  
        merge into [db-au-star].dbo.dimPolicy_test007 as DST  
        using [db-au-stage].dbo.etl_dimPolicy as SRC  
        on (SRC.PolicyKey = DST.PolicyKey)  
  
        -- inserting new records  
        when not matched by target then  
        insert  
        (  
            Country,  
            PolicyKey,  
            PolicyNumber,  
            PolicyStatus,  
            IssueDate,  
            CancelledDate,  
            TripStart,  
            TripEnd,  
            GroupName,  
            CompanyName,  
            PolicyStart,  
            PolicyEnd,  
            Excess,  
            TripType,  
            TripCost,  
            isCancellation,  
            CancellationCover,  
            LoadDate,  
            updateDate,  
            LoadID,  
            updateID,  
            HashKey,  
            PurchasePath,  
            MaxDuration,  
            TravellerCount,  
            AdultCount,  
            ChargedAdultCount,  
            EMCFlag,  
            TotalEMCScore,  
            MaxEMCScore,  
            CancellationFlag,  
            CruiseFlag,  
          ElectronicsFlag,  
            LuggageFlag,  
            MotorcycleFlag,  
            RentalCarFlag,  
            WinterSportFlag,  
            Underwriter,  
   CancellationPlusFlag  
        )  
        values  
        (  
            SRC.Country,  
            SRC.PolicyKey,  
            SRC.PolicyNumber,  
            SRC.PolicyStatus,  
            SRC.IssueDate,  
            SRC.CancelledDate,  
            SRC.TripStart,  
            SRC.TripEnd,  
            SRC.GroupName,  
            SRC.CompanyName,  
            SRC.PolicyStart,  
            SRC.PolicyEnd,  
            SRC.Excess,  
            SRC.TripType,  
            SRC.TripCost,  
            SRC.isCancellation,  
            SRC.CancellationCover,  
            getdate(),  
            null,  
            @batchid,  
            null,  
            SRC.HashKey,  
            SRC.PurchasePath,  
            SRC.MaxDuration,  
            SRC.TravellerCount,  
            SRC.AdultCount,  
            SRC.ChargedAdultCount,  
            SRC.EMCFlag,  
            SRC.TotalEMCScore,  
            SRC.MaxEMCScore,  
            SRC.CancellationFlag,  
            SRC.CruiseFlag,  
            SRC.ElectronicsFlag,  
            SRC.LuggageFlag,  
            SRC.MotorcycleFlag,  
            SRC.RentalCarFlag,  
            SRC.WinterSportFlag,  
            SRC.Underwriter,  
      SRC.CancellationPlusFlag  
        )  
          
        -- update existing records where data has changed via HashKey  
        when matched and DST.HashKey <> SRC.HashKey then  
        update  
        set DST.PolicyStatus = SRC.PolicyStatus,  
            DST.IssueDate = SRC.IssueDate,  
            DST.CancelledDate = SRC.CancelledDate,  
            DST.TripStart = SRC.TripStart,  
            DST.TripEnd = SRC.TripEnd,  
            DST.GroupName = SRC.GroupName,  
            DST.CompanyName = SRC.CompanyName,  
            DST.PolicyStart  = SRC.PolicyStart,  
            DST.PolicyEnd = SRC.PolicyEnd,  
            DST.Excess  = SRC.Excess,  
            DST.TripType  = SRC.TripType,  
            DST.TripCost  = SRC.TripCost,  
            DST.isCancellation  = SRC.isCancellation,  
            DST.CancellationCover  = SRC.CancellationCover,  
            DST.UpdateDate = getdate(),  
            DST.PurchasePath = SRC.PurchasePath,  
            DST.MaxDuration = SRC.MaxDuration,  
            DST.TravellerCount = SRC.TravellerCount,  
            DST.AdultCount = SRC.AdultCount,  
            DST.ChargedAdultCount= SRC.ChargedAdultCount,  
            DST.EMCFlag= SRC.EMCFlag,  
            DST.TotalEMCScore= SRC.TotalEMCScore,  
            DST.MaxEMCScore= SRC.MaxEMCScore,  
            DST.CancellationFlag = SRC.CancellationFlag,  
            DST.CruiseFlag = SRC.CruiseFlag,  
            DST.ElectronicsFlag = SRC.ElectronicsFlag,  
            DST.LuggageFlag = SRC.LuggageFlag,  
            DST.MotorcycleFlag = SRC.MotorcycleFlag,  
            DST.RentalCarFlag = SRC.RentalCarFlag,  
            DST.WinterSportFlag = SRC.WinterSportFlag,  
            DST.Underwriter = SRC.Underwriter,  
   DST.CancellationPlusFlag = SRC.CancellationPlusFlag,  
            DST.UpdateID = @batchid  
              
        output $action into @mergeoutput;  
  
        select  
            @insertcount =  
                sum(  
                    case  
                        when MergeAction = 'insert' then 1  
                        else 0  
                    end  
                ),  
            @updatecount =  
                sum(  
                    case  
                        when MergeAction = 'update' then 1  
                        else 0  
                    end  
                )  
        from  
            @mergeoutput  
  
        if @batchid <> -1  
            exec syssp_genericerrorhandler  
                @LogToTable = 1,  
                @ErrorCode = '0',  
                @BatchID = @batchid,  
                @PackageID = @name,  
                @LogStatus = 'Finished',  
                @LogSourceCount = @sourcecount,  
    @LogInsertCount = @insertcount,  
                @LogUpdateCount = @updatecount  
  
    end try  
  
    begin catch  
  
        if @@trancount > 0  
            rollback transaction  
  
        if @batchid <> -1  
            exec syssp_genericerrorhandler  
                @SourceInfo = 'data refresh failed',  
                @LogToTable = 1,  
                @ErrorCode = '-100',  
                @BatchID = @batchid,  
                @PackageID = @name  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction  
  
end  
  
  
GO

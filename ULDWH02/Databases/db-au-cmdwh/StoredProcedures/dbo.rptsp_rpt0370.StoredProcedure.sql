USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0370]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0370]
    @ReportingPeriod varchar(30),
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @ReportSet int = 0,
    @UpdateStatus bit = 0

as
begin

/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0370
--  Author:         Linus Tor
--  Date Created:   20121017
--  Description:    This stored procedure returns policy and customer details with return date in specified range
--  Parameters:     @AgencyGroup: Agency group code
--                  @ReportingPeriod: Value is valid date range
--                  @StartDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--                  @EndDate: Enter if @ReportingPeriod = _User Defined. YYYY-MM-DD eg. 2010-01-01
--
--  Change History: 20121017 - LT - Created
--                  20121210 - LT - Changed FL expo policy duration >= 10 and FL non expo policy duration between 10 to 45 days
--                  20130107 - LT - Changed FL Top percent to 20%.
--                                  Added FL Trial Alpha policies.
--                  20130108 - LT - Changed NumberOfDays to >= 10 days for Trial Alphas
--                                  Changed Top percent to 25% for Non expo
--                                  Removed State as filter
--                  20130131 - LT - Removed FL Trial Alphas
--                                  Changed FL Other criteria to: Area in (1,2,3) AND Product = FCO
--                  20130211 - LT - Added condition for FL to include CMO product for subgroup = FL
--                  20130304 - LS - Rewrite based on new BRS
--                  20130305 - LS - Use sub group name, duplicates found between FL & CM
--                  20130306 - LS - strip time portion on gs.CreateDateTime
--                  20130307 - LS - BRS update (Amit's email), change time range
--                  20130311 - LS - ULG bug fix, send all request created from previous day
--                  20130318 - LS - Add ReportSet parameter, work around for 50 characters limit on BI 4 prompt value length
--                  20130321 - LS - Bug fix on ULG, wrong definition on Report Set 9
--                                  More information (to be consumed by ULG)
--                  20130404 - LS - TFS 8105, expand CM. This requires changing @GroupCode to multiple values
--                                  TFS 8106, new report sets
--                  20130412 - LS - bug fix on Report Set 12
--                  20130502 - LS - TFS 8381, change order to departure lead time limit from 10 to 12
--                  20130507 - LS - TFS 8381, bug fix
--                                  typo on original subgroups requirement
--                  20130520 - LS - bug fix, 7 days limitation should be based on order date instead of start date
--                  20130617 - LS - Case 18576, add mobile number to ULG report
--                  20130625 - LS - Case 18648, change lead time from 12 to 15 days
--                  20130723 - LS - TFS 9277, call penguin dispatch proc to mark policies being reported
--                  20130802 - LS - Case 18854, add report sets
--                                  13: Flight Centre, italy, nano sim
--                                  14: non Flight Centre, italy, nano sim
--                  20130924 - LT - Case 19129, updated linked server to correct SQL2012 listen server ([db-au-penguinsharp],
--                                  removed FL from ReportSet 8 and added report set
--                                  15: Flight centre, Italy, Standard/Micro SIM
--                  20131010 - LS - Introduce alpha level filtering, change Phill Hofmann & TI
--                                  TFS 9790
--                                  16: MB standard SIM report
--                                  17: MB Nano SIM report
--                                  18: MB Standard Italy SIM report
--                                  19: MB Nano Italy SIM report
--                  20131018 - LS - no code change, just to note that the changes on 20131010 fix an unknown bug with ULG
--                                  previously ULG data set excludes phil hoffman
--                  20131023 - LS - TFS 8001, Include YouGo in CM, CM Nano, Italy and Italy Nano
--                                  TFS 9772-9773, NZ
--                                  20: NZ FC
--                                  21: NZ FC Nano
--                                  22: NZ FC Italy
--                                  23: NZ FC Italy Nano
--                                  24: NZ CM
--                                  25: NZ CM Nano
--                                  26: NZ CM Italy
--                                  27: NZ CM Italy Nano
--                                  28: NZ ULG
--                  20131031 - LS - Change international filter to use Area Type
--                  20131119 - LS - TFS 10009 & 10010, include AirNZ in CM (A & NZ)
--                  20131206 - LS - cleanup, remove redundant logic (e.g. AA includes all subgroups)
--                                  19756, Split Air NZ on it's own
--                                  19758, Include RAC
--                                  29: AZ
--                                  30: AZ Nano
--                                  31: AZ Italy
--                                  32: AZ Italy Nano
--                                  33: NZ AZ
--                                  34: NZ AZ Nano
--                                  35: NZ AZ Italy
--                                  36: NZ AZ Italy Nano
--                                  37: RC
--                                  38: RC Nano
--                                  39: RC Italy
--                                  40: RC Italy Nano
--                  20131224 - LS - rewrite, use shareable business logic (in view)
--                                  from now on definitions will be on vpenGlobalSIM
--                                  pushed earlier on Magda's request
--                  20140107 - LS - bug fix, ULG dates
--                  20140108 - LS - bug fix, ULG dates supposed to be order date + 1
--                  20140110 - LS - bug fix, conditional checking for Penguin update 
--                                  @StartDate = @EndDate -> @rptStartDate = @rptEndDate
--                  20140115 - LS - potential bug fix, no date filter on report set 0 (not used yet)
--                                  add OutletName
--                  20140120 - LS - add logger
--                                  20090, modify to enable report bursting
--                  20140513 - LS - Case 20827, exclude null address for PMA files
--
/****************************************************************************************************/

--uncomment to debug
--declare
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10),
--    @ReportSet int,
--    @UpdateStatus bit

--select
--    @ReportingPeriod = 'Today',
--    @StartDate = null,
--    @EndDate = null,
--    @ReportSet = 0,
--    @UpdateStatus = 0

    set nocount on
    
    declare
        @rptStartDate smalldatetime,
        @rptEndDate smalldatetime,
        @notificationcount int

    /* get reporting dates */
    if @ReportingPeriod = '_User Defined'
        select
            @rptStartDate = @StartDate,
            @rptEndDate = @EndDate

    else
        select
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from
            vDateRange
        where
            DateRange = @ReportingPeriod

    /* cleanup temp tables */
    if object_id('tempdb..#result') is not null
        drop table #result
        
    select 
        @notificationcount = count(distinct p.PolicyKey)
    from
        penJob j
        inner join penDataQueue dq on
            dq.JobKey = j.JobKey
        inner join penPolicy p on
            dq.CountryKey = p.CountryKey and
            dq.CompanyKey = p.CompanyKey and
            dq.DataID = p.PolicyID
    where
        (
            (
                @ReportSet = 9 and
                dq.CountryKey = 'AU' and
                j.JobCode in
                    (
                        'AU_GLOBALSIM_CM',
                        'AU_GLOBALSIM-EMAIL1_CM',
                        'AU_GLOBALSIM-EMAIL2_CM',  
                        'AU_GLOBALSIM_TIP',
                        'AU_GLOBALSIM-EMAIL1_TIP',
                        'AU_GLOBALSIM-EMAIL2_TIP'
                    )
            ) or
            (
                @ReportSet = 28 and
                dq.CountryKey = 'NZ' and
                j.JobCode in
                    (
                        'NZ_GlobalSIM_CM',
                        'NZ_GlobalSIM-EMAIL1_CM',
                        'NZ_GlobalSIM-EMAIL2_CM'
                    )
            ) 
        ) and
        dq.CreateDateTime >= dateadd(day, -1, @rptStartDate) and 
        dq.CreateDateTime <  @rptEndDate
        
    select
        CountryKey,
        AlphaCode,
        OutletName,
        GroupCode,
        GroupName,
        SubGroupCode,
        SubGroupName,
        PolicyKey,
        PolicyID,
        PolicyNumber,
        TripStart,
        TripEnd,
        OrderDate,
        InclusionDate,
        ReportSet,
        ReportSetName,
        Status,
        Comments,
        FirstName,
        Surname,
        Address,
        Suburb,
        State,
        Postcode,
        Email,
        Mobile,
        ItalyVisit,
        NanoSIM,
        isnull(@notificationcount, 0) NotificationCount,
        @rptStartDate StartDate,
        @rptEndDate EndDate
    into #result
    from
        vpenGlobalSIM gs
    where
        (
            @ReportSet not in (9, 28) and
            ReportSet = @ReportSet and
            InclusionDate between @rptStartDate and @rptEndDate and
            Address <> 'null' and
            Suburb <> 'null'
        ) or
        (
            @ReportSet = 9 and
            CountryKey = 'AU' and
            OrderDate >= dateadd(day, -1, @rptStartDate) and 
            OrderDate <  @rptEndDate
        ) or
        (
            @ReportSet = 28 and
            CountryKey = 'NZ' and
            OrderDate >= dateadd(day, -1, @rptStartDate) and 
            OrderDate <  @rptEndDate
        ) or
        (
            @ReportSet = 0 and
            --CountryKey = @Country and
            InclusionDate between @rptStartDate and @rptEndDate and
            Address <> 'null' and
            Suburb <> 'null'
        )
        
    if object_id('usrRPT0370') is null
    begin

        create table usrRPT0370
        (
	        BIRowID bigint identity(1,1) not null,
	        PolicyKey varchar(41) null,
	        PolicyID int null,
	        ReportSet int null,
	        CreateDateTime datetime not null default getdate(),
	        UpdateDateTime datetime not null default getdate(),
	        Propagated bit not null default 0
        )

        create unique clustered index idx_usrRPT0370_BIRowID on usrRPT0370 (BIRowID)
        create nonclustered index idx_usrRPT0370_PolicyKey on usrRPT0370 (PolicyKey)
        create nonclustered index idx_usrRPT0370_Propagated on usrRPT0370 (Propagated) include (PolicyID, ReportSet)
        
    end
        
    insert into usrRPT0370
    (
        PolicyKey,
        PolicyID,
        ReportSet
    )
    select 
        PolicyKey,
        PolicyID,
        ReportSet
    from
        #result t
    where
        @UpdateStatus = 1 and
        not exists
        (
            select 
                null
            from
                usrRPT0370 r
            where
                r.PolicyKey = t.PolicyKey
        )

    select
        CountryKey,
        AlphaCode,
        OutletName,
        GroupCode,
        GroupName,
        SubGroupCode,
        SubGroupName,
        PolicyKey,
        PolicyID,
        PolicyNumber,
        TripStart,
        TripEnd,
        OrderDate,
        InclusionDate,
        ReportSet,
        ReportSetName,
        Status,
        Comments,
        FirstName,
        Surname,
        Address,
        Suburb,
        State,
        Postcode,
        Email,
        Mobile,
        ItalyVisit,
        NanoSIM,
        NotificationCount,
        StartDate,
        EndDate
    from
        #result
        
--alter trigger tr_PropagateGlobalSIM
--on  dbo.usrRPT0370
----with execute as 'covermore\appbobj'
--after insert
--as 
--begin

--	set nocount on
	
--	declare
--	    @rowid int,
--	    @policyid int,
--	    @reportset int
	
--	declare c_loop cursor local for
--	    select
--	        BIRowID,
--	        PolicyID,
--	        ReportSet
--	    from
--	        inserted
--	    where
--	        Propagated = 0
	
--	begin try
	
--	    open c_loop
	    
--	    fetch next from c_loop into 
--	        @rowid,
--	        @policyid,
--	        @reportset
	        
--	    while @@fetch_status = 0
--	    begin
	
--            if
--                isnull(@reportset, 0) not in (0, 9, 28) and /* ULG */
--                isnull(@reportset, 0) not in (16, 17, 18, 19) and /* MB */
--                isnull(@reportset, 0) not in (37, 38, 39, 40) /* RC */
--	        begin
        	
--		        exec [DB-AU-PENGUINSHARP].[AU_PenguinSharp_Active].dbo.wsUpdateAdditionalBenefitTransactionStatusBatch
--			        @policyIds = @policyid,
--			        @status = 'inprogress',
--			        @code = 'sim'
        			
--	        end
        	
--	        else
        	
--            if
--                (
--                    isnull(@reportset, 0) in (16, 17, 18, 19) or /* MB */
--                    isnull(@reportset, 0) in (37, 38, 39, 40) /* RC */
--                )

--	        begin
        	
--		        exec [DB-AU-PENGUINSHARP].[AU_TIP_PenguinSharp_Active].dbo.wsUpdateAdditionalBenefitTransactionStatusBatch
--			        @policyIds = @policyid,
--			        @status = 'inprogress',
--			        @code = 'sim'
        			
--	        end
        	
--            update usrRPT0370
--            set
--                Propagated = 1,
--                UpdateDateTime = getdate()
--            where
--                BIRowID = @rowid


--	        fetch next from c_loop into 
--	            @rowid,
--	            @policyid,
--	            @reportset

--        end
        
--        close c_loop
--        deallocate c_loop
        
--	end try
	
--	begin catch
--	end catch

--end


end
GO

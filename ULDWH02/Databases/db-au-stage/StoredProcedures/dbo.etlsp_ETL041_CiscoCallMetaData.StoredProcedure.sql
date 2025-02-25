USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL041_CiscoCallMetaData]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL041_CiscoCallMetaData]  
as
begin
/************************************************************************************************************************************
Author:         Leo
Date:           20160608
Prerequisite:   cisCallMetaData
Change History:
                20160608 - LL - created
				20170829 - VL - change server name from BHWFO01 to Ulsqmdbagl after infrastructure migration 
                
*************************************************************************************************************************************/

    set nocount on

    declare @SQL varchar(8000)
    
    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int
        
    declare @mergeoutput table (MergeAction varchar(20))

    exec syssp_getrunningbatch
        @SubjectArea = 'CISCO ODS',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    select
        @name = object_name(@@procid)
        
    exec syssp_genericerrorhandler 
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'
    
    --create table if not exists
    if object_id('[db-au-cmdwh].dbo.cisCallMetaData') is null
    begin
        
        create table [db-au-cmdwh].dbo.cisCallMetaData
        (
            [BIRowID] bigint not null identity(1,1),
            [MetaDataID] bigint not null,
            [SessionKey] nvarchar(50),
            [SessionID] numeric(18, 0),
            [CallType] varchar(10),
            [LocalStartTime] datetime,
            [Duration] int,
            [Username] nvarchar(60),
            [isTraining] bit,
            [isInbound] bit,
            [Team] nvarchar(60),
            [CompanyGroup] nvarchar(60),
            [Phone] nvarchar(70),
            [CCRef] nvarchar(2056),
            [EMCRef] nvarchar(2056),
            [ClaimRef] nvarchar(2056),
            [PolicyRef] nvarchar(2056),
            [CaseKey] nvarchar(20),
            [ApplicationKey] varchar(15),
            [ClaimKey] varchar(40),
            [PolicyTransactionKey] varchar(41),
            [ForcedAUPhone] varchar(20)
        ) 
            
        create clustered index idx_cisCallMetaData_BIRowID on [db-au-cmdwh].dbo.cisCallMetaData(BIRowID)
        create nonclustered index idx_cisCallMetaData_MetaDataID on [db-au-cmdwh].dbo.cisCallMetaData(MetaDataID)
        create nonclustered index idx_cisCallMetaData_SessionKey on [db-au-cmdwh].dbo.cisCallMetaData(SessionKey)
        create nonclustered index idx_cisCallMetaData_Phone on [db-au-cmdwh].dbo.cisCallMetaData(Phone) include(LocalStartTime,Duration,Username,CCRef,EMCRef,ClaimRef,PolicyRef,CaseKey,ApplicationKey,ClaimKey,PolicyTransactionKey)
        --create nonclustered index idx_cisCallMetaData_Policy on [db-au-cmdwh].dbo.cisCallMetaData(PolicyRef) include(LocalStartTime,Duration,Username,PolicyTransactionKey)
        --create nonclustered index idx_cisCallMetaData_Claim on [db-au-cmdwh].dbo.cisCallMetaData(ClaimRef) include(LocalStartTime,Duration,Username,ClaimKey)
        create nonclustered index idx_cisCallMetaData_CaseKey on [db-au-cmdwh].dbo.cisCallMetaData(CaseKey) include(LocalStartTime,Duration,Username,Phone)
        create nonclustered index idx_cisCallMetaData_ApplicationKey on [db-au-cmdwh].dbo.cisCallMetaData(ApplicationKey) include(LocalStartTime,Duration,Username,Phone)
        create nonclustered index idx_cisCallMetaData_ClaimKey on [db-au-cmdwh].dbo.cisCallMetaData(ClaimKey) include(LocalStartTime,Duration,Username,Phone)
        create nonclustered index idx_cisCallMetaData_PolicyTransactionKey on [db-au-cmdwh].dbo.cisCallMetaData(PolicyTransactionKey) include(LocalStartTime,Duration,Username,Phone)
        create nonclustered index idx_cisCallMetaData_LocalStartTime on [db-au-cmdwh].dbo.cisCallMetaData(LocalStartTime)
        create nonclustered index idx_cisCallMetaData_ForcedAUPhone on [db-au-cmdwh].dbo.cisCallMetaData(ForcedAUPhone) include(MetaDataID,Duration,LocalStartTime,Phone)
            
    end    

    
    if object_id('tempdb..#metadata') is not null
        drop table #metadata

    select
        *
	into #metadata
    from
        [db-au-cmdwh]..cisCallMetaData
    where
        1 = 0
	
	set @SQL =
		'
		select
			ID,
			CallType,
			LocalStartTime,
			Duration,
			Username,
			isTraining,
			isInbound,
			Team,
			CompanyGroup,
			Phone,
			CustomerCare,
			EMC,
			CLaim,
			Policy
		from
			openquery
			(
				Ulsqmdbagl,
				''
				select
					ID,
					(
						select top 1
							ct.name
						from
							SQMDB.dbo.CcrType ct
						where
							ct.id = r.ccrTypeFK
					) CallType,
					LocalStartTime,
					Duration,
					(
						select top 1
							skilltargetid
						from
							SQMDB.dbo.Person p
						where
							p.id = r.personFK
					) Username,
					isTraining,
					isInbound,
					(
						select top 1
							name
						from
							SQMDB.dbo.team t
						where
							t.id = r.teamFK
					) Team,
					(
						select top 1
							name
						from
							SQMDB.dbo.groups g
						where
							g.id = r.groupFK
					) CompanyGroup,
					case
						when len(ani) = 4 then dnis
						else ani
					end Phone,
					md.CustomerCare,
					md.EMC,
					md.Claim,
					md.Policy
				from
					SQMDB.dbo.CCR r
					outer apply
					(
						select 
							max
							(
								case
									when md.metaDataFieldFK = 1 then md.data
									else null
								end 
							) CustomerCare,
							max
							(
								case
									when md.metaDataFieldFK = 2 then md.data
									else null
								end 
							) EMC,
							max
							(
								case
									when md.metaDataFieldFK = 3 then md.data
									else null
								end 
							) Claim,
							max
							(
								case
									when md.metaDataFieldFK = 4 then md.data
									else null
								end 
							) Policy
						from
							SQMDB.dbo.MetaData md
						where
							md.ccrFK = r.id
					) md
				where
					LocalStartTime >= ''''' + convert(varchar(10), @start, 120) + ''''' and
					LocalStartTime <  dateadd(day, 1, ''''' + convert(varchar(10), @end, 120) + ''''') and
					(
						ani <> ''''Unknown'''' or
						CustomerCare is not null or
						emc is not null or
						claim is not null or
						policy is not null
					)
				''
			) t
		'
        
    insert into #metadata
	(
        [MetaDataID],
        [CallType],
        [LocalStartTime],
        [Duration],
        [Username],
        [isTraining],
        [isInbound],
        [Team],
        [CompanyGroup],
        [Phone],
        [CCRef],
        [EMCRef],
        [ClaimRef],
        [PolicyRef]
	)
    -- @SQL
    execute(@SQL)

	--link to cisco call
	update c
	set
		c.SessionKey = coalesce(t1.Sessionkey, t2.SessionKey, t3.SessionKey, t4.SessionKey),
		c.SessionID = coalesce(t1.SessionID, t2.SessionID, t3.SessionID, t4.SessionID)
	from
		#metadata c
		outer apply
		(
			select top 1 
				cd.SessionKey,
				cd.SessionID
			from
				[db-au-cmdwh]..cisCallData cd --with(index(idx_cisCallData_LoginID))
			where
                cd.LoginID = c.Username and
                cd.CallStartDateTime <= dateadd(second, 1, c.localStartTime) and --milisecond truncation on metadata part
                cd.CallEndDateTime >= dateadd(ms, c.Duration, c.localStartTime)
			order by
                cd.LoginID,
				cd.CallStartDateTime desc
        ) t1
		outer apply
		(
			select top 1 
				cd.SessionKey,
				cd.SessionID
			from
				[db-au-cmdwh]..cisCallData cd --with(index(idx_cisCallData_OriginatorNumber))
			where
                c.Phone not in ('Unknown', '') and
                cd.OriginatorNumber = c.Phone and
                cd.CallStartDateTime <= dateadd(second, 1, c.localStartTime) and
                cd.CallEndDateTime >= dateadd(ms, c.Duration, c.localStartTime)
			order by
                cd.OriginatorNumber,
				cd.CallStartDateTime desc
        ) t2
		outer apply
		(
			select top 1 
				cd.SessionKey,
				cd.SessionID
			from
				[db-au-cmdwh]..cisCallData cd --with(index(idx_cisCallData_LoginID))
			where
                cd.LoginID = c.Username and
                c.Phone not in ('Unknown', '') and
                cd.OriginatorNumber = c.Phone and
				cd.CallStartDateTime <= dateadd(minute, 1, c.localStartTime) and
                cd.CallStartDateTime >= dateadd(hour, -1, c.localStartTime)
			order by
                cd.LoginID,
				cd.CallStartDateTime desc
        ) t3
		outer apply
		(
			select top 1 
				cd.SessionKey,
				cd.SessionID
			from
				[db-au-cmdwh]..cisCallData cd --with(index(idx_cisCallData_LoginID))
			where
                len(c.Phone) = 4 and
                cd.LoginID = 
                    (
                        select top 1
                            AgentLogin
                        from
                            [db-au-cmdwh]..cisAgent with(nolock)
                        where
                            Extension = c.Phone and
                            (
                                DateInactive is null or
                                DateInactive >= c.localStartTime
                            )
                        order by
                            isnull(DateInactive, getdate())
                    ) and
                cd.Transfer = 1 and
                cd.CallStartDateTime < c.localStartTime and
                cd.CallEndDateTime >= dateadd(second, -30, c.localStartTime) and
                cd.CallEndDateTime < dateadd(second, 30, c.localStartTime)
			order by
                cd.LoginID,
				cd.CallStartDateTime desc
        ) t4

	--link to policy
    update c
	set
		c.PolicyTransactionKey = pt.PolicyTransactionKey
    from
        #metadata c
		cross apply
		(
			select top 1 
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..penPolicyTransSummary pt
			where
				pt.CountryKey = isnull(left(c.Team, 2), 'AU') and
				pt.IssueDate >= dateadd(year, -4, c.LocalStartTime) and
				(
					len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef))) > 8 or
					(
						len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef))) = 8 and
						[db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef) > 12600000
					)
				) and
				pt.PolicyNumber = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef))
		) pt

    update c
	set
		c.PolicyTransactionKey = pt.PolicyTransactionKey
    from
        #metadata c
		cross apply
		(
			select top 1 
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..penPolicyTransSummary pt
			where
				pt.CountryKey = isnull(left(c.Team, 2), 'AU') and
				pt.IssueDate >= dateadd(year, -4, c.LocalStartTime) and
				(
					len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef))) > 8 or
					(
						len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef))) = 8 and
						[db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef) > 12600000
					)
				) and
				pt.PolicyNumber = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef))
		) pt
	where
		c.PolicyTransactionKey is null

	update c
	set
		c.PolicyTransactionKey = pt.PolicyTransactionKey
    from
        #metadata c
		cross apply
		(
			select top 1 
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..penPolicyTransSummary pt
			where
				pt.CountryKey = isnull(left(c.Team, 2), 'AU') and
				pt.IssueDate >= dateadd(year, -4, c.LocalStartTime) and
				(
					len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef))) > 8 or
					(
						len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef))) = 8 and
						[db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef) > 12600000
					)
				) and
				pt.PolicyNumber = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef))
		) pt
	where
		c.PolicyTransactionKey is null
        
	update c
	set
		c.PolicyTransactionKey = pt.PolicyTransactionKey
    from
        #metadata c
		cross apply
		(
			select top 1 
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..penPolicyTransSummary pt
			where
				pt.CountryKey = isnull(left(c.Team, 2), 'AU') and
				pt.IssueDate >= dateadd(year, -4, c.LocalStartTime) and
				(
					len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef))) > 8 or
					(
						len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef))) = 8 and
						[db-au-cmdwh].dbo.fn_StrToInt(c.CCRef) > 12600000
					)
				) and
				pt.PolicyNumber = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef))
		) pt
	where
		c.PolicyTransactionKey is null

	--link to claim
	update c
	set
		c.ClaimKey = cl.Claimkey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cl.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cl.ClaimKey,
				cl.PolicyTransactionKey
			from
				[db-au-cmdwh]..clmClaim cl
			where
				cl.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cl.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef))) between 6 and 7 and
				cl.ClaimNo = [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef)
		) cl

	update c
	set
		c.ClaimKey = cl.Claimkey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cl.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cl.ClaimKey,
				cl.PolicyTransactionKey
			from
				[db-au-cmdwh]..clmClaim cl
			where
				cl.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cl.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef))) between 6 and 7 and
				cl.ClaimNo = [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef)
		) cl
	where
		c.ClaimKey is null

	update c
	set
		c.ClaimKey = cl.Claimkey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cl.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cl.ClaimKey,
				cl.PolicyTransactionKey
			from
				[db-au-cmdwh]..clmClaim cl
			where
				cl.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cl.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef))) between 6 and 7 and
				cl.ClaimNo = [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef)
		) cl
	where
		c.ClaimKey is null

	update c
	set
		c.ClaimKey = cl.Claimkey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cl.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cl.ClaimKey,
				cl.PolicyTransactionKey
			from
				[db-au-cmdwh]..clmClaim cl
			where
				cl.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cl.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef))) between 6 and 7 and
				cl.ClaimNo = [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef)
		) cl
	where
		c.ClaimKey is null

	--link emc
	update c
	set
		c.ApplicationKey = e.ApplicationKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, e.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				e.ApplicationKey,
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..emcApplications e
				left join [db-au-cmdwh]..penPolicyEMC pe on
					pe.EMCApplicationKey = e.ApplicationKey
				left join [db-au-cmdwh]..penPolicyTravellerTransaction ptt on
					ptt.PolicyTravellerTransactionKey = pe.PolicyTravellerTransactionKey
				left join [db-au-cmdwh]..penPolicyTransSummary pt on
					pt.PolicyTransactionKey = ptt.PolicyTransactionKey
			where
				e.CountryKey = isnull(left(c.Team, 2), 'AU') and
				e.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef))) = 8 and
				e.ApplicationID = [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef)
		) e

	update c
	set
		c.ApplicationKey = e.ApplicationKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, e.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				e.ApplicationKey,
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..emcApplications e
				left join [db-au-cmdwh]..penPolicyEMC pe on
					pe.EMCApplicationKey = e.ApplicationKey
				left join [db-au-cmdwh]..penPolicyTravellerTransaction ptt on
					ptt.PolicyTravellerTransactionKey = pe.PolicyTravellerTransactionKey
				left join [db-au-cmdwh]..penPolicyTransSummary pt on
					pt.PolicyTransactionKey = ptt.PolicyTransactionKey
			where
				e.CountryKey = isnull(left(c.Team, 2), 'AU') and
				e.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef))) = 8 and
				e.ApplicationID = [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef)
		) e
	where
		c.ApplicationKey is null

	update c
	set
		c.ApplicationKey = e.ApplicationKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, e.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				e.ApplicationKey,
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..emcApplications e
				left join [db-au-cmdwh]..penPolicyEMC pe on
					pe.EMCApplicationKey = e.ApplicationKey
				left join [db-au-cmdwh]..penPolicyTravellerTransaction ptt on
					ptt.PolicyTravellerTransactionKey = pe.PolicyTravellerTransactionKey
				left join [db-au-cmdwh]..penPolicyTransSummary pt on
					pt.PolicyTransactionKey = ptt.PolicyTransactionKey
			where
				e.CountryKey = isnull(left(c.Team, 2), 'AU') and
				e.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef))) = 8 and
				e.ApplicationID = [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef)
		) e
	where
		c.ApplicationKey is null

	update c
	set
		c.ApplicationKey = e.ApplicationKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, e.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				e.ApplicationKey,
				pt.PolicyTransactionKey
			from
				[db-au-cmdwh]..emcApplications e
				left join [db-au-cmdwh]..penPolicyEMC pe on
					pe.EMCApplicationKey = e.ApplicationKey
				left join [db-au-cmdwh]..penPolicyTravellerTransaction ptt on
					ptt.PolicyTravellerTransactionKey = pe.PolicyTravellerTransactionKey
				left join [db-au-cmdwh]..penPolicyTransSummary pt on
					pt.PolicyTransactionKey = ptt.PolicyTransactionKey
			where
				e.CountryKey = isnull(left(c.Team, 2), 'AU') and
				e.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef))) = 8 and
				e.ApplicationID = [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef)
		) e
	where
		c.ApplicationKey is null

	--link carebase
	update c
	set
		c.CaseKey = cc.CaseKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cc.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cc.CaseKey,
				cp.PolicyTransactionKey
			from
				[db-au-cmdwh]..cbCase cc
				outer apply
				(
					select top 1 
						cp.PolicyTransactionKey
					from
						[db-au-cmdwh]..cbPolicy cp
					where
						cp.CaseKey = cc.CaseKey and
						cp.IsMainPolicy = 1
				) cp
			where
				cc.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cc.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef))) = 10 and
				cc.CaseNo = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.CCRef))
		) cc

	update c
	set
		c.CaseKey = cc.CaseKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cc.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cc.CaseKey,
				cp.PolicyTransactionKey
			from
				[db-au-cmdwh]..cbCase cc
				outer apply
				(
					select top 1 
						cp.PolicyTransactionKey
					from
						[db-au-cmdwh]..cbPolicy cp
					where
						cp.CaseKey = cc.CaseKey and
						cp.IsMainPolicy = 1
				) cp
			where
				cc.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cc.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef))) = 10 and
				cc.CaseNo = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.PolicyRef))
		) cc
	where
		c.CaseKey is null

	update c
	set
		c.CaseKey = cc.CaseKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cc.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cc.CaseKey,
				cp.PolicyTransactionKey
			from
				[db-au-cmdwh]..cbCase cc
				outer apply
				(
					select top 1 
						cp.PolicyTransactionKey
					from
						[db-au-cmdwh]..cbPolicy cp
					where
						cp.CaseKey = cc.CaseKey and
						cp.IsMainPolicy = 1
				) cp
			where
				cc.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cc.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef))) = 10 and
				cc.CaseNo = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.ClaimRef))
		) cc
	where
		c.CaseKey is null

	update c
	set
		c.CaseKey = cc.CaseKey,
		c.PolicyTransactionKey = isnull(c.PolicyTransactionKey, cc.PolicyTransactionKey)
    from
        #metadata c
		cross apply
		(
			select top 1 
				cc.CaseKey,
				cp.PolicyTransactionKey
			from
				[db-au-cmdwh]..cbCase cc
				outer apply
				(
					select top 1 
						cp.PolicyTransactionKey
					from
						[db-au-cmdwh]..cbPolicy cp
					where
						cp.CaseKey = cc.CaseKey and
						cp.IsMainPolicy = 1
				) cp
			where
				cc.CountryKey = isnull(left(c.Team, 2), 'AU') and
				cc.CreateDate >= dateadd(year, -4, c.LocalStartTime) and
				len(convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef))) = 10 and
				cc.CaseNo = convert(varchar(max), [db-au-cmdwh].dbo.fn_StrToInt(c.EMCRef))
		) cc
	where
		c.CaseKey is null

    select 
        @sourcecount = count(*)
    from
        #metadata

    begin transaction

    begin try
            
        merge into [db-au-cmdwh].dbo.cisCallMetaData with(tablock) t
        using #metadata s on 
            s.MetaDataID = t.MetaDataID
                
        when matched then
            
            update
            set
				t.SessionKey = s.SessionKey,
				t.SessionID = s.SessionID,
				t.CallType = s.CallType,
				t.LocalStartTime = s.LocalStartTime,
				t.Duration = s.Duration,
				t.Username = s.Username,
				t.isTraining = s.isTraining,
				t.isInbound = s.isInbound,
				t.Team = s.Team,
				t.CompanyGroup = s.CompanyGroup,
				t.Phone = s.Phone,
				t.CCRef = s.CCRef,
				t.EMCRef = s.EMCRef,
				t.ClaimRef = s.ClaimRef,
				t.PolicyRef = s.PolicyRef,
				t.CaseKey = s.CaseKey,
				t.ApplicationKey = s.ApplicationKey,
				t.ClaimKey = s.ClaimKey,
				t.PolicyTransactionKey = s.PolicyTransactionKey,
                t.ForcedAUPhone = 
                    case
                        when s.Team = 'NZ Customer Service' then
                            case
                                when replace(s.Phone, '0', '') = '' then ''
                                when len(s.Phone) <= 6 then ''
                                when s.Phone like '64%' then s.Phone
                                when s.Phone like '61%' then s.Phone
                                when s.Phone like '061%' then right(s.Phone, len(s.Phone) - 1)
                                when len(s.Phone) = 7 and s.Phone not like '0%' and s.Phone not like '1999%' then '64' + s.Phone
                                when len(s.Phone) = 8 and s.Phone not like '0%' then '64' + s.Phone
                                when len(s.Phone) = 8 and s.Phone like '0%' then '64' + right(s.Phone, 7)
                                when len(s.Phone) = 9 and s.Phone not like '0%' then '64' + s.Phone
                                when len(s.Phone) = 9 and s.Phone like '000%' then '64' + right(s.Phone, 6)
                                when len(s.Phone) = 9 and s.Phone like '00%' then '64' + right(s.Phone, 7)
                                when len(s.Phone) = 9 then '64' + right(s.Phone, 8)
                                when len(s.Phone) = 10 and s.Phone not like '0%' then '64' + s.Phone
                                when len(s.Phone) = 10 and s.Phone like '000%' then '64' + right(s.Phone, 7)
                                when len(s.Phone) = 10 and s.Phone like '00%' then '64' + right(s.Phone, 8)
                                when len(s.Phone) = 10 then '64' + right(s.Phone, 9)
                                when s.Phone like '000000%' then '64' + right(s.Phone, len(s.Phone) - 6)
                                when s.Phone like '00000%' then '64' + right(s.Phone, len(s.Phone) - 5)
                                when s.Phone like '0000%' then '64' + right(s.Phone, len(s.Phone) - 4)
                                when s.Phone like '000%' then '64' + right(s.Phone, len(s.Phone) - 3)
                                when s.Phone like '00%' then '64' + right(s.Phone, len(s.Phone) - 2)
                                else ''
                            end
                        when len(s.Phone) >= 9 then '61' + right(s.Phone, 9)
                        else ''
                    end 
                    
        when not matched by target then
            insert 
            (
				MetaDataID,
				SessionKey,
				SessionID,
				CallType,
				LocalStartTime,
				Duration,
				Username,
				isTraining,
				isInbound,
				Team,
				CompanyGroup,
				Phone,
				CCRef,
				EMCRef,
				ClaimRef,
				PolicyRef,
				CaseKey,
				ApplicationKey,
				ClaimKey,
				PolicyTransactionKey,
                ForcedAUPhone
            )
            values
            (
				s.MetaDataID,
				s.SessionKey,
				s.SessionID,
				s.CallType,
				s.LocalStartTime,
				s.Duration,
				s.Username,
				s.isTraining,
				s.isInbound,
				s.Team,
				s.CompanyGroup,
				s.Phone,
				s.CCRef,
				s.EMCRef,
				s.ClaimRef,
				s.PolicyRef,
				s.CaseKey,
				s.ApplicationKey,
				s.ClaimKey,
				s.PolicyTransactionKey,
                case
                    when s.Team = 'NZ Customer Service' then
                        case
                            when replace(s.Phone, '0', '') = '' then ''
                            when len(s.Phone) <= 6 then ''
                            when s.Phone like '64%' then s.Phone
                            when s.Phone like '61%' then s.Phone
                            when s.Phone like '061%' then right(s.Phone, len(s.Phone) - 1)
                            when len(s.Phone) = 7 and s.Phone not like '0%' and s.Phone not like '1999%' then '64' + s.Phone
                            when len(s.Phone) = 8 and s.Phone not like '0%' then '64' + s.Phone
                            when len(s.Phone) = 8 and s.Phone like '0%' then '64' + right(s.Phone, 7)
                            when len(s.Phone) = 9 and s.Phone not like '0%' then '64' + s.Phone
                            when len(s.Phone) = 9 and s.Phone like '000%' then '64' + right(s.Phone, 6)
                            when len(s.Phone) = 9 and s.Phone like '00%' then '64' + right(s.Phone, 7)
                            when len(s.Phone) = 9 then '64' + right(s.Phone, 8)
                            when len(s.Phone) = 10 and s.Phone not like '0%' then '64' + s.Phone
                            when len(s.Phone) = 10 and s.Phone like '000%' then '64' + right(s.Phone, 7)
                            when len(s.Phone) = 10 and s.Phone like '00%' then '64' + right(s.Phone, 8)
                            when len(s.Phone) = 10 then '64' + right(s.Phone, 9)
                            when s.Phone like '000000%' then '64' + right(s.Phone, len(s.Phone) - 6)
                            when s.Phone like '00000%' then '64' + right(s.Phone, len(s.Phone) - 5)
                            when s.Phone like '0000%' then '64' + right(s.Phone, len(s.Phone) - 4)
                            when s.Phone like '000%' then '64' + right(s.Phone, len(s.Phone) - 3)
                            when s.Phone like '00%' then '64' + right(s.Phone, len(s.Phone) - 2)
                            else ''
                        end
                    when len(s.Phone) >= 9 then '61' + right(s.Phone, 9)
                    else ''
                end 
            )

        output $action into @mergeoutput
        ;

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
                
        exec syssp_genericerrorhandler 
            @SourceInfo = 'cisCallMetaData data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name
            
    end catch    

    if @@trancount > 0
        commit transaction
            
end
GO

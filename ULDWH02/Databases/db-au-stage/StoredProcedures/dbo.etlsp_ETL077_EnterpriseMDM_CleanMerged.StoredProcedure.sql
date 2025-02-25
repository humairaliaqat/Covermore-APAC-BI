USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL077_EnterpriseMDM_CleanMerged]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL077_EnterpriseMDM_CleanMerged]
as
begin

    if object_id('tempdb..#cleanupmerged') is not null
        drop table #cleanupmerged

    select top 50000 
        CustomerID,
		MergedTo
    into #cleanupmerged
    from
        [db-au-cmdwh]..entCustomer
    where
        CustomerID <> MergedTo
    order by
        UpdateDate

    delete
    from
        [db-au-cmdwh]..entAccounts
    where
        CustomerID in (select CustomerID from #cleanupmerged)

    delete
    from
        [db-au-cmdwh]..entAddress
    where
        CustomerID in (select CustomerID from #cleanupmerged)

    delete
    from
        [db-au-cmdwh]..entAssociation
    where
        CustomerID in (select CustomerID from #cleanupmerged)

    delete
    from
        [db-au-cmdwh]..entEmail
    where
        CustomerID in (select CustomerID from #cleanupmerged)

    delete
    from
        [db-au-cmdwh]..entIdentity
    where
        CustomerID in (select CustomerID from #cleanupmerged)

    delete
    from
        [db-au-cmdwh]..entPhone
    where
        CustomerID in (select CustomerID from #cleanupmerged)

    delete
    from
        [db-au-cmdwh]..entPolicy
    where
        CustomerID in (select CustomerID from #cleanupmerged)

    delete
    from
        [db-au-cmdwh]..entCustomerDemography
    where
        CustomerID in (select CustomerID from #cleanupmerged)

	--update these tables
--cbCase
--clmClaimFlags
--emcApplicants
--lcLiveChat

	update t
	set
		t.CustomerID = r.MergedTo
	from
		[db-au-cmdwh]..cbCase t
		inner join #cleanupmerged r on
			r.CustomerID = t.CustomerID

	update t
	set
		t.CustomerID = r.MergedTo
	from
		[db-au-cmdwh]..clmClaimFlags t
		inner join #cleanupmerged r on
			r.CustomerID = t.CustomerID

	update t
	set
		t.CustomerID = r.MergedTo
	from
		[db-au-cmdwh]..emcApplicants t
		inner join #cleanupmerged r on
			r.CustomerID = t.CustomerID

	update t
	set
		t.CustomerID = r.MergedTo
	from
		[db-au-cmdwh]..lcLiveChat t
		inner join #cleanupmerged r on
			r.CustomerID = t.CustomerID

    delete
    from
        [db-au-cmdwh]..entCustomer
    where
        CustomerID in (select CustomerID from #cleanupmerged)



    update cc
    set
	    cc.CustomerID = cp.CustomerID
    from
	    [db-au-cmdwh].dbo.cbCase cc
	    cross apply
	    (
		    select top 1 
			    coalesce(ec.CustomerID, ea.CustomerID) CustomerID
		    from
			    [db-au-cmdwh].dbo.cbPolicy cp with(nolock)
			    inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt with(nolock) on
				    pt.PolicyTransactionKey = cp.PolicyTransactionKey
			    inner join [db-au-cmdwh].dbo.entPolicy ep with(nolock) on
				    ep.PolicyKey = pt.PolicyKey
			    left join [db-au-cmdwh].[dbo].entCustomer ec with(nolock) on
				    ec.CustomerID = ep.CustomerID and
				    ec.CustomerName like '%' + cc.FirstName + '%' and
				    ec.CustomerName like '%' + cc.Surname + '%'
			    left join [db-au-cmdwh].dbo.entAlias ea with(nolock) on
				    ea.CustomerID = ep.CustomerID and
				    ea.Alias like '%' + cc.FirstName + '%' and
				    ea.Alias like '%' + cc.Surname + '%'
		    where
			    cp.CaseKey = cc.CaseKey and
			    cp.isMainPolicy = 1 and
			    coalesce(ec.CustomerID, ea.CustomerID) is not null
	    ) cp
    where
	    cc.CustomerID is null and
	    cc.CreateDate >= '2011-07-01'

end
GO

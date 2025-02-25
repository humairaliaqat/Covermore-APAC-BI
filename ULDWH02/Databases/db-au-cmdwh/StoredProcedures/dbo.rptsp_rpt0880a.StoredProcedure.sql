USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Policy
CREATE PROCEDURE [dbo].[rptsp_rpt0880a]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880a
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Data-In Monitoring - Policy Data-In
--  Parameters:     N/A
/****************************************************************************************************/
select IssueDate
, PolicyNumber
, AlphaCode
, DistributorCode
, CountryCode
, GroupCode
, SubGroupCode
, LastDataQueueStatus
, UpdateDateTime
, DataQueueID
, RetryCount
, Comment
, CommentGroup
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select p.IssueDate, p.PolicyNumber, p.AlphaCode
, t.Code as DistributorCode, d.CountryCode, g.Code as GroupCode, sg.Code as SubGroupCode
, q.Status as LastDataQueueStatus, q.UpdateDateTime, q.DataQueueID, q.RetryCount, q.Comment
, left(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(q.Comment, ''0'', ''x''), ''1'', ''x''), ''2'', ''x''), ''3'', ''x''), ''4'', ''x''), ''5'', ''x''), ''6'', ''x''), ''7'', ''x''), ''8'', ''x''), ''9'', ''x''), 250) as CommentGroup
from [AU_PenguinSharp_Active]..tblPolicy p with (nolock)
inner join [AU_PenguinSharp_Active]..tblDomain d with (nolock) on d.DomainID = p.DomainID 
inner join [AU_PenguinSharp_Active]..tblOutlet o with (nolock) on o.AlphaCode = p.AlphaCode and o.DomainId = p.DomainID
inner join [AU_PenguinSharp_Active]..tblSubGroup sg with (nolock) on sg.ID = o.SubGroupID
inner join [AU_PenguinSharp_Active]..tblGroup g with (nolock) on g.ID = sg.GroupID
inner join [AU_PenguinSharp_Active]..tblDistributor t with (nolock) on t.DistributorId = sg.DistributorId and t.Status = ''Active''
outer apply (select top 1 dque.DataQueueID, dque.Status, dque.UpdateDateTime, dque.RetryCount, dque.Comment
	from [AU_PenguinJob]..tblDataQueue dque with (nolock)
	outer apply DataValue.nodes(''/*[local-name() = "anyType"]'') as T(x)
	where dque.jobid = 177
	and dque.DataQueueTypeID = 110
	and T.x.value(''*[local-name() = "BlModule"][1]'', ''varchar(100)'') = ''CoverMore.PenguinJobs.MyCoverMore.PolicyNewBl,CoverMore.PenguinJobs.MyCoverMore''
	and dque.dataid = p.PolicyNumber
	order by dque.DataQueueID desc) q 
where p.DomainID = 7 -- AU domain only
and t.Code = ''CMAU'' -- CMAU only
and p.IssueDate >= ''2016-04-19'' -- Post to MDM go live date
and not exists (select 1
	from [MDM_Distributor]..C_PARTY_PRODUCT_TXN mprd with (nolock)
	where mprd.LAST_ROWID_SYSTEM = ''PENGUIN''
	and mprd.PRTY_ROLE = ''Policy Holder''
	and mprd.PROD_REF_NO COLLATE Latin1_General_CI_AS = p.PolicyNumber)
order by p.IssueDate')

GO

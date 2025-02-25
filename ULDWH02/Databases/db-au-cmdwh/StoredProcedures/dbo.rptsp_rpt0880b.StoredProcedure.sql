USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880b]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Claims
CREATE PROCEDURE [dbo].[rptsp_rpt0880b]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880b
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Data-In Monitoring - Claims Data-In
--  Parameters:     N/A
/****************************************************************************************************/
select CreatedDate
, ClaimNo
, AlphaCode
, KLPOLICY
, LastDataQueueStatus
, UpdateDateTime
, DataQueueID
, RetryCount
, Comment
, CommentGroup
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select clm.KLCREATED as CreatedDate, clm.KLCLAIM as ClaimNo, clm.KLALPHA as AlphaCode, clm.KLPOLICY
, q.Status as LastDataQueueStatus, q.UpdateDateTime, q.DataQueueID, q.RetryCount, q.Comment 
, left(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(q.Comment, ''0'', ''x''), ''1'', ''x''), ''2'', ''x''), ''3'', ''x''), ''4'', ''x''), ''5'', ''x''), ''6'', ''x''), ''7'', ''x''), ''8'', ''x''), ''9'', ''x''), 250) as CommentGroup
from [Claims]..[KLREG] clm with (nolock)
outer apply (select top 1 dque.DataQueueID, dque.Status, dque.UpdateDateTime, dque.RetryCount, dque.Comment
	from [AU_PenguinJob]..tblDataQueue dque with (nolock)
	outer apply DataValue.nodes(''/*[local-name() = "anyType"]'') as T(x)
	where dque.jobid = 177
	and dque.DataQueueTypeID = 110
	and T.x.value(''*[local-name() = "BlModule"][1]'', ''varchar(100)'') = ''CoverMore.PenguinJobs.MyCoverMore.ClaimBl,CoverMore.PenguinJobs.MyCoverMore''
	and dque.dataid = convert(varchar(20), clm.KLCLAIM)
	order by dque.DataQueueID desc) q 
where clm.KLDOMAINID = 7 -- AU only
and clm.KLALPHA in (''CMFL000'', ''CMN0100'')  -- Only Outlets under CMAU
and clm.KLCREATED >= ''2016-04-19'' -- Only post to MDM go live date
and not exists (select 1
	from [MDM_Distributor]..C_PARTY_PRODUCT_TXN mprd with (nolock)
	where mprd.LAST_ROWID_SYSTEM = ''CLAIMS''
	and (mprd.PRTY_ROLE = ''Claimant'' or mprd.PRTY_ROLE = ''Payee'') --ClaimNo are sent to MDM via both Claimant and Payee
	and mprd.PROD_REF_NO COLLATE Latin1_General_CI_AS = convert(varchar(20), clm.KLCLAIM))
order by clm.KLCREATED')

GO

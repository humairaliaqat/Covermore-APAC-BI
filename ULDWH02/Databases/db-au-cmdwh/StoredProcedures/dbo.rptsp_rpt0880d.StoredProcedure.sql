USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0880d]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- Gigya
CREATE PROCEDURE [dbo].[rptsp_rpt0880d]
AS
/****************************************************************************************************/
--  Name:           rptsp_rpt0880d
--  Author:         Ryan Lee
--  Date Created:   20170815
--  Description:    Used by RPT0880 for MDM Data-In Monitoring - Gigya Data-In
--  Parameters:     N/A
/****************************************************************************************************/
with party as (
select *
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select mprd.PROD_REF_NO
from [MDM_Distributor]..C_PARTY_PRODUCT_TXN mprd with (nolock)
where mprd.LAST_ROWID_SYSTEM = ''GIGYA''
and mprd.PRTY_ROLE = ''Account Holder'''))
--select * from party
, pjob as (
select *
from openquery([db-au-penguinsharp.aust.covermore.com.au],
'select dque.Status as LastDataQueueStatus, dque.UpdateDateTime, dque.DataQueueID, dque.RetryCount, dque.Comment, dque.DataID
from [AU_PenguinJob]..tblDataQueue dque with (nolock)
outer apply DataValue.nodes(''/*[local-name() = "anyType"]'') as T(x)
where dque.jobid = 177
and dque.DataQueueTypeID = 110
and T.x.value(''*[local-name() = "BlModule"][1]'', ''varchar(100)'') = ''CoverMore.PenguinJobs.MyCoverMore.GigyaUserBl,CoverMore.PenguinJobs.MyCoverMore'''))
--select * from pjob
select gig.createdDate
, gig.UID
, gig.isActive
, gig.isRegistered
, gig.isVerified
, t.LastDataQueueStatus
, t.UpdateDateTime
, t.DataQueueID
, t.RetryCount
, t.Comment
from [db-au-cmdwh]..gigAccount gig with (nolock)
outer apply (select top 1 * 
	from pjob with (nolock)
	where pjob.DataID COLLATE Latin1_General_CI_AS = gig.UID
	order by pjob.DataQueueID desc) t
left join party with (nolock) on party.PROD_REF_NO = gig.UID
where gig.isActive = 1
and gig.isRegistered = 1
and gig.isVerified = 1
and party.PROD_REF_NO is null
order by gig.createdDate

GO

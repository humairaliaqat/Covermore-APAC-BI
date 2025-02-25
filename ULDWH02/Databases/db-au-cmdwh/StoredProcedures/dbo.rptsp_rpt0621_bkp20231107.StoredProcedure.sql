USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0621_bkp20231107]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[rptsp_rpt0621_bkp20231107] @Country varchar(2),
									  @PolicyNumber varchar(50)
    
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0621
--  Author:         Linus Tor
--  Date Created:   20150218
--  Description:    This stored procedure retrieves penguin sent email details
--  Parameters:     @Country: 1 or more values of AU, NZ, MY, SG or UK. Separated by comma.
--                  @PolicyNumber: 1 or more policy numbers. Separated by comma.
--                  
--  Change History: 
--                  20150218 - LT - Created
--
/****************************************************************************************************/

--uncomment to debug
/*
declare 
    @Country varchar(100),
    @PolicyNumber varchar(200)   
select    
    @Country = 'AU', 
    @PolicyNumber = '62664178'
 */


;with cte_policy as
(
    select
        tp.CountryKey as Country, 
        tp.CompanyKey as Company, 
        o.AlphaCode as AlphaCode,
        tp.PolicyNumber,
        pt.FirstName + ' ' + pt.LastName as PolicyHolder,
        tp.IssueDate as PolicyIssuedDate,
        tea.EmailAuditID as EmailID,
        tea.Sender,
        tea.SentDate,
        convert(varchar(250),tea.Recipients) as Recipients,
        tea.[Subject] as EmailSubject,
        case 
            when tea.[Status] = 0 then 'Failed'
            when tea.[Status] = 1 then 'Success'
        end as [Status],
        tea.ExtraData.value('(/Hashtable/Item/Value)[2]','nvarchar(50)') as [Initiator],
        tea.ExtraData.value('(/Hashtable/Item/Value)[1]','nvarchar(10)') as isCOIAttached,
        tea.ExtraData.value('(/Hashtable/Item/Value)[3]','nvarchar(10)') as isPDFAttached
    from 
        penEmailAudit tea 
        inner join penPolicy tp on 
            tea.CountryKey = tp.CountryKey and 
            tea.CompanyKey = tp.CompanyKey and
            tea.AuditReference=tp.PolicyNumber
        inner join penOutlet o on
            tp.OutletAlphaKey = o.OutletAlphaKey and
            o.OutletStatus = 'Current'
		inner join penPolicyTraveller pt on
			tp.PolicyKey = pt.PolicyKey and
			pt.isPrimary = 1
		inner join
		(
			select Item as PolicyNumber
			from dbo.fn_DelimitedSplit8K(replace(@PolicyNumber,' ',''), ',')
		) p on tea.AuditReference = p.PolicyNumber
    where
        tea.CountryKey = @Country and
        tea.AuditReference = @PolicyNumber
)
select
    a.Country,
    a.Company,
    a.AlphaCode,
    a.PolicyNumber, 
    a.PolicyHolder,
    a.PolicyIssuedDate,
    a.EmailID,
    a.Sender,
    a.SentDate, 
    a.Recipients,
    a.EmailSubject,
    a.[Status], 
    (select top 1 DisplayName from usrLDAP where UserName = a.[Initiator]) as [Initiator],
    a.isCOIAttached,
    a.isPDFAttached 
from
    cte_policy a 
order by
	a.PolicyNumber,
	a.EmailID	








GO

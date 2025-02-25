USE [db-au-actuary]
GO
/****** Object:  StoredProcedure [ws].[sp_penPolicyAdminCallCommentDataSet]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [ws].[sp_penPolicyAdminCallCommentDataSet]
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           ws.sp_penPolicyAdminCallCommentDataSet
--  Author:         Linus Tor
--  Date Created:   20171023
--	Prerequisite:	[db-au-actuary].[ws].[penPolicy] table exists and populated with data.
--  Description:    This stored procedure inserts [db-au-cmdwh].dbo.penPolicyAdminCallComment data into [db-au-actuary].[ws].[penPolicyAdminCallComment]
--
--  Change History: 20171023 - LT - Created
--                  
/****************************************************************************************************/

--create penPolicyAdminCallComment table and populate with data that exists in [db-au-actuary].ws.penPolicy
if object_id('[db-au-actuary].ws.penPolicyAdminCallComment') is null
begin
	create table [db-au-actuary].ws.penPolicyAdminCallComment
	(
		[CountryKey] [varchar](2) NOT NULL,
		[CompanyKey] [varchar](3) NOT NULL,
		[CallCommentKey] [varchar](41) NOT NULL,
		[PolicyKey] [varchar](41) NULL,
		[CRMUserKey] [varchar](41) NULL,
		[CallCommentID] [int] NOT NULL,
		[PolicyID] [int] NULL,
		[PolicyNumber] [varchar](50) NULL,
		[CRMUserID] [int] NULL,
		[CallDate] [datetime] NULL,
		[CallReason] [nvarchar](50) NULL,
		[CallComment] [nvarchar](max) NULL,
		[DomainID] [int] NULL,
		[CallDateUTC] [datetime] NULL
	)
    create clustered index idx_penPolicyAdminCallComment_PolicyKey on [db-au-actuary].ws.penPolicyAdminCallComment(PolicyKey)
    create nonclustered index idx_penPolicyAdminCallComment_CallCommentKey on [db-au-actuary].ws.penPolicyAdminCallComment(CallCommentKey)
    create nonclustered index idx_penPolicyAdminCallComment_CallDate on [db-au-actuary].ws.penPolicyAdminCallComment(CallDate,CountryKey)
    create nonclustered index idx_penPolicyAdminCallComment_CallReason on [db-au-actuary].ws.penPolicyAdminCallComment(CallReason,CountryKey)
    create nonclustered index idx_penPolicyAdminCallComment_CRMUserKey on [db-au-actuary].ws.penPolicyAdminCallComment(CRMUserKey)
    create nonclustered index idx_penPolicyAdminCallComment_PolicyNumber on [db-au-actuary].ws.penPolicyAdminCallComment(PolicyNumber,CountryKey)
end



--populate penPolicyAdminCallComment data
insert into [db-au-actuary].ws.penPolicyAdminCallComment with(tablockx)
(
    CountryKey,
    CompanyKey,
    CallCommentKey,
    PolicyKey,
    CRMUserKey,
    DomainID,
    CallCommentID,
    PolicyID,
    PolicyNumber,
    CRMUserID,
    CallDate,
    CallDateUTC,
    CallReason,
    CallComment
)
select
    CountryKey,
    CompanyKey,
    CallCommentKey,
    PolicyKey,
    CRMUserKey,
    DomainID,
    CallCommentID,
    PolicyID,
    PolicyNumber,
    CRMUserID,
    CallDate,
    CallDateUTC,
    CallReason,
    CallComment
from
    [db-au-cmdwh].dbo.penPolicyAdminCallComment
where
	CountryKey = 'AU' and
	PolicyKey in (select PolicyKey from [db-au-actuary].ws.penPolicy)
GO

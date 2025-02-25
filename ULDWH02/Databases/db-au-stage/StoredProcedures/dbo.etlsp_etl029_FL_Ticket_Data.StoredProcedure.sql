USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl029_FL_Ticket_Data]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_etl029_FL_Ticket_Data]
as

SET NOCOUNT ON


/************************************************************************************************************************************
Author:         Linus Tor
Date:           20130315
Prerequisite:   1. Requires Penguin Data Model ETL successfully run.
				2. Requires Flight Centre excel spreadsheet saved in E:\EmailLists\FLUpload\CovermoreUpload.xlsx
Description:    This ETL imports, transforms and loads Flight Centre Ticket data into usrFLTicketData table.
Change History:
                20130315_LT - Procedure created
                20140912_LT - Update linkage to T3 code instead of PCC (ExtID)
                20141204_LT - Added Update clauses to correct ExtID to true ExtID and Outlet details
                
*************************************************************************************************************************************/



if OBJECT_ID('[db-au-stage].dbo.etl_FLTicketData') is not null drop table [db-au-stage].dbo.etl_FLTicketData
select
	a.CountryKey,
	a.CompanyKey,
	a.OutletKey,	
	a.OutletID,	
	a.OutletAlphaKey,	
	a.AlphaCode,
	a.OutletName,
	a.IssuedDate,
	a.ExtID,
	sum(isnull(a.FLTicketCountINT,0)) as FLTicketCountINT,
	sum(isnull(a.FLTicketCountDOM,0)) as FLTicketCountDOM,
	sum(isnull(a.CMPolicyCountINT,0)) as CMPolicyCountINT,
	sum(isnull(a.CMPolicyCountDOM,0)) as CMPolicyCountDOM,
	a.PCC
into [db-au-stage].dbo.etl_FLTicketData
from
(
	select
		'AU' as CountryKey,
		'CM' as CompanyKey,
		(select top 1 OutletKey from [db-au-cmdwh].dbo.penOutlet where CountryKey = 'AU' and GroupCode = 'FL' and OutletStatus = 'Current' and ExtID = a.T3) as OutletKey,	
		(select top 1 OutletID from [db-au-cmdwh].dbo.penOutlet where CountryKey = 'AU' and GroupCode = 'FL' and OutletStatus = 'Current' and ExtID = a.T3) as OutletID,	
		(select top 1 OutletAlphaKey from [db-au-cmdwh].dbo.penOutlet where CountryKey = 'AU' and GroupCode = 'FL' and OutletStatus = 'Current' and ExtID = a.T3) as OutletAlphaKey,	
		(select top 1 AlphaCode from [db-au-cmdwh].dbo.penOutlet where CountryKey = 'AU' and GroupCode = 'FL' and OutletStatus = 'Current' and ExtID = a.T3) as AlphaCode,
		(select top 1 OutletName from [db-au-cmdwh].dbo.penOutlet where CountryKey = 'AU' and GroupCode = 'FL' and OutletStatus = 'Current' and ExtID = a.T3) as OutletName,
		convert(datetime,a.IssuedDate) as IssuedDate,
		a.T3 as ExtID,
		a.FLTicketCountINT,
		a.FLTicketCountDOM,
		a.CMPolicyCountINT,
		a.CMPolicyCountDOM,
		left(a.PCC,20) as PCC
	from
		[db-au-stage].dbo.ETL_FLTicketDataImport a
	where
		a.IssuedDate is not null
) a		
group by
	a.CountryKey,
	a.CompanyKey,
	a.OutletKey,	
	a.OutletID,	
	a.OutletAlphaKey,	
	a.AlphaCode,
	a.OutletName,
	a.IssuedDate,
	a.ExtID,	
	a.PCC

if OBJECT_ID('[db-au-cmdwh].dbo.usrFLTicketData') is null
begin
	create table [db-au-cmdwh].dbo.usrFLTicketData
	(	
		[CountryKey] [varchar](2) NULL,
		[CompanyKey] [varchar](2) NULL,
		[OutletKey] [varchar](33) NULL,
		[OutletID] [int] NULL,
		[OutletAlphaKey] [varchar](33) NULL,
		[AlphaCode] [varchar](20) NULL,
		[OutletName] [varchar](50) NULL,
		[IssuedDate] [datetime] NULL,
		[ExtID] [nvarchar](255) NULL,
		[FLTicketCountINT] [float] NULL,
		[FLTicketCountDOM] [float] NULL,
		[CMPolicyCountINT] [float] NULL,
		[CMPolicyCountDOM] [float] NULL,
		[PCC] [nvarchar](20) NULL
	)
        create clustered index idx_usrFLTicketData_OutletKey on [db-au-cmdwh].dbo.usrFLTicketData(OutletKey)
        create index idx_usrFLTicketData_OutletAlphaKey on [db-au-cmdwh].dbo.usrFLTicketData(OutletAlphaKey)
        create index idx_usrFLTicketData_IssuedDate on [db-au-cmdwh].dbo.usrFLTicketData(IssuedDate)
        create index idx_usrFLTicketData_ExtID on [db-au-cmdwh].dbo.usrFLTicketData(ExtID)
end        	
else
    begin
        delete a
        from
            [db-au-cmdwh].dbo.usrFLTicketData a
            inner join [db-au-stage].dbo.etl_FLTicketData b on
                isnull(a.OutletAlphaKey,'') = isnull(b.OutletAlphaKey,'') and
                a.IssuedDate = b.IssuedDate
    end

        

insert into [db-au-cmdwh].dbo.usrFLTicketData with (tablockx)
    (
		[CountryKey],
		[CompanyKey],
		[OutletKey],
		[OutletID],
		[OutletAlphaKey],
		[AlphaCode],
		[OutletName],
		[IssuedDate],
		[ExtID],
		[FLTicketCountINT],
		[FLTicketCountDOM],
		[CMPolicyCountINT],
		[CMPolicyCountDOM],
		[PCC]
    )
    select
		[CountryKey],
		[CompanyKey],
		[OutletKey],
		[OutletID],
		[OutletAlphaKey],
		[AlphaCode],
		[OutletName],
		[IssuedDate],
		[ExtID],
		[FLTicketCountINT],
		[FLTicketCountDOM],
		[CMPolicyCountINT],
		[CMPolicyCountDOM],
		[PCC]
    from
        [db-au-stage].dbo.etl_FLTicketData




--update usrFLTicketData with true ExtID
--get TrueExtID and store in temp able
if object_id('tempdb..#TrueExtID') is not null drop table #TrueExtID
select 
	t.ExtID,
	CASE WHEN LEN(t.ExtID) > 5 THEN t.ExtID 
		 ELSE right('0000000000'+ rtrim(t.ExtID), 5) 
	END as TrueExtID,
	f.PCC,
	o.AlphaCode
into #TrueExtID	
from
	[db-au-cmdwh].dbo.usrFLTicketData t
	left join [db-au-cmdwh].dbo.penOutlet o on t.ExtID = o.ExtID and o.CountryKey = 'AU' and o.GroupCode = 'FL'
	left join [db-au-stage].dbo.etl_FLTicketData f on t.ExtID = f.ExtID
where
	o.AlphaCode is null	and
	f.PCC is not null

--update to true ExtID
update a
set a.ExtID = b.TrueExtID
from
	[db-au-cmdwh].dbo.usrFLTicketData a
	join #TrueExtID b on a.ExtID = b.ExtID
	
	
--update outlet details now that true ExtID is reflected from penOutlet ExtID
update a
set a.OutletKey = b.OutletKey,
	a.OutletID = b.OutletID,
	a.OutletAlphaKey = b.OutletAlphaKey,
	a.AlphaCode = b.AlphaCode,
	a.OutletName = b.OutletName
from
	[db-au-cmdwh].dbo.usrFLTicketData a
	join [db-au-cmdwh].dbo.penOutlet b on a.ExtID = b.ExtID and b.CountryKey = 'AU' and b.GroupCode = 'FL' and b.OutletStatus = 'Current'
	join #TrueExtID c on b.ExtID = c.TrueExtID
GO

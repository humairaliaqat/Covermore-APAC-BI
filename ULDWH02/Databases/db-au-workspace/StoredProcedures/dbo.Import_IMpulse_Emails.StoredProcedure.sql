USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[Import_IMpulse_Emails]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[Import_IMpulse_Emails]  
as  
begin  
  
declare @date1 datetime  
declare @date2 datetime  
set @date1=(select getdate())  
set @date2=(select getdate()-10)  
  
if(OBJECT_ID('Medallia_Inv_Quote_EMail') is not null)  
begin  
truncate table  Medallia_Inv_Quote_EMail  
end  
  
  
insert into Medallia_Inv_Quote_EMail(SessionID,TITLE,FIRSTNAME,LASTNAME,EMAILADDRESS,Date,CreatedDate)  
select a1.SessionID,json_value([PartnerMetaData],'$.title_1') collate SQL_Latin1_General_CP1_CI_AS as TITLE,  
FIRSTNAME collate SQL_Latin1_General_CP1_CI_AS as FIRSTNAME,    
LASTNAME collate SQL_Latin1_General_CP1_CI_AS as LASTNAME,json_value([PartnerMetaData],'$.billingEmail') collate SQL_Latin1_General_CP1_CI_AS as EMAILADDRESS,Date,getdate() as CreatedDate   
from [db-au-stage].dbo.cdg_factTraveler_AU as a1 with(nolock)      
inner join [db-au-stage].dbo.cdg_factSession_AU as b on a1.SessionID=b.FactSessionID and IsPrimary=1      
inner join [db-au-stage].dbo.cdg_SessionPartnerMetaData_AU as c on b.SessionToken=c.SessionToken      
inner join [db-au-stage].dbo.cdg_factQuote_AU as d on a1.SessionID=d.SessionID  
inner join [db-au-stage].dbo.cdg_dimDate_AU as e on d.QuoteTransactionDateID=e.DimDateID  where convert(date,[date],103) between convert(date,@date2,103) and   convert(date,@date1,103)  
  
end
GO

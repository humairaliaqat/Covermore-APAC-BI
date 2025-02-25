USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_tbl_Finance_Reco_20240930]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
CREATE Procedure [dbo].[etlsp_tbl_Finance_Reco_20240930]              
as              
              
Begin              
Truncate Table tbl_Finance_Reco              
            
insert into tbl_Finance_Reco            
values ('[Source Business Unit]','[Source Period]','[Source GL Amount]','[BI Business Unit]','[BI Period]','[BI GL Amount]','[Variance]')            
            
              
;with CTE_A as              
( select BusinessUnit,period,case when BusinessUnit in ('CMG','LAT') then sum(OTHER_AMT) else sum(AMOUNT) end 'GL_Amount'               
from sungl_SALFLDG_reco_20240926 where Accnt_Code >= '4000' and Accnt_Code <= '9999'              
    and ScenarioCode = 'A'                
group by BusinessUnit,period              
)              
, CTE_B as              
(              
   select BusinessUnit,Period,case when BusinessUnit in ('CMG','LAT') then sum(OtherAmount) else sum(GLAmount) end 'GL_Amount'              
    from [db-au-cmdwh]..glTransactions                 
 where AccountCode >= '4000' and AccountCode <= '9999'                
    and ScenarioCode = 'A'  and Period >= '2023001'              
 group by BusinessUnit,[period]               
)              
Insert into tbl_Finance_Reco              
 select gl.BusinessUnit 'Source Business Unit', gl.period 'Source Period', gl.GL_Amount 'Source GL Amount',bi.BusinessUnit 'BI Business Unit', bi.period 'BI Period', bi.GL_Amount 'BI GL Amount',   abs(isnull(gl.GL_Amount,0) - isnull(bi.GL_Amount,0)) 'Variance'              
 from CTE_A gl full outer join CTE_B bi              
 on gl.BusinessUnit = bi.BusinessUnit and gl.period = bi.period               
 ORDER BY [BI Period] DESC,bi.BusinessUnit              
              
            
declare @QueryGL varchar(8000)                
              
declare @SQL varchar(8000)                
declare @Path varchar(1000)                
declare @FileNameGL varchar(200)                
                
declare @ExtZip varchar(4)                
declare @ExtTxt varchar(4)                
                
select @QueryGL = 'select [Source Business Unit],[Source Period],[Source GL Amount],[BI Business Unit],[BI Period],[BI GL Amount],Variance from [db-au-stage].dbo.tbl_Finance_Reco'              
select @Path = 'E:\ETL\Siddhesh\'                
select @FilenameGL = 'Finance_Recon_test'              
select @ExtTxt = '.csv'                 
--build SQL statement and export GL file                
select @SQL = 'bcp "' + @QueryGL + '" queryout "' + @Path + @FileNameGL + @ExtTxt + '"' + ' -S localhost -T -w'              
print(@SQL)             
exec xp_cmdshell @SQL              
         
-- exec msdb..sp_send_dbmail               
--                @profile_name='covermorereport',              
--@recipients='BusinessIntelligence@covermore.com.au;kevin.kong@covermore.com;Kangan.Dara@covermore.com;Sanchay.Grover@covermore.com;steve.qian@covermore.com;Sushil.Ghadigaonkar@covermore.com;brook.lee@covermore.com',             
--                @subject='Finance Reco File',              
--                @body='',             
--                @file_attachments = 'E:\ETL\Siddhesh\Finance_Recon.csv';           
                        
                         
 End 
GO

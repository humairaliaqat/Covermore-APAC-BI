USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_stage_SALFLDG_reco_20230627]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL033_stage_SALFLDG_reco_20230627]      
as      
      
Begin      
      
Begin      
TRUNCATE TABLE sungl_SALFLDG_reco      
      
INSERT INTO sungl_SALFLDG_reco (BusinessUnit, ScenarioCode, ACCNT_CODE, PERIOD,TRANS_DATETIME ,JRNAL_NO ,JRNAL_LINE ,AMOUNT ,D_C ,ALLOCATION ,JRNAL_TYPE ,JRNAL_SRCE ,TREFERENCE ,DESCRIPTN ,ENTRY_DATETIME ,ENTRY_PRD ,DUE_DATETIME ,ALLOC_REF ,ALLOC_DATETIME
  
    
 ,ALLOC_PERIOD ,ASSET_IND ,      
ASSET_CODE ,ASSET_SUB ,CONV_CODE ,CONV_RATE ,OTHER_AMT ,OTHER_DP ,CLEARDOWN ,REVERSAL ,LOSS_GAIN ,ROUGH_FLAG ,IN_USE_FLAG ,ANAL_T0 ,      
ANAL_T1 ,ANAL_T2 ,ANAL_T3 ,ANAL_T4 ,ANAL_T5 ,ANAL_T6 ,ANAL_T7 ,ANAL_T8 ,ANAL_T9 ,POSTING_DATETIME ,ALLOC_IN_PROGRESS ,HOLD_REF ,HOLD_OP_ID ,BASE_RATE ,BASE_OPERATOR ,CONV_OPERATOR ,REPORT_RATE ,      
REPORT_OPERATOR ,REPORT_AMT ,MEMO_AMT ,EXCLUDE_BAL ,LE_DETAILS_IND ,CONSUMED_BDGT_ID ,CV4_CONV_CODE ,CV4_AMT ,CV4_CONV_RATE ,CV4_OPERATOR ,CV4_DP ,CV5_CONV_CODE ,CV5_AMT ,CV5_CONV_RATE ,      
CV5_OPERATOR ,      
CV5_DP ,LINK_REF_1 ,LINK_REF_2 ,LINK_REF_3 ,ALLOCN_CODE ,ALLOCN_STMNTS ,OPR_CODE ,SPLIT_ORIG_LINE ,VAL_DATETIME ,SIGNING_DETAILS ,INSTLMT_DATETIME ,PRINCIPAL_REQD ,BINDER_STATUS ,AGREED_STATUS ,SPLIT_LINK_REF ,      
PSTG_REF ,TRUE_RATED ,HOLD_DATETIME ,HOLD_TEXT ,INSTLMT_NUM ,SUPPLMNTRY_EXTSN ,APRVLS_EXTSN ,REVAL_LINK_REF ,SAVED_SET_NUM ,AUTHORISTN_SET_REF ,PYMT_AUTHORISTN_SET_REF ,MAN_PAY_OVER ,PYMT_STAMP ,      
AUTHORISTN_IN_PROGRESS ,SPLIT_IN_PROGRESS ,VCHR_NUM ,JNL_CLASS_CODE ,ORIGINATOR_ID ,ORIGINATED_DATETIME ,LAST_CHANGE_USER_ID ,LAST_CHANGE_DATETIME ,AFTER_PSTG_ID , AFTER_PSTG_DATETIME ,POSTER_ID ,ALLOC_ID ,JNL_REVERSAL_TYPE)      
SELECT BusinessUnit, ScenarioCode, ACCNT_CODE, PERIOD,TRANS_DATETIME ,JRNAL_NO ,JRNAL_LINE ,AMOUNT ,D_C ,ALLOCATION ,JRNAL_TYPE ,JRNAL_SRCE ,TREFERENCE ,DESCRIPTN ,ENTRY_DATETIME ,ENTRY_PRD ,DUE_DATETIME ,ALLOC_REF ,ALLOC_DATETIME ,    
ALLOC_PERIOD ,ASSET_IND ,      
ASSET_CODE ,ASSET_SUB ,CONV_CODE ,CONV_RATE ,OTHER_AMT ,OTHER_DP ,CLEARDOWN ,REVERSAL ,LOSS_GAIN ,ROUGH_FLAG ,IN_USE_FLAG ,ANAL_T0 ,      
ANAL_T1 ,ANAL_T2 ,ANAL_T3 ,ANAL_T4 ,ANAL_T5 ,ANAL_T6 ,ANAL_T7 ,ANAL_T8 ,ANAL_T9 ,POSTING_DATETIME ,ALLOC_IN_PROGRESS ,HOLD_REF ,HOLD_OP_ID ,BASE_RATE ,BASE_OPERATOR ,CONV_OPERATOR ,REPORT_RATE ,      
REPORT_OPERATOR ,REPORT_AMT ,MEMO_AMT ,EXCLUDE_BAL ,LE_DETAILS_IND ,CONSUMED_BDGT_ID ,CV4_CONV_CODE ,CV4_AMT ,CV4_CONV_RATE ,CV4_OPERATOR ,CV4_DP ,CV5_CONV_CODE ,CV5_AMT ,CV5_CONV_RATE ,      
CV5_OPERATOR ,CV5_DP ,LINK_REF_1 ,LINK_REF_2 ,LINK_REF_3 ,ALLOCN_CODE ,ALLOCN_STMNTS ,OPR_CODE ,SPLIT_ORIG_LINE ,VAL_DATETIME ,SIGNING_DETAILS ,INSTLMT_DATETIME ,PRINCIPAL_REQD ,BINDER_STATUS     
,AGREED_STATUS ,SPLIT_LINK_REF ,PSTG_REF ,TRUE_RATED ,HOLD_DATETIME ,HOLD_TEXT ,INSTLMT_NUM ,SUPPLMNTRY_EXTSN ,APRVLS_EXTSN ,REVAL_LINK_REF ,SAVED_SET_NUM ,AUTHORISTN_SET_REF     
,PYMT_AUTHORISTN_SET_REF ,MAN_PAY_OVER ,PYMT_STAMP ,AUTHORISTN_IN_PROGRESS ,SPLIT_IN_PROGRESS ,VCHR_NUM ,JNL_CLASS_CODE ,ORIGINATOR_ID ,ORIGINATED_DATETIME ,LAST_CHANGE_USER_ID     
,LAST_CHANGE_DATETIME ,AFTER_PSTG_ID , AFTER_PSTG_DATETIME ,POSTER_ID ,ALLOC_ID ,JNL_REVERSAL_TYPE    from sungl_SALFLDG      
End      
      
Begin      
Declare @ParentGroup varchar(5) = 'CMG',      
  @DateRange varchar(30) = 'History'      
      
if object_id('tempdb..#gl') is not null       
    drop table #gl      
      
select       
    case       
        --when BusinessUnit = 'CMG' and sbu.BusinessUnitCode in ('CMG', 'HHC', 'USC', 'M05','BIC') then 'CMGG'       
        when BusinessUnit = 'CMG' and sbu.BusinessUnitCode in ('CMG', 'M05') then 'CMGG'       
        when BusinessUnit = 'ARG' and sbu.BusinessUnitCode in ('ARG') then 'ARGG'       
   when BusinessUnit = 'WTC' and sbu.BusinessUnitCode in ('WTC') then 'WTC'      
        when BusinessUnit = 'LAT' then sbu.BusinessUnitCode         
        else BusinessUnit       
    end [Business_Unit_Code],      
    coalesce(jv.JVCode, cl.ClientCode, 'UN') [JV_Client_Code],      
    isnull(ch.ChannelCode, 'UN') [Channel_Code],      
    isnull(dp.DepartmentCode, 'UN') [Department_Code],      
    isnull(pr.ProductCode, 'UN') [Product_Code],      
    isnull(st.StateCode, 'UN') [State_Code],      
 --isnull(pj.ProjectCode, 'UN') [Project_Code],      
 coalesce(ct.CCATeamsCode, pj.ProjectCode, 'UN') [Project_Code],           -- Added CCATeamsCode      
   isnull(a.AccountCode, 'UN') [Account_Code],      
    ScenarioCode [Scenario],      
 case      
  when JournalType in ('ZENMC','ZENTB') then 'JNL'      
        when JournalType like 'Z%' and TransactionReference in ('DEPT2', 'DEPT3') then 'JNL'      
        when JournalType like 'Z%' then 'ALO'      
        else 'JNL'      
    end [Journal_Type],      
      
    isnull(sbu.BusinessUnitCode, 'UN') [Source_Business_Unit_Code],      
    Period,      
    left(datename(mm, d.[Date]), 3) + ' ' + datename(yyyy, d.[Date]) [Month],      
    case      
        when BusinessUnit = 'LAT' then OtherAmount      
        else GLAmount       
    end [GL_Amount]      
into #gl      
from      
    [db-au-cmdwh]..glTransactions gl with(nolock)      
    cross apply      
    (      
        select top 1       
            d.[Date]      
        from      
            [db-au-cmdwh]..Calendar d with(nolock)      
        where      
            d.SUNPeriod = gl.Period      
    ) d      
    outer apply      
    (      
        select top 1       
            jv.JVCode      
        from      
            [db-au-cmdwh]..glJointVentures jv with(nolock)      
        where      
            jv.JVCode = gl.JointVentureCode      
    ) jv      
    outer apply      
    (      
        select top 1       
            cl.ClientCode      
        from      
            [db-au-cmdwh]..glClients cl with(nolock)      
        where      
            cl.ClientCode = gl.ClientCode      
    ) cl      
    outer apply      
    (      
        select top 1       
            ch.ChannelCode      
        from      
            [db-au-cmdwh]..glChannels ch with(nolock)      
        where      
            ch.ChannelCode = gl.ChannelCode      
    ) ch      
    outer apply      
    (      
        select top 1       
            dp.DepartmentCode      
        from      
            [db-au-cmdwh]..glDepartments dp with(nolock)      
        where      
            dp.DepartmentCode = gl.DepartmentCode      
    ) dp      
    outer apply      
    (      
        select top 1       
            pr.ProductCode      
        from      
            [db-au-cmdwh]..glProducts pr with(nolock)      
        where      
            pr.ProductCode = gl.ProductCode      
    ) pr      
    outer apply      
    (      
        select top 1       
            st.StateCode      
        from      
            [db-au-cmdwh]..glStates st with(nolock)      
        where      
            st.StateCode = gl.StateCode      
    ) st      
 outer apply      
    (      
        select top 1       
            pj.ProjectCode      
        from      
            [db-au-cmdwh]..[glProjects] pj with(nolock)      
        where      
            pj.ProjectCode = gl.ProjectCode      
    ) pj      
 outer apply      
    (      
        select top 1       
            ct.CCATeamsCode      
        from      
            [db-au-cmdwh]..[glCCATeams] ct with(nolock)      
        where      
            ct.CCATeamsCode = gl.CCATeamsCode      
    ) ct      
 outer apply      
    (      
        select top 1       
            a.AccountCode      
        from      
            [db-au-cmdwh]..glAccounts a with(nolock)      
        where      
            a.AccountCode = gl.AccountCode      
    ) a      
    outer apply      
    (      
        select top 1       
            sbu.BusinessUnitCode      
        from      
            [db-au-cmdwh]..glBusinessUnits sbu with(nolock)      
        where      
            sbu.BusinessUnitCode = gl.SourceCode      
    ) sbu      
where      
    ScenarioCode in ('A', 'C', 'F') and      
    (      
        (      
            @ParentGroup = 'CMG' and      
            (      
       BusinessUnit in      
       (      
        select       
         BusinessUnitCode      
        from      
         [db-au-cmdwh]..glBusinessUnits with(nolock)      
        where      
         ParentBusinessUnitCode not in ('XIN', 'IND', 'ARG')      
       ) or      
                (      
           BusinessUnit = 'CMG' and       
                    sbu.BusinessUnitCode in ('CMG','M05')      
                )      
      )       
        )       
        or      
        (      
            @ParentGroup = 'ARG' and                      
       BusinessUnit = 'ARG'      
        )      
        or      
        (      
            @ParentGroup = 'WTC' and                      
            BusinessUnit = 'WTC'      
        )      
        or      
        (      
            @ParentGroup = 'LAT' and      
            BusinessUnit = 'LAT'      
         
   --temporary filter: include only PAT accounts for LAT      
   and a.AccountCode in       
    (      
     select distinct Descendant_Code      
     from [db-au-star].dbo.vAccountAncestors      
     where Account_Code = 'PAT'      
    )      
   )      
    ) and      
    [Period] >= '2023007'      
      
    if object_id('tempdb..#tmp_glout') is not null       
 drop table #tmp_glout      
      
          
 select       
    [Unique Key],      
    [Business_Unit_Code],      
    [JV_Client_Code],      
    [Channel_Code],      
    [Department_Code],      
    [Product_Code],      
    [State_Code],      
 [Project_Code],      
    [Account_Code],      
    [Scenario],      
    [Journal_Type],      
    [Source_Business_Unit_Code],      
    [Period],      
    [Month],      
    sum([GL_Amount]) [GL_Amount],      
 convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[JV_Client_Code]) [BU_JV],      
 convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]) [BU_Dept],      
 convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]) + '_' + convert(varchar,[JV_Client_Code]) [BU_Dept_JV]      
into #tmp_glout      
from      
      
    #gl t      
    cross apply      
    (      
        select      
   case when @ParentGroup <> 'LAT' then      
      rtrim([Business_Unit_Code]) + '-' +      
      rtrim([JV_Client_Code]) + '-' +      
      rtrim([Channel_Code]) + '-' +      
      rtrim([Department_Code]) + '-' +      
      rtrim([Product_Code]) + '-' +      
      rtrim([State_Code]) + '-' +      
      rtrim([Project_Code]) + '-' +      
      rtrim([Account_Code]) + '-' +      
      rtrim([Scenario]) + '-' +      
      rtrim([Journal_Type]) + '-' +      
      rtrim([Source_Business_Unit_Code]) + '-' +      
      convert(varchar(7), [Period])      
    else --LATAM Unique Key structure      
      rtrim([Source_Business_Unit_Code]) + '-' +      
      rtrim([JV_Client_Code]) + '-' +      
      rtrim([Channel_Code]) + '-' +      
      rtrim([Department_Code]) + '-' +      
      rtrim([Product_Code]) + '-' +      
      rtrim([State_Code]) + '-' +      
      rtrim([Project_Code]) + '-' +      
      rtrim([Account_Code]) + '-' +      
      rtrim([Scenario]) + '-' +      
      rtrim([Journal_Type]) + '-' +            
      convert(varchar(7), [Period])            
   end  [Unique Key]      
    ) qid      
group by      
    [Unique Key],      
    [Business_Unit_Code],      
    [JV_Client_Code],      
    [Channel_Code],      
    [Department_Code],      
    [Product_Code],      
    [State_Code],      
 [Project_Code],      
    [Account_Code],      
    [Scenario],      
    [Journal_Type],      
    [Source_Business_Unit_Code],      
    [Period],      
    [Month],      
 convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[JV_Client_Code]),      
 convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]),      
 convert(varchar,[Business_Unit_Code]) + '_' + convert(varchar,[Department_Code]) + '_' + convert(varchar,[JV_Client_Code])      
      
 if object_id('tempdb..#tmp_glout_export') is not null       
 drop table #tmp_glout_export      
      
 select      
    [Unique Key],      
    [Business_Unit_Code],      
    [JV_Client_Code],      
   [Channel_Code],      
    [Department_Code],      
    [Product_Code],      
    [State_Code],      
 [Project_Code],      
    [Account_Code],      
    [Scenario],      
    [Journal_Type],      
    [Source_Business_Unit_Code],      
    convert(varchar(10), Period) as [Period],      
    [Month],      
    GL_Amount,      
 BU_JV,      
 BU_Dept,      
 BU_Dept_JV      
 into #tmp_glout_export      
from      
    #tmp_glout      
      
    drop table tmp_glout_export_reco      
      
    select * into tmp_glout_export_reco from #tmp_glout_export      
       
    select Period,sum(GL_Amount) from #tmp_glout_export       
 where Business_Unit_Code = 'AUH' and Account_Code >= '4000' and Account_Code <= '9999'      
    and Scenario = 'A'      
--    and Source_Business_Unit_Code not in ('AZU',      
--'GLA',      
--'GUJ',      
--'NZU',      
--'TLA',      
--'TZU',      
--'HOF'      
--)      
 group by [period]      
      
End      
      
End 
GO

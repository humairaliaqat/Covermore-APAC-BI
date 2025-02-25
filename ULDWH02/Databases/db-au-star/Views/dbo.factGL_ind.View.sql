USE [db-au-star]
GO
/****** Object:  View [dbo].[factGL_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[factGL_ind] as
select --top 100
    f.Account_SID, 
    f.Business_Unit_SK, 
    f.State_SK, 
    f.Project_Codes_SK, 
    f.Channel_SK, 
    f.Currency_SK, 
    f.Joint_Venture_SK, 
    f.Department_SK, 
    f.Source_Business_Unit_SK, 
    f.Date_SK, 
    f.Scenario_SK, 
    f.Client_SK, 
    f.GL_Product_SK, 
    f.Journal_Type_SK,
    f.GST_SK,
    case 
        when da.Account_Operator = '-' then f.General_Ledger_Amount * - 1 
        else f.General_Ledger_Amount 
    end General_Ledger_Amount, 
    case 
        when da.Account_Operator = '-' then f.Report_Amount * - 1 
        else f.Report_Amount 
    end Report_Amount, 
    case 
        when da.Account_Operator = '-' then f.Other_Amount * - 1 
        else f.Other_Amount 
    end Other_Amount 
from 
    Fact_GL_ind f
    outer apply
    (
        select top 1
            Account_Operator
        from
            Dim_Account_ind da
        where
            da.Account_SID = f.Account_SID
    )da


GO

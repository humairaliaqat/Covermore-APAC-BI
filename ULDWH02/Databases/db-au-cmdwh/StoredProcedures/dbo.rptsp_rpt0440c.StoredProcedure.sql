USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0440c]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0440c] 
    @Country varchar(3),
    @PolicyNumber varchar(20)
    
as
begin
/****************************************************************************************************/
--  Name:           dbo.rptsp_rpt0440c
--  Author:         Linus Tor
--  Date Created:   20130626
--  Description:    This stored procedure returns policy call comments details. It will be called from a Webi report
--  Parameters:     @Country: Country is AU, NZ, MY, SG, or UK
--                  @PolicyNumber: valid policy number
--   
--  Change History: 20130626 - LT - Created
--                  20130731 - LS - optimize
--
/****************************************************************************************************/								   

--uncomment to debug
/*
declare @Country varchar(3)
declare @PolicyNumber varchar(20)
select @Country = 'AU', @PolicyNumber = '50006698'
*/

    set nocount on
    
    declare @alpha varchar(25)
    
    --the index on crmcalls puts agencycode in higher precedence
    select 
        @alpha = AgencyCode
    from
        Policy
    where
        CountryKey = @Country and
        PolicyNo = @PolicyNumber

    select  
      a.CountryKey,  
      a.Consultant,
      a.PolicyNumber,
      a.CallRemarks,  
      a.CallDate,
      a.Rep,
      a.RepType
    from
    (
        SELECT
          crmCallCard.CRMCallCardID,
          crmCalls.CountryKey,  
          crmCalls.Consultant,
          crmCalls.SubCategoryDetails as PolicyNumber,
          crmCallCard.CallRemarks,  
          crmCalls.CallTime as CallDate,
          upper(crmCallCard.rep) as Rep,
          crmCallCard.RepType
        FROM
          crmCalls 
          inner JOIN crmCallCard ON (crmCallCard.CRMCallsID=crmCalls.CRMCallsID and crmCallCard.CountryKey=crmCalls.CountryKey)
          inner JOIN crmUser ON (crmUser.UserName=crmCallCard.Rep and crmUser.CountryKey=crmCallCard.CountryKey)  
        WHERE
          (
           crmCalls.CountryKey  =  @Country
           AND
           crmCalls.SubCategoryDetails  = @PolicyNumber and
           crmCalls.AgencyCode = @alpha
          )

        union

        --this is required to handle no call comments record
        SELECT
          null as CRMCallCardID,
          @Country,  
          null as Consultant,
          null as PolicyNumber,
          null as CallRemarks,  
          null as CallDate,
          null as Rep,
          null as RepType
    ) a
    --order by a.CRMCallCardID

end


GO

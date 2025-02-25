USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0293a]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0293a]
as
begin

/****************************************************************************************************/
--  Name:           dbo.[rptsp_rpt0293a]
--  Author:         Leonardus Setyabudi
--  Date Created:   20120222
--  Description:    This stored procedure return claim's average value in 3 years span of quarters
--  Parameters:     
--  Change History: 20120222 - LS - Created
--                  20120224 - LS - Break QTD & Full quarter for previous years
--                  20120312 - LS - Remove QTD, not needed by user
--                                - Add 3rd previous quarter
--                  20120314 - LS - Change period to month, this can be made to prompt but made
--                                  based on user requirement
--                  
/****************************************************************************************************/

  set nocount on

  declare @rptStartDate smalldatetime
  declare @rptEndDate smalldatetime

  /* get reporting dates */
  select 
    @rptStartDate = StartDate, 
    @rptEndDate = EndDate
  from [db-au-cmdwh].dbo.vDateRange
  where DateRange = 'Current Month'

  ;with cte_summary as
  (  
    select 
      cb.BenefitDesc Section,
      cb.ProductCode,
      case
        when cl.ReceivedDate >= @rptStartDate then 'Current Month'
        when cl.ReceivedDate >= dateadd(year, -1, @rptStartDate) then 'Previous Year Month'
        when cl.ReceivedDate >= dateadd(year, -2, @rptStartDate) then 'Previous 2nd Year Month'
        else 'Previous 3rd Year Month'
      end Period,
      count(distinct cl.ClaimKey) ClaimCount,
      sum(EstimateValue + isnull(Paid, 0)) ClaimValue
    from 
      clmClaim cl 
      inner join clmSection cs on cs.ClaimKey = cl.ClaimKey
      inner join clmBenefit cb on cb.BenefitSectionKey = cs.BenefitSectionKey
      outer apply
      (
        select sum(PaymentAmount) Paid
        from clmPayment cp
        where 
          cp.SectionKey = cs.SectionKey and
          cp.PaymentStatus in ('PAID', 'RECY')
      ) p
    where 
      cl.CountryKey = 'AU' and
      (
        (
          cl.ReceivedDate >= @rptStartDate and
          cl.ReceivedDate <  dateadd(day, 1, @rptEndDate)
        ) or
        (
          cl.ReceivedDate >= dateadd(year, -1, @rptStartDate) and
          cl.ReceivedDate <  dateadd(day, 1, dateadd(year, -1, @rptEndDate))
        ) or
        (
          cl.ReceivedDate >= dateadd(year, -2, @rptStartDate) and
          cl.ReceivedDate <  dateadd(day, 1, dateadd(year, -2, @rptEndDate))
        ) or
        (
          cl.ReceivedDate >= dateadd(year, -3, @rptStartDate) and
          cl.ReceivedDate <  dateadd(day, 1, dateadd(year, -3, @rptEndDate))
        )
      )
    group by
      cb.BenefitDesc,
      cb.ProductCode,
      case
        when cl.ReceivedDate >= @rptStartDate then 'Current Month'
        when cl.ReceivedDate >= dateadd(year, -1, @rptStartDate) then 'Previous Year Month'
        when cl.ReceivedDate >= dateadd(year, -2, @rptStartDate) then 'Previous 2nd Year Month'
        else 'Previous 3rd Year Month'
      end
  )
  select
    Section, 
    ProductCode,
    [Current Month], 
    [Previous Year Month], 
    [Previous 2nd Year Month],
    [Previous 3rd Year Month],
    @rptStartDate StartDate, 
    @rptEndDate EndDate
  from 
  (
    select 
      Section,
      ProductCode,
      Period,
      case
        when ClaimCount = 0 then 0
        else ClaimValue / ClaimCount
      end AvgClaimValue
    from cte_summary
  ) t
  pivot 
  (
    sum(AvgClaimValue)
    for Period in 
    (
      [Current Month], 
      [Previous Year Month], 
      [Previous 2nd Year Month],
      [Previous 3rd Year Month]
    )
  ) pt
  order by 1
  
end
GO

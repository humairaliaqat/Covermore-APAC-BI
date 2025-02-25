USE [db-au-cmdwh]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_CorpNewPolicyCount]    Script Date: 24/02/2025 12:39:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fn_CorpNewPolicyCount] 
(
  @DateRange varchar(30),
  @StartDate varchar(10),
  @EndDate varchar(10)
)
returns 
@output table 
(
  QuoteKey varchar(10) null,
  PolicyNo int null,
  PreviousPolicyNo int null,
  NewPolicyCount int
)
as
begin

  declare 
    @dataStartDate date,
    @dataEndDate date

  if @DateRange <> '_User Defined'
    select 
      @dataStartDate = StartDate, 
      @dataEndDate = EndDate
    from vDateRange
    where DateRange = @DateRange
  
  else if isnull(@StartDate, '') <> '' and isnull(@EndDate, '') <> ''
    select
      @dataStartDate = @StartDate, 
      @dataEndDate = @EndDate
  
  else
    select 
      @dataStartDate = getdate(), 
      @dataEndDate = getdate()

  ;with cte_policies as
  (
    select
      q.QuoteKey,
      q.PolicyNo,
      q.PreviousPolicyNo,
      AccountingPeriod
    from 
      corpQuotes q
      cross apply
      (
        select top 1 AccountingPeriod
        from corpTaxes t
        where 
          AccountingPeriod >= @dataStartDate and
          AccountingPeriod <  dateadd(day, 1, @dataEndDate)
      ) t
    where isPolicy = 1
  )
  insert into @output
  select 
    QuoteKey,
    PolicyNo,
    PreviousPolicyNo,
    case
      when exists
      (
        select null
        from cte_policies t
        where t.PreviousPolicyNo = p.PolicyNo
      ) then 0
      else 1
    end PolicyCount
  from cte_policies p

  return

end


GO

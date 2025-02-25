USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_etl020_PolicyInForceNoDel]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_etl020_PolicyInForceNoDel]
  @StartDate datetime,
  @EndDate datetime,
  @Country varchar(2) = null

as
begin

  if object_id('tempdb..#policy') is not null
    drop table #policy

  select CountryKey, PolicyNo, IssuedDate
  into #policy
  from [db-au-cmdwh].dbo.Policy p
  where
    IssuedDate >= @StartDate and
    IssuedDate <  dateadd(day, 1, @EndDate) and
    (
      @Country is null or
      CountryKey = @Country
    ) and
    (
      IssuedDate >= '2010-07-01' or -- hardcode, due to space issue data will be limited for the past 2 FY
      ReturnDate >= '2010-07-01'
    )


  insert into [db-au-cmdwh].dbo.usrPolicyInForce (CountryKey, PolicyNo, DateInForce)
  select
    CountryKey,
    PolicyNo,
    d.Date
  from
    [db-au-cmdwh].dbo.Policy p
    cross apply dbo.fn_GenerateDates(IssuedDate, ReturnDate) d
  where
    IssuedDate >= @StartDate and
    IssuedDate <  dateadd(day, 1, @EndDate) and
    (
      @Country is null or
      CountryKey = @Country
    ) and
    (
      IssuedDate >= '2010-07-01' or -- hardcode, due to space issue data will be limited for the past 2 FY
      ReturnDate >= '2010-07-01'
    ) and
    DepartureDate <= dateadd(year, 2, IssuedDate) and -- exclude policies with departure date more than 2 years from issued date (most likely erronous data)
    d.Date >= '2010-07-01'

end



GO

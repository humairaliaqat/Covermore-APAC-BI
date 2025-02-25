USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_financeadmin_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[etlsp_cmdwh_financeadmin_rollup]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:
Prerequisite:
Description:
Change History:
                20130129 - LS - case 18180, NZ: use the same TRIPS schema as AU

*************************************************************************************************************************************/

    set nocount on


    if object_id('[db-au-stage].dbo.etl_financeadmin') is not null drop table [db-au-stage].dbo.etl_financeadmin

    select
      'AU' as CountryKey,
      f.id as ID,
      f.Name,
      f.Initial,
      f.Phone,
      f.Email,
      f.Fax,
      f.InUse
    into [db-au-stage].dbo.etl_financeadmin
    from
      [db-au-stage].dbo.trips_financeadmin_au f


    union all

    select
      'NZ' as CountryKey,
      f.id as ID,
      f.Name,
      f.Initial,
      f.Phone,
      f.Email,
      f.Fax,
      f.InUse
    from
      [db-au-stage].dbo.trips_financeadmin_nz f

    union all

    select
      'UK' as CountryKey,
      f.id as ID,
      f.Name,
      f.Initial,
      f.Phone,
      f.Email,
      f.Fax,
      f.InUse
    from
      [db-au-stage].dbo.trips_financeadmin_uk f

    union all

    select
      'MY' as CountryKey,
      f.id as ID,
      f.Name,
      f.Initial,
      f.Phone,
      f.Email,
      f.Fax,
      f.InUse
    from
      [db-au-stage].dbo.trips_financeadmin_my f

    union all

    select
      'SG' as CountryKey,
      f.id as ID,
      f.Name,
      f.Initial,
      f.Phone,
      f.Email,
      f.Fax,
      f.InUse
    from
      [db-au-stage].dbo.trips_financeadmin_sg f


    if object_id('[db-au-cmdwh].dbo.FinanceAdmin') is null
    begin
      create table [db-au-cmdwh].dbo.FinanceAdmin
      (
        CountryKey varchar(2) NOT NULL,
        ID int NULL,
        Name varchar(100) NULL,
        Initial varchar(4) NULL,
        Phone varchar(20) NULL,
        Email varchar(100) NULL,
        Fax varchar(50) NULL,
        InUse bit NULL
      )
      if exists(select name from sys.indexes where name = 'idx_FinanceAdmin_CountryKey')
        drop index idx_FinanceAdmin_CountryKey on FinanceAdmin.CountryKey

      create index idx_FinanceAdmin_CountryKey on [db-au-cmdwh].dbo.FinanceAdmin(CountryKey)
    end
    else
    begin
      truncate table [db-au-cmdwh].dbo.FinanceAdmin
    end



    -- Transfer data from [db-au-stage].dbo.etl_bank to [db-au-cmdwh].dbo.Bank
    insert into [db-au-cmdwh].dbo.FinanceAdmin with (tablock)
    (
        CountryKey,
        ID,
        Name,
        Initial,
        Phone,
        Email,
        Fax,
        InUse
    )
    select * from [db-au-stage].dbo.etl_financeadmin

end


GO

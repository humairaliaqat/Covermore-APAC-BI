USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0139_Test_INC0319227]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[rptsp_rpt0139_Test_INC0319227]  
    @Country varchar(2),  
    @Company varchar(10) = 'ALL',  
    @Underwriter varchar(15) = 'ALL',  
    @ReportingPeriod varchar(30),  
    @StartDate datetime = null,  
    @EndDate datetime = null  
      
as  
begin  
/****************************************************************************************************/  
--  Name:           rptsp_rpt0139  
--  Author:         Leonardus S  
--  Date Created:   20130806  
--  Description:    This stored procedure returns bank adjustments  
--  Parameters:       
--     
--  Change History:  
--                  20130808 - LS - exclude cancelled allocations  
--                                  include cheque number for new crm  
--                  20140313 - LS - decrypt account number  
--                  20141208 - LS - F22499, corporate data  
--                  20141209 - LS - F22499, bank payment not necesarily must have quote record  
--                  20150404 - LS - F22935, ETIQA & CCIC  
--                  20150722 - LS - Simas Net UW  
--     20170601 - LT - Updated UW definition as part of Zurich UW changeover  
--     20170630 - LT - Updated UW definition for APOTC  
--     20171101 - LT - Updated UW definition for ETI and ERV  
--  
/****************************************************************************************************/  
  
--uncomment to debug  
--declare  
--    @Country varchar(2),  
--    @Company varchar(5) = 'ALL',  
--    @Underwriter varchar(15) = 'ALL',  
--    @ReportingPeriod varchar(30),  
--    @StartDate datetime = null,  
--    @EndDate datetime = null  
--select  
--    @Country = 'AU',  
--    @Company = 'ALL',  
--    @Underwriter = 'ALL',  
--    @ReportingPeriod = 'Last Month'  
  
    set nocount on  
  
    declare   
        @rptStartDate datetime,  
        @rptEndDate datetime  
    declare  
        @output table  
        (  
            CreateDateTime datetime,  
            AlphaCode nvarchar(20),  
            OutletName nvarchar(50),  
            CRMUser nvarchar(101),  
            AdjustmentType varchar(30),  
            Amount money,  
            AccountCode varchar(5),  
            RefundChq varchar(255),  
            AccountNumber varchar(255),  
            BSB nvarchar(50),  
            Comments varchar(255),  
            PaymentAllocationID int,  
            StartDate datetime,  
            EndDate datetime,
			Underwriter   varchar(500)
        )  
  
    /* get reporting dates */  
    if @ReportingPeriod = '_User Defined'  
        select  
            @rptStartDate = @StartDate,  
            @rptEndDate = @EndDate  
    else  
        select  
            @rptStartDate = StartDate,  
            @rptEndDate = EndDate  
        from  
            vDateRange  
        where  
            DateRange = @ReportingPeriod  
  
    insert into @output  
    (  
        CreateDateTime,  
        AlphaCode,  
        OutletName,  
        CRMUser,  
        AdjustmentType,  
        Amount,  
        AccountCode,  
        RefundChq,  
        AccountNumber,  
        BSB,  
        Comments,  
        PaymentAllocationID,  
        StartDate,  
        EndDate,
		Underwriter  
    )  
    select    
        pa.CreateDateTime,  
        o.AlphaCode,  
        o.OutletName,  
        cu.FirstName + ' ' + cu.LastName CRMUser,  
        paa.AdjustmentType,  
        paa.Amount,  
        o.CompanyKey AccountCode,  
        case  
            when pa.Source = 'MIGRATION' then paa.Comments  
            else prt.ChequeNumber  
        end RefundChq,  
        convert(varchar(255), decryptbykeyautocert(cert_id('PenguinThirdPartyCertificate'), null, o.EncryptedAccountNumber, 0, null)) AccountNumber,  
        o.BSB,  
        pa.Comments,  
        pa.PaymentAllocationID,  
        @rptStartDate StartDate,  
        @rptEndDate EndDate,
		uw.Underwriter 
    from  
        [db-au-cmdwh]..penPaymentAllocation pa  
        inner join [db-au-cmdwh]..penPaymentAllocationAdjustment paa on  
            paa.PaymentAllocationKey = pa.PaymentAllocationKey  
        inner join [db-au-cmdwh]..penOutlet o on  
            o.OutletKey = pa.OutletKey and  
            o.OutletStatus = 'Current'  
        left join [db-au-cmdwh]..penCRMUser cu on  
            cu.CRMUserKey = pa.CRMUserKey   
        outer apply  
        (  
            select top 1  
                ChequeNumber  
            from  
                [db-au-cmdwh]..penPaymentRegisterTransaction prt  
            where  
                prt.PaymentAllocationKey = pa.PaymentAllocationKey  
        ) prt  
		 outer apply(
 select
 case   
                when pa.CompanyKey = 'TIP' and (pa.CreateDateTime < '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pa.CreateDateTime < '2017-07-01')) then 'TIP-GLA'  
    when pa.CompanyKey = 'TIP' and (pa.CreateDateTime >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pa.CreateDateTime >= '2017-07-01')) then 'TIP-ZURICH'  
    when pa.CountryKey in ('AU', 'NZ') and pa.CreateDateTime >= '2009-07-01' and pa.CreateDateTime < '2017-06-01' then 'GLA'  
    when pa.CountryKey in ('AU', 'NZ') and pa.CreateDateTime >= '2017-06-01' then 'ZURICH'   
                when pa.CountryKey in ('AU', 'NZ') and pa.CreateDateTime between '2002-08-23' and '2009-06-30' then 'VERO'   
                when pa.CountryKey in ('UK') and pa.CreateDateTime >= '2009-09-01' and pa.CreateDateTime < '2017-07-01' then 'ETI'   
    when pa.CountryKey in ('UK') and pa.CreateDateTime >= '2017-07-01' then 'ERV'   
                when pa.CountryKey in ('UK') and pa.CreateDateTime < '2009-09-01' then 'UKU'   
                when pa.CountryKey in ('MY', 'SG') then 'ETIQA'  
                when pa.CountryKey in ('CN') then 'CCIC'  
                when pa.CountryKey in ('ID') then 'Simas Net'  
                else 'OTHER'   
            end Underwriter
        ) uw
    where  
        o.CountryKey = @Country and  
        (  
            @Company = 'ALL' or  
            o.CompanyKey = @Company  
        ) and  
        (  
            @Underwriter = 'ALL' or  
            case   
                when pa.CompanyKey = 'TIP' and (pa.CreateDateTime < '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pa.CreateDateTime < '2017-07-01')) then 'TIP-GLA'  
    when pa.CompanyKey = 'TIP' and (pa.CreateDateTime >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and pa.CreateDateTime >= '2017-07-01')) then 'TIP-ZURICH'  
    when pa.CountryKey in ('AU', 'NZ') and pa.CreateDateTime >= '2009-07-01' and pa.CreateDateTime < '2017-06-01' then 'GLA'  
    when pa.CountryKey in ('AU', 'NZ') and pa.CreateDateTime >= '2017-06-01' then 'ZURICH'   
                when pa.CountryKey in ('AU', 'NZ') and pa.CreateDateTime between '2002-08-23' and '2009-06-30' then 'VERO'   
                when pa.CountryKey in ('UK') and pa.CreateDateTime >= '2009-09-01' and pa.CreateDateTime < '2017-07-01' then 'ETI'   
    when pa.CountryKey in ('UK') and pa.CreateDateTime >= '2017-07-01' then 'ERV'   
                when pa.CountryKey in ('UK') and pa.CreateDateTime < '2009-09-01' then 'UKU'   
                when pa.CountryKey in ('MY', 'SG') then 'ETIQA'  
                when pa.CountryKey in ('CN') then 'CCIC'  
                when pa.CountryKey in ('ID') then 'Simas Net'  
                else 'OTHER'   
            end = @Underwriter  
        ) and  
        pa.CreateDateTime >= @rptStartDate and  
        pa.CreateDateTime <  dateadd(day, 1, @rptEndDate) and  
        pa.Status <> 'CANCELLED'  
  
  
    insert into @output  
    (  
        CreateDateTime,  
        AlphaCode,  
        OutletName,  
        CRMUser,  
        AdjustmentType,  
        Amount,  
        AccountCode,  
        RefundChq,  
        AccountNumber,  
        BSB,  
        Comments,  
        PaymentAllocationID,  
        StartDate,  
        EndDate,
		Underwriter  
    )  
    select   
        cb.BankDate CreateDateTime,  
        o.AlphaCode,  
        o.OutletName,  
        u.FullName CRMUser,  
        'REFUND' AdjustmentType,  
        cb.Adjustment Amount,  
        o.CompanyKey AccountCode,  
        cb.RefundCheque RefundChq,  
        convert(varchar(255), decryptbykeyautocert(cert_id('PenguinThirdPartyCertificate'), null, o.EncryptedAccountNumber, 0, null)) AccountNumber,  
        o.BSB,  
        cb.Comments Comments,  
        cb.BankRecord PaymentAllocationID,  
        @rptStartDate StartDate,  
        @rptEndDate EndDate,
		uw.Underwriter  
    from  
        [db-au-cmdwh]..corpBank cb  
        inner join [db-au-cmdwh]..penOutlet o on  
            o.AlphaCode = cb.AgencyCode and  
            o.CountryKey = cb.CountryKey and  
            o.OutletStatus = 'Current'  
        outer apply  
        (  
            select top 1  
                FullName  
            from   
                [db-au-cmdwh]..corpSecurity cs  
            where  
                cs.Login = cb.Operator  
        ) u 
		outer apply(
		select 
 case   
                when o.CompanyKey = 'TIP' and (cb.BankDate < '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and cb.BankDate < '2017-07-01')) then 'TIP-GLA'  
    when o.CompanyKey = 'TIP' and (cb.BankDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and cb.BankDate >= '2017-07-01')) then 'TIP-ZURICH'  
                when o.CountryKey in ('AU', 'NZ') and cb.BankDate>= '2009-07-01' and cb.BankDate < '2017-06-01' then 'GLA'   
    when o.CountryKey in ('AU', 'NZ') and cb.BankDate>= '2017-06-01' then 'ZURICH'   
                when o.CountryKey in ('AU', 'NZ') and cb.BankDate between '2002-08-23' and '2009-06-30' then 'VERO'   
                when o.CountryKey in ('UK') and cb.BankDate >= '2009-09-01' and cb.BankDate < '2017-07-01' then 'ETI'   
    when o.CountryKey in ('UK') and cb.BankDate >= '2017-07-01' then 'ERV'   
                when o.CountryKey in ('UK') and cb.BankDate < '2009-09-01' then 'UKU'   
                when o.CountryKey in ('MY', 'SG') then 'ETIQA'  
                when o.CountryKey in ('CN') then 'CCIC'  
                when o.CountryKey in ('ID') then 'Simas Net'  
                else 'OTHER'   
            end Underwriter  )uw
    where  
        o.CountryKey = @Country and  
        @Company in ('CORPORATE') and  
        (  
            @Underwriter = 'ALL' or  
            case   
                when o.CompanyKey = 'TIP' and (cb.BankDate < '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and cb.BankDate < '2017-07-01')) then 'TIP-GLA'  
    when o.CompanyKey = 'TIP' and (cb.BankDate >= '2017-06-01' OR (o.AlphaCode in ('APN0004','APN0005') and cb.BankDate >= '2017-07-01')) then 'TIP-ZURICH'  
                when o.CountryKey in ('AU', 'NZ') and cb.BankDate>= '2009-07-01' and cb.BankDate < '2017-06-01' then 'GLA'   
    when o.CountryKey in ('AU', 'NZ') and cb.BankDate>= '2017-06-01' then 'ZURICH'   
                when o.CountryKey in ('AU', 'NZ') and cb.BankDate between '2002-08-23' and '2009-06-30' then 'VERO'   
                when o.CountryKey in ('UK') and cb.BankDate >= '2009-09-01' and cb.BankDate < '2017-07-01' then 'ETI'   
    when o.CountryKey in ('UK') and cb.BankDate >= '2017-07-01' then 'ERV'   
                when o.CountryKey in ('UK') and cb.BankDate < '2009-09-01' then 'UKU'   
                when o.CountryKey in ('MY', 'SG') then 'ETIQA'  
                when o.CountryKey in ('CN') then 'CCIC'  
                when o.CountryKey in ('ID') then 'Simas Net'  
                else 'OTHER'   
            end = @Underwriter  
        ) and  
        cb.BankDate >= @rptStartDate and  
        cb.BankDate <  dateadd(day, 1, @rptEndDate)  
  
              
    select    
        CreateDateTime,  
        AlphaCode,  
        OutletName,  
        CRMUser,  
        AdjustmentType,  
        Amount,  
        AccountCode,  
        RefundChq,  
        AccountNumber,  
        BSB,  
        Comments,  
        PaymentAllocationID,  
        StartDate,  
        EndDate,
		Underwriter  
    from  
        @output  
                  
end  
  
  
  
  

GO

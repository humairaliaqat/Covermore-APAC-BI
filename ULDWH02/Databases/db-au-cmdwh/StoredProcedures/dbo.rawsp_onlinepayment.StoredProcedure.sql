USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rawsp_onlinepayment]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rawsp_onlinepayment]
    @Country varchar(2),
    @AgencyGroup varchar(2),
    @DateRange varchar(30),
    @StartDate date = null,
    @EndDate date = null
  
as
begin  

/****************************************************************************************************/
--  Name:           rawsp_onlinepayment
--  Author:         Leonardus Setyabudi
--  Date Created:   20111024
--  Description:    This stored procedure extract online payment data for given parameters
--  Parameters:     @Country: Country Code; e.g. AU
--                  @AgencyGroup: Agency group code; e.g. AP, FL 
--                  @DateRange: Value is valid date range
--                  @StartDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--                  @EndDate: if @DateRange = _User Defined. Use valid date format e.g yyyy-mm-dd
--  
--  Change History:  
--                  20111024 - LS - Created
--                  20140129 - LS - migrate to penguin data set
--					20160830 - PZ - Include AHM (groupcode = 'AH') in Medibank (groupcode = 'MB') extract 
--
/****************************************************************************************************/
--uncomment to debug
/*
declare @Country varchar(2)
declare @AgencyGroup varchar(2)
declare @DateRange varchar(30)
declare @StartDate date
declare @EndDate date
select 
    @Country = 'AU', 
    @AgencyGroup = 'MB',
    @DateRange = 'Yesterday'
*/

    set nocount on 

    declare @dataStartDate date
    declare @dataEndDate date

    /* get dates */
    if @DateRange = '_User Defined'
        select 
            @dataStartDate = @StartDate,
            @dataEndDate = @EndDate

    else
        select 
            @dataStartDate = StartDate, 
            @dataEndDate = EndDate
        from 
            vDateRange
        where 
            DateRange = @DateRange


    select
        pt.PolicyNumber PolicyNo,
        op.PaymentID PayID,
        op.PaymentRefID MerchantTxtRef,
        op.OrderId OrderInfo,
        op.MerchantID,
        op.Total AmountPaid,
        op.ReceiptNo,
        op.ResponseDescription,
        op.TransactionNo,
        op.AuthoriseID,
        op.BatchNo,
        op.CardType,
        op.TransTime RecordDate
    from 
        penOutlet o
        inner join penPolicyTransSummary pt on 
            pt.OutletAlphaKey = o.OutletAlphaKey
        inner join penPayment op on 
            op.PolicyTransactionKey = pt.PolicyTransactionKey
    where 
        o.CountryKey = @Country and
		o.GroupCode in (select @AgencyGroup as [AgencyGroupCode] where @AgencyGroup <> 'MB' union all select 'MB' where @AgencyGroup = 'MB' union all select 'AH' where @AgencyGroup = 'MB') and
        o.OutletStatus = 'Current' and
        op.TransTime >= @dataStartDate and 
        op.TransTime <  dateadd(day, 1, @dataEndDate)
    
end
GO

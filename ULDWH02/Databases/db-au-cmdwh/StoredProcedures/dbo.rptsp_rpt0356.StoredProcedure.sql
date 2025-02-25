USE [db-au-cmdwh]
GO
/****** Object:  StoredProcedure [dbo].[rptsp_rpt0356]    Script Date: 24/02/2025 12:39:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[rptsp_rpt0356]	
    @ReportingPeriod varchar(30) = 'Yesterday',
    @StartDate varchar(10) = null,
    @EndDate varchar(10) = null,
    @ClientID int = null
    
as
begin
/****************************************************************************************************/
--  Name:           rptsp_rpt0356
--  Author:         Linus Tor
--  Date Created:   20120917
--  Description:    This stored procedure returns Approved/Denied status for EMC conditions where Client
--					email address field is empty
--  Parameters:     @ReportingPeriod: standard date range or _User Defined
--					@StartDate: if _User Defined. Format: YYYY-MM-DD eg. 2012-01-01
--					@EndDate: if_User Defined. Format: YYYY-MM-DD eg. 2012-01-01
--   
--  Change History: 20120917 - LT - Created
--					20121022 - LT - Amended stored procedure to filter application status and payment
--									conditions
--					20130802 - LT - Added AgencyCode filter to ('BMN0002','BSN0002','SGN0002','AUS0002','BWN0002','CBN0002','WPN0002')
--                  20140827 - LS - F21668, refactoring
--                  
/****************************************************************************************************/

--uncomment to debug
--declare 
--    @ReportingPeriod varchar(30),
--    @StartDate varchar(10),
--    @EndDate varchar(10),
--    @ClientID int
--select 
--    @ClientID = 11003962

    set nocount on

    /* get reporting dates */
    declare 
        @rptStartDate date,
        @rptEndDate date

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

    select 
	    e.ApplicationID ClientID,
	    e.AssessedDate AssessedDate,
	    e.Destination,
	    e.DepartureDate,
	    e.ReturnDate,
	    m.MedicalID [Counter],
	    m.Condition,
	    case 
            when e.ApprovalStatus in ('NotCovered', 'PolicyDenied') then 'D'
            else left(m.ConditionStatus, 1)
	    end DeniedAccepted,
	    n.Title ClientTitle,
	    n.Firstname ClientFirstName,
	    n.Surname ClientSurname,
	    convert(varchar(255), decryptbykeyautocert(cert_id('EMCCertificate'), null, n.Street, 0, null)) ClientStreet,
	    convert(varchar, decryptbykeyautocert(cert_id('EMCCertificate'), null, n.Suburb, 0, null)) ClientSuburb,
	    convert(varchar, decryptbykeyautocert(cert_id('EMCCertificate'), null, n.State, 0, null)) ClientState,
	    convert(varchar, decryptbykeyautocert(cert_id('EMCCertificate'), null, n.PostCode, 0, null)) ClientPostCode,
	    convert(varchar, decryptbykeyautocert(cert_id('EMCCertificate'), null, n.Email, 0, null)) ClientEmail,
	    c.CompanyName BankName,
	    e.ProductType CardType,
	    c.Phone CompanyPhone,
	    e.ApprovalStatus,
	    isnull(p.EMCPremium, 0) AmountPaid,
	    isnull(p.GST, 0) GST,
	    p.ReceiptNo TransactionNo,
	    e.AgeApprovalStatus AgeApproval,
	    @rptStartDate StartDate,
	    @rptEndDate EndDate
    from 
	    emcApplications e
	    inner join emcMedical m on 
	        e.ApplicationKey = m.ApplicationKey
	    inner join emcApplicants n on 
	        e.ApplicationKey = n.ApplicationKey
	    inner join emcCompanies c on 
	        e.CompanyKey = c.CompanyKey
	    left join emcPayment p on 
	        e.ApplicationKey = p.ApplicationKey
    where
	    m.ConditionStatus in ('Approved', 'Denied') and	
	    e.AgencyCode in 
	    (
	        'BMN0002', 
	        'BSN0002', 
	        'SGN0002', 
	        'AUS0002', 
	        'BWN0002', 
	        'CBN0002', 
	        'WPN0002'
	    ) and
	    ltrim(rtrim(c.ParentCompanyName)) = 'Zurich' and
	    isnull(convert(varchar(8000), decryptbykeyautocert(cert_id('EMCCertificate'), null, n.Email, 0, null)), '') = '' and
	    (
	        (
	            isnull(@ClientID, 0) <> 0 and
	            e.ApplicationID = @ClientID
	        ) or
	        (
	            isnull(@ClientID, 0) = 0 and
	            e.AssessedDate >= @rptStartDate and
	            e.AssessedDate <  dateadd(day, 1, @rptEndDate)
	        )
	    ) and
	    (
            (
                e.ApprovalStatus = 'Covered' and 
                p.ReceiptNo is not null
            ) or
            (
                e.ApprovalStatus in ('NotCovered', 'PolicyDenied') and 
                p.ReceiptNo is null
            )
	    )
    order by 
        e.ApplicationID,
        m.MedicalID


end
GO

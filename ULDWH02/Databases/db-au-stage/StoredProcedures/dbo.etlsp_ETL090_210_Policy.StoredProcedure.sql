USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL090_210_Policy]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:        Vincent Lam
-- create date:
-- Description:    23/09/2017
-- Modified:
--	20180208 - DM - ADjusted to bring in Clientele Contract Debtor Code
-- =============================================
CREATE PROCEDURE [dbo].[etlsp_ETL090_210_Policy]
AS
BEGIN

    SET NOCOUNT ON;

-- Contract => Policy
-- ContractService => PolicyCoverage
-- ContractServiceActivity => PolicyCoverageRate

/*
note:
    the penelope custom migration splits some Clientele contracts into multiple policies, but it makes sense to map each contract to one policy.
    so here just load all the contracts from Clientele into ODS
    this will be fine because no report is done on the policy level, and the custom migration didn't import the events fact

stage tables:
    [db-au-stage]..dtc_cli_Contract

pnpPolicy:
    PolicySK
    FunderSK
    PolicyID                        'CLI_CON_' + Contract_ID
    FunderID                        'CLI_ORG_' + ORG_ID
    PublicPolicyID
    Class                            'Public' / 'Group'
    PublicPolicyFunderID            'CLI_ORG_' + ORG_ID
    PublicPolicyName
    PublicPolicyNumber
    PublicPolicyCategory
    PublicPolicyStatus
    PublicPolicyNoShow
    PublicPolicyStart
    PublicPolicyEnd
    PublicPolicyNote
    PublicPolicyCreatedDateTime
    PublicPolicyUpdatedDateTime
    PublicPolicyType
    PublicPolicyDisableFFS
    PublicPolicyPayableToSiteID        OwnerState
    Type                            BillingCategory = CASE BillingType WHEN 'Fixed Fee' THEN 'FF' WHEN 'Fee for Service' THEN 'FFS' WHEN 'Pre-Paid' THEN 'PP' END
                                    CASE
                                        WHEN cs.BillingType = 'Pre-Paid' THEN 'Bank of Hours'
                                        WHEN InvoiceType='Summary Split by PO' THEN 'Summary'
                                        WHEN InvoiceType='Individual by Feedback Person' THEN 'Itemised'
                                        WHEN InvoiceType='Summary by Feedback Person' THEN 'Summary'
                                        WHEN InvoiceType='Both - Indiv + Summary' THEN 'Summary'
                                        WHEN InvoiceType='Summary by ServiceType Grouping' THEN 'Summary'
                                        WHEN InvoiceType='Individual - Address by BU' THEN 'Itemised'
                                        WHEN InvoiceType='Special Invoice' THEN 'Other'
                                        WHEN InvoiceType='Summary split by BU' THEN 'Summary'
                                        WHEN InvoiceType='Summary by Cost Centre' THEN 'Summary'
                                        WHEN InvoiceType='Summary' THEN 'Summary'
                                        WHEN InvoiceType='Summary with Special Page' THEN 'Other'
                                        ELSE 'Itemised'
                                    END
    PolicyNumber                    ContractNumber
    Name                            ContractNumber
    Status                            StatusFlag
    PolicyCon
    Comments
    CreatedDatetime                    AddDate
    UpdatedDatetime                    ChangeDate
    CreatedBy                        AddUser
    UpdatedBy                        ChangeUser
    Sign
    Accept
    FunderContactID
    Disableffs
    SignDatetime
    DisableFeeOvr
    Disabless
    Inclusive
    Corp
    BlueBookID
    PriceLevelID
    SearchDepartmentTreeForBillTo
    PayableToSiteID
    InvoiceCurrencyCode
    InvoiceCurrencyCountry
    InvoiceCurrencySign
*/


-- 1. transform
if object_id('tempdb..#src') is not null drop table #src
;with gp as (
    select
        cs.Contract_id Contract_id
    from
        [db-au-stage].dbo.dtc_cli_ContractService cs
        join [db-au-stage].dbo.dtc_cli_ServiceType st on st.ServiceType_ID = cs.ServiceType_Id
    where
        st.ServiceType in ('employeeAssist','managerAssist','Nutrition@DTC')
)
select
    coalesce(pf.FunderSK, f.FunderSK) FunderSK,
    'CLI_CON_' + c.Contract_ID PolicyID,
    'CLI_ORG_' + c.ORG_ID FunderID,
    case
        when exists (select 1 from gp where gp.Contract_id = c.Contract_id) then 'Group'
        else 'Public'
    end Class,
    c.ContractNumber PolicyNumber,
    c.ContractNumber Name,
    c.StatusFlag Status,
    c.AddDate CreatedDatetime,
    c.ChangeDate UpdatedDatetime,
    c.AddUser CreatedBy,
    c.ChangeUser UpdatedBy,
    case
        when ltrim(rtrim(c.OwnerState)) = 'ACT' then '34'
        when ltrim(rtrim(c.OwnerState)) = 'DC' then '40'
        when ltrim(rtrim(c.OwnerState)) = 'EAP' then '35'
        when ltrim(rtrim(c.OwnerState)) = 'EES' then '36'
        when ltrim(rtrim(c.OwnerState)) = 'HRN' then '37'
        when ltrim(rtrim(c.OwnerState)) = 'MW' then '38'
        when ltrim(rtrim(c.OwnerState)) = 'NSW' then '14'
        when ltrim(rtrim(c.OwnerState)) = 'PERF' then '39'
        when ltrim(rtrim(c.OwnerState)) = 'QLD' then '18'
        when ltrim(rtrim(c.OwnerState)) = 'SA' then '41'
        when ltrim(rtrim(c.OwnerState)) = 'SNG' then '32'
        when ltrim(rtrim(c.OwnerState)) = 'TAS' then '42'
        when ltrim(rtrim(c.OwnerState)) = 'VIC' then '17'
        when ltrim(rtrim(c.OwnerState)) = 'WA' then '16'
		when ltrim(rtrim(c.OwnerState)) = 'PRIME' then '16'
        else null
    end PublicPolicyPayableToSiteID,
    case
        when ltrim(rtrim(c.OwnerState)) = 'ACT' then '34'
        when ltrim(rtrim(c.OwnerState)) = 'DC' then '40'
        when ltrim(rtrim(c.OwnerState)) = 'EAP' then '35'
        when ltrim(rtrim(c.OwnerState)) = 'EES' then '36'
        when ltrim(rtrim(c.OwnerState)) = 'HRN' then '37'
        when ltrim(rtrim(c.OwnerState)) = 'MW' then '38'
        when ltrim(rtrim(c.OwnerState)) = 'NSW' then '14'
        when ltrim(rtrim(c.OwnerState)) = 'PERF' then '39'
        when ltrim(rtrim(c.OwnerState)) = 'QLD' then '18'
        when ltrim(rtrim(c.OwnerState)) = 'SA' then '41'
        when ltrim(rtrim(c.OwnerState)) = 'SNG' then '32'
        when ltrim(rtrim(c.OwnerState)) = 'TAS' then '42'
        when ltrim(rtrim(c.OwnerState)) = 'VIC' then '17'
        when ltrim(rtrim(c.OwnerState)) = 'WA' then '16'
		when ltrim(rtrim(c.OwnerState)) = 'PRIME' then '16'
        else null
    end PayableToSiteID,
    pt.[Type],
	C.DebtorCode
into #src
from
    [db-au-stage].dbo.dtc_cli_Contract c
    outer apply (select top 1 FunderSK from [db-au-dtc]..pnpFunder where FunderID = 'CLI_ORG_' + c.ORG_ID) f
    left join [db-au-stage]..dtc_cli_base_org bo on bo.org_id = c.org_id
    left join [db-au-stage]..dtc_cli_org_lookup ol on ol.uniquefunderid = bo.pene_id
    outer apply (select top 1 FunderSK from [db-au-dtc]..pnpFunder where FunderID = convert(varchar, ol.kfunderid)) pf
    outer apply (
        select top 1
            CASE
                WHEN cs.BillingType = 'Pre-Paid' THEN 'Bank of Hours'
                WHEN it.InvoiceTypeName ='Summary Split by PO' THEN 'Summary'
                WHEN it.InvoiceTypeName ='Individual by Feedback Person' THEN 'Itemised'
                WHEN it.InvoiceTypeName ='Summary by Feedback Person' THEN 'Summary'
                WHEN it.InvoiceTypeName ='Both - Indiv + Summary' THEN 'Summary'
                WHEN it.InvoiceTypeName ='Summary by ServiceType Grouping' THEN 'Summary'
                WHEN it.InvoiceTypeName ='Individual - Address by BU' THEN 'Itemised'
                WHEN it.InvoiceTypeName ='Special Invoice' THEN 'Other'
                WHEN it.InvoiceTypeName ='Summary split by BU' THEN 'Summary'
                WHEN it.InvoiceTypeName ='Summary by Cost Centre' THEN 'Summary'
                WHEN it.InvoiceTypeName ='Summary' THEN 'Summary'
                WHEN it.InvoiceTypeName ='Summary with Special Page' THEN 'Other'
                ELSE 'Itemised'
            END [Type]
        from
            [db-au-stage]..dtc_cli_ContractService cs
            join [db-au-stage]..dtc_cli_InvoiceType it on it.InvoiceTypeID = cs.InvoiceType
        where
            cs.Contract_id = c.Contract_ID
    ) pt


-- 2. load
merge [db-au-dtc].dbo.pnpPolicy as tgt
using #src
    on #src.PolicyID = tgt.PolicyID
when not matched by target then
    insert (
        FunderSK,
        PolicyID,
        FunderID,
        Class,
        PolicyNumber,
        Name,
        Status,
        CreatedDatetime,
        UpdatedDatetime,
        CreatedBy,
        UpdatedBy,
        PublicPolicyPayableToSiteID,
        PayableToSiteID,
        Type,
		ClienteleDebtorCode
    )
    values (
        #src.FunderSK,
        #src.PolicyID,
        #src.FunderID,
        #src.Class,
        #src.PolicyNumber,
        #src.Name,
        #src.Status,
        #src.CreatedDatetime,
        #src.UpdatedDatetime,
        #src.CreatedBy,
        #src.UpdatedBy,
        #src.PublicPolicyPayableToSiteID,
        #src.PayableToSiteID,
        #src.Type,
		#src.DebtorCode
    )
when matched then
    update set
        tgt.FunderSK = #src.FunderSK,
        tgt.PolicyID = #src.PolicyID,
        tgt.FunderID = #src.FunderID,
        tgt.Class = #src.Class,
        tgt.PolicyNumber = #src.PolicyNumber,
        tgt.Name = #src.Name,
        tgt.Status = #src.Status,
        tgt.CreatedDatetime = #src.CreatedDatetime,
        tgt.UpdatedDatetime = #src.UpdatedDatetime,
        tgt.CreatedBy = #src.CreatedBy,
        tgt.UpdatedBy = #src.UpdatedBy,
        tgt.PublicPolicyPayableToSiteID = #src.PublicPolicyPayableToSiteID,
        tgt.PayableToSiteID = #src.PayableToSiteID,
        tgt.Type = #src.Type,
		tgt.ClienteleDebtorCode = #src.DebtorCode
;


update p set
    PublicPolicyPayableToSiteSK = pppts.PublicPolicyPayableToSiteSK,
    PayableToSiteSK = pts.PayableToSiteSK
from
    [db-au-dtc]..pnpPolicy p
    join #src s on s.PolicyID = p.PolicyID
    outer apply (
        select top 1 SiteSK PublicPolicyPayableToSiteSK
        from [db-au-dtc]..pnpSite
        where SiteID = s.PublicPolicyPayableToSiteID
    ) pppts
    outer apply (
        select top 1 SiteSK PayableToSiteSK
        from [db-au-dtc]..pnpSite
        where SiteID = s.PayableToSiteID
    ) pts


END
GO

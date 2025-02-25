USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_stationeryorder_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_stationeryorder_rollup]
as
begin
/*
20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
                        
*/

    set nocount on

    if object_id('etl_StationeryOrder_penguin') is not null
        drop table etl_StationeryOrder_penguin

    select
        dk.CountryKey,
        dk.CompanyKey,
        PrefixKey + convert(varchar, so.ID) StationeryKey,
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,
        so.ID StationeryID,
        so.OrderDate DateCreated,
        u.Initial ConsultantInitial,
        o.AlphaCode AgencyCode,
        sum(
            case
                when p.ProductDisplayName = 'Options' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) OptionsBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Options' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) OptionsPricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Travelsure' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) TravelsureBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Travelsure' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) TravelsurePricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Essentials' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) EssentialsBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Essentials' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) EssentialsPricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Savemore' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) SaveMoreBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Business' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) BusinessBrochure,
        0 STABrochure,
        0 STAPricingGuide,
        sum(
            case
                when st.Name = 'Corporate' then sod.Quantity
                else 0
            end
        ) CorporateBrochure,
        0 CorporateQuotes,
        sum(
            case
                when p.ProductDisplayName = 'Comprehensive' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) ComprehensiveBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Comprehensive' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) ComprehensivePricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Basic' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) BasicBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Basic' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) BasicPricingGuide,
        sum(
            case
                when st.Name = 'Claim Forms' then sod.Quantity
                else 0
            end
        ) ClaimForm,
        sum(
            case
                when st.Name = 'Assessment Forms' then sod.Quantity
                else 0
            end
        ) AssessmentForm,
        sum(
            case
                when st.Name = 'Assistance Cards' then sod.Quantity
                else 0
            end
        ) AssistanceCards,
        sum(
            case
                when st.Name = 'Declaration Pads' then sod.Quantity
                else 0
            end
        ) DeclarationPads,
        0 PolicyWallet,
        0 SalesReturn,
        0 QuickTips,
        so.Comments,
        so.Email
    into etl_StationeryOrder_penguin
    from
        penguin_tblStationeryOrder_aucm so
        inner join penguin_tblOutlet_aucm o on
            o.OutletId = so.OutletID
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'AU') dk
        inner join penguin_tblUser_aucm u on
            u.UserId = so.ConsultantID
        inner join penguin_tblStationeryOrderDetails_aucm sod on
            sod.OrderID = so.ID
        inner join penguin_tblStationeryType_aucm st on
            st.ID = sod.StationeryType
        inner join penguin_tblReferenceValue_aucm rst on
            rst.ID = st.DocumentType
        left join penguin_tblProduct_aucm p on
            p.ProductId = sod.ProductID
    group by
        so.ID,
        so.OrderDate,
        u.Initial,
        o.AlphaCode,
        so.Comments,
        so.Email,
        dk.CountryKey,
        dk.CompanyKey,
        dk.PrefixKey

    insert into etl_StationeryOrder_penguin
    select
        dk.CountryKey,
        dk.CompanyKey,
        PrefixKey + convert(varchar, so.ID) StationeryKey,
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,
        so.ID StationeryID,
        so.OrderDate DateCreated,
        u.Initial ConsultantInitial,
        o.AlphaCode AgencyCode,
        sum(
            case
                when p.ProductDisplayName = 'Options' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) OptionsBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Options' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) OptionsPricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Travelsure' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) TravelsureBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Travelsure' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) TravelsurePricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Essentials' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) EssentialsBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Essentials' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) EssentialsPricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Savemore' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) SaveMoreBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Business' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) BusinessBrochure,
        0 STABrochure,
        0 STAPricingGuide,
        sum(
            case
                when st.Name = 'Corporate' then sod.Quantity
                else 0
            end
        ) CorporateBrochure,
        0 CorporateQuotes,
        sum(
            case
                when p.ProductDisplayName = 'Comprehensive' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) ComprehensiveBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Comprehensive' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) ComprehensivePricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Basic' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) BasicBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Basic' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) BasicPricingGuide,
        sum(
            case
                when st.Name = 'Claim Forms' then sod.Quantity
                else 0
            end
        ) ClaimForm,
        sum(
            case
                when st.Name = 'Assessment Forms' then sod.Quantity
                else 0
            end
        ) AssessmentForm,
        sum(
            case
                when st.Name = 'Assistance Cards' then sod.Quantity
                else 0
            end
        ) AssistanceCards,
        sum(
            case
                when st.Name = 'Declaration Pads' then sod.Quantity
                else 0
            end
        ) DeclarationPads,
        0 PolicyWallet,
        0 SalesReturn,
        0 QuickTips,
        so.Comments,
        so.Email
    from
        penguin_tblStationeryOrder_autp so
        inner join penguin_tblOutlet_autp o on
            o.OutletId = so.OutletID
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'TIP', 'AU') dk
        inner join penguin_tblUser_autp u on
            u.UserId = so.ConsultantID
        inner join penguin_tblStationeryOrderDetails_autp sod on
            sod.OrderID = so.ID
        inner join penguin_tblStationeryType_autp st on
            st.ID = sod.StationeryType
        inner join penguin_tblReferenceValue_autp rst on
            rst.ID = st.DocumentType
        left join penguin_tblProduct_autp p on
            p.ProductId = sod.ProductID
    group by
        so.ID,
        so.OrderDate,
        u.Initial,
        o.AlphaCode,
        so.Comments,
        so.Email,
        dk.CountryKey,
        dk.CompanyKey,
        dk.PrefixKey

    insert into etl_StationeryOrder_penguin
    select
        dk.CountryKey,
        dk.CompanyKey,
        PrefixKey + convert(varchar, so.ID) StationeryKey,
        PrefixKey + ltrim(rtrim(o.AlphaCode)) collate database_default OutletAlphaKey,
        so.ID StationeryID,
        so.OrderDate DateCreated,
        u.Initial ConsultantInitial,
        o.AlphaCode AgencyCode,
        sum(
            case
                when p.ProductDisplayName = 'Options' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) OptionsBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Options' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) OptionsPricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Travelsure' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) TravelsureBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Travelsure' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) TravelsurePricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Essentials' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) EssentialsBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Essentials' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) EssentialsPricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Savemore' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) SaveMoreBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Business' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) BusinessBrochure,
        0 STABrochure,
        0 STAPricingGuide,
        sum(
            case
                when st.Name = 'Corporate' then sod.Quantity
                else 0
            end
        ) CorporateBrochure,
        0 CorporateQuotes,
        sum(
            case
                when p.ProductDisplayName = 'Comprehensive' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) ComprehensiveBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Comprehensive' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) ComprehensivePricingGuide,
        sum(
            case
                when p.ProductDisplayName = 'Basic' and st.Name = 'Brochure' and rst.Value = 'PDS' then sod.Quantity
                else 0
            end
        ) BasicBrochure,
        sum(
            case
                when p.ProductDisplayName = 'Basic' and st.Name = 'Pricing Guide' and rst.Value = 'IBPG' then sod.Quantity
                else 0
            end
        ) BasicPricingGuide,
        sum(
            case
                when st.Name = 'Claim Forms' then sod.Quantity
                else 0
            end
        ) ClaimForm,
        sum(
            case
                when st.Name = 'Assessment Forms' then sod.Quantity
                else 0
            end
        ) AssessmentForm,
        sum(
            case
                when st.Name = 'Assistance Cards' then sod.Quantity
                else 0
            end
        ) AssistanceCards,
        sum(
            case
                when st.Name = 'Declaration Pads' then sod.Quantity
                else 0
            end
        ) DeclarationPads,
        0 PolicyWallet,
        0 SalesReturn,
        0 QuickTips,
        so.Comments,
        so.Email
    from
        penguin_tblStationeryOrder_ukcm so
        inner join penguin_tblOutlet_ukcm o on
            o.OutletId = so.OutletID
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'UK') dk
        inner join penguin_tblUser_ukcm u on
            u.UserId = so.ConsultantID
        inner join penguin_tblStationeryOrderDetails_ukcm sod on
            sod.OrderID = so.ID
        inner join penguin_tblStationeryType_ukcm st on
            st.ID = sod.StationeryType
        inner join penguin_tblReferenceValue_ukcm rst on
            rst.ID = st.DocumentType
        left join penguin_tblProduct_ukcm p on
            p.ProductId = sod.ProductID
    group by
        so.ID,
        so.OrderDate,
        u.Initial,
        o.AlphaCode,
        so.Comments,
        so.Email,
        dk.CountryKey,
        dk.CompanyKey,
        dk.PrefixKey

    if object_id('[db-au-cmdwh].dbo.StationeryOrder') is null
    begin

        create table [db-au-cmdwh].dbo.StationeryOrder
        (
            CountryKey varchar(2) not null,
            CompanyKey varchar(5) null,
            StationeryID int not null,
            DateCreated datetime null,
            ConsultantInitial nvarchar(20) null,
            AgencyCode nvarchar(20) null,
            OptionsBrochure int null,
            OptionsPricingGuide int null,
            TravelsureBrochure int null,
            TravelsurePricingGuide int null,
            EssentialsBrochure int null,
            EssentialsPricingGuide int null,
            SaveMoreBrochure int null,
            BusinessBrochure int null,
            STABrochure int null,
            STAPricingGuide int null,
            CorporateBrochure int null,
            CorporateQuotes int null,
            ComprehensiveBrochure int null,
            ComprehensivePricingGuide int null,
            BasicBrochure int null,
            BasicPricingGuide int null,
            ClaimForm int null,
            AssessmentForm int null,
            AssistanceCards int null,
            DeclarationPads  int null,
            PolicyWallet int null,
            SalesReturn int null,
            QuickTips int null,
            Comments nvarchar(max) null,
            Email nvarchar(200) null,
            StationeryKey varchar(41) null,
            OutletAlphaKey nvarchar(50) null
        )

        create clustered index idx_StationeryOrder_StationeryID on [db-au-cmdwh].dbo.StationeryOrder(StationeryID, CountryKey)
        create nonclustered index idx_StationeryOrder_CountryKey on [db-au-cmdwh].dbo.StationeryOrder(CountryKey)
        create nonclustered index idx_StationeryOrder_AgencyCode on [db-au-cmdwh].dbo.StationeryOrder(AgencyCode, CountryKey)
        create nonclustered index idx_StationeryOrder_DateCreated on [db-au-cmdwh].dbo.StationeryOrder(DateCreated, CountryKey)
        create nonclustered index idx_StationeryOrder_StationeryKey on [db-au-cmdwh].dbo.StationeryOrder(StationeryKey)
        create nonclustered index idx_StationeryOrder_OutletAlphaKey on [db-au-cmdwh].dbo.StationeryOrder(OutletAlphaKey)

    end
    else
    begin

        delete so
        from
            [db-au-cmdwh].dbo.StationeryOrder so
            inner join etl_StationeryOrder_penguin t on
                t.CountryKey = so.CountryKey and
                t.CompanyKey = so.CompanyKey and
                t.StationeryID = so.StationeryID

    end

    insert [db-au-cmdwh].dbo.StationeryOrder
    (
        CountryKey,
        CompanyKey,
        StationeryID,
        DateCreated,
        ConsultantInitial,
        AgencyCode,
        OptionsBrochure,
        OptionsPricingGuide,
        TravelsureBrochure,
        TravelsurePricingGuide,
        EssentialsBrochure,
        EssentialsPricingGuide,
        SaveMoreBrochure,
        BusinessBrochure,
        STABrochure,
        STAPricingGuide,
        CorporateBrochure,
        CorporateQuotes,
        ComprehensiveBrochure,
        ComprehensivePricingGuide,
        BasicBrochure,
        BasicPricingGuide,
        ClaimForm,
        AssessmentForm,
        AssistanceCards,
        DeclarationPads,
        PolicyWallet,
        SalesReturn,
        QuickTips,
        Comments,
        Email,
        StationeryKey,
        OutletAlphaKey
    )
    select
        CountryKey,
        CompanyKey,
        StationeryID,
        DateCreated,
        ConsultantInitial,
        AgencyCode,
        OptionsBrochure,
        OptionsPricingGuide,
        TravelsureBrochure,
        TravelsurePricingGuide,
        EssentialsBrochure,
        EssentialsPricingGuide,
        SaveMoreBrochure,
        BusinessBrochure,
        STABrochure,
        STAPricingGuide,
        CorporateBrochure,
        CorporateQuotes,
        ComprehensiveBrochure,
        ComprehensivePricingGuide,
        BasicBrochure,
        BasicPricingGuide,
        ClaimForm,
        AssessmentForm,
        AssistanceCards,
        DeclarationPads,
        PolicyWallet,
        SalesReturn,
        QuickTips,
        Comments,
        Email,
        StationeryKey,
        OutletAlphaKey
    from 
        etl_StationeryOrder_penguin

end
GO

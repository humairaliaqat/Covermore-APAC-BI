USE [db-au-star]
GO
/****** Object:  View [dbo].[v_ic_dimUnderwriter]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[v_ic_dimUnderwriter]
as
select
    'Great Lake Australia' Underwriter,
    'TIP-GLA' UnderwriterCode

union

select
    'Great Lake Australia' Underwriter,
    'GLA' UnderwriterCode

union

select
    'Zurich' Underwriter,
    'TIP-ZURICH' UnderwriterCode

union

select
    'Zurich' Underwriter,
    'ZURICH' UnderwriterCode

union

select
    'Vero Insurance' Underwriter,
    'VERO' UnderwriterCode

union

select
    'ERV Travel Insurance' Underwriter,
    'ETI' UnderwriterCode

union

select
    'ERV Travel Insurance' Underwriter,
    'ERV' UnderwriterCode

union

select
    'UK Ultimate' Underwriter,
    'UKU' UnderwriterCode

union

select
    'ETIQA Insurance' Underwriter,
    'ETIQA' UnderwriterCode

union

select
    'China Continent Property & Casual Insurance Company' Underwriter,
    'CCIC' UnderwriterCode

union

select
    'Asuransi Simasnet' Underwriter,
    'Simas Net' UnderwriterCode

union

select
    'AON' Underwriter,
    'AON' UnderwriterCode

union

select
    'Other' Underwriter,
    'OTHER' UnderwriterCode




GO

USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vDataMappingProductPlan]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   VIEW [dbo].[vDataMappingProductPlan] AS  
  
  
-- Created by RL  
-- 20170825  
-- For product data mapping  
-- Used by Product Mapping v15.xlsx  
-- 20171106  
-- Remove tblProductVersion.Status as this field is no longer used in prod  
-- The field above is replaced by tblProductVersion.VersionStatus  
-- 20180215  
-- Now showing all Product Plan mapping, including the ones which have already been mapped  
  
  
WITH cte AS (  
-- AU CM  
SELECT * FROM OPENQUERY([db-au-penguinsharp.aust.covermore.com.au],  
'SELECT d.CountryCode AS CountryKey  
, ''CM'' AS CompanyKey  
, d.CountryCode + ''-CM'' + CAST(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName AS ProductKey  
, prd.ProductCode  
, prd.ProductName  
, prd.ProductDisplayName  
, prd.DomainId  
, pl.PlanName  
, ''Insurance'' AS ProductType  
, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'', ''BUS'', ''CRP'') THEN ''Travel''   
 WHEN fin.Code = ''NTIP'' THEN ''Specialty''  
 ELSE NULL END AS ProductGroup  
, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'') THEN ''Leisure''  
 WHEN fin.Code = ''BUS'' THEN ''Business''  
 WHEN fin.Code = ''CRP'' THEN ''Corporate''  
 WHEN fin.Code = ''NTIP'' THEN ''Event''  
 ELSE NULL END AS PolicyType  
, fin.[Name] AS ProductClassification  
, CASE WHEN opa.Domestic = 1 THEN ''Domestic''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Domestic Inbound''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 0 THEN ''International''  
 ELSE NULL END AS PlanType  
, CASE WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D1'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D2'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''STC'' AND pl.PlanCode = ''STC'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CBP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMH'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMT'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMY'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''FCO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''FPP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''IAL'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''NCC'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''STA'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CIA'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''IAG'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''NZO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''PNO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''RDA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHID'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHII'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''VAR'' AND pl.PlanCode = ''VARD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCA'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRAD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRA'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRBD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRB'' THEN ''Car Hire''  
 WHEN fin.Code = ''NTIP'' THEN ''Cancellation''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Inbound''  
 WHEN plt.PlanType = ''Annual Multi Trip'' THEN ''AMT''   
 ELSE plt.PlanType END AS TripType  
, CASE WHEN fin.Code = ''NTIP'' THEN fin.Code  
 WHEN opa.Domestic = 1 THEN ''D'' + fin.Code  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''DI'' + fin.Code  
 WHEN opa.Domestic = 0 THEN ''I'' + fin.Code  
 ELSE ''Error'' END AS FinanceProductCode  
-- Additional fields  
, '''' AS FinanceProductCode_OLD  
, pl.PlanCode  
, '''' AS Updated  
, r.[Value] AS PurchasePathName  
, pl.DisplayName  
, fin.Code FinanceCodeOnPlan  
, finprd.Code AS FinanceCodeOnProduct  
, prd.ProductId, pl.UniquePlanID, pl.PlanId, opa.Domestic, opa.NonResident  
, ROW_NUMBER() OVER (PARTITION BY (d.CountryCode + ''-CM'' + cast(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName) ORDER BY pl.UniquePlanID DESC) AS LatestPlan  
FROM [AU_PenguinSharp_Active]..tblProduct prd WITH (NOLOCK)  
INNER JOIN [AU_PenguinSharp_Active]..tblDomain d WITH (NOLOCK) ON d.DomainId = prd.DomainId  
INNER JOIN [AU_PenguinSharp_Active]..tblProductVersion prdv WITH (NOLOCK) ON prdv.ProductID = prd.ProductId and prdv.VersionStatus = ''ACTIVE''  
INNER JOIN [AU_PenguinSharp_Active]..tblPlan pl WITH (NOLOCK) ON pl.ProductVersionID = prdv.ProductVersionID  
INNER JOIN [AU_PenguinSharp_Active]..tblPlanType plt WITH (NOLOCK) ON plt.PlanTypeId = pl.PlanTypeId  
INNER JOIN [AU_PenguinSharp_Active]..tblReferenceValue r WITH (NOLOCK) ON r.id = prd.PurchasePathID  
LEFT JOIN [AU_PenguinSharp_Active]..tblFinanceProduct fin WITH (NOLOCK) ON fin.FinanceProductId = pl.FinanceProductId AND fin.[Status] = ''ACTIVE''  
LEFT JOIN [AU_PenguinSharp_Active]..tblFinanceProduct finprd WITH (NOLOCK) ON finprd.FinanceProductId = prd.FinanceProductId AND finprd.[Status] = ''ACTIVE''  
OUTER APPLY (SELECT DISTINCT a.Domestic, a.NonResident  
 FROM [AU_PenguinSharp_Active]..tblPlanArea pa WITH (NOLOCK)  
 INNER JOIN [AU_PenguinSharp_Active]..tblArea a WITH (NOLOCK) ON a.AreaId = pa.AreaID  
 WHERE pa.PlanID = pl.PlanId) opa')  
  
-- AU TIP  
UNION  
SELECT * FROM OPENQUERY([db-au-penguinsharp.aust.covermore.com.au],  
'SELECT d.CountryCode AS CountryKey  
, ''TIP'' AS CompanyKey  
, d.CountryCode + ''-TIP'' + CAST(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName AS ProductKey  
, prd.ProductCode  
, prd.ProductName  
, prd.ProductDisplayName  
, prd.DomainId  
, pl.PlanName  
, ''Insurance'' AS ProductType  
, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'', ''BUS'', ''CRP'') THEN ''Travel''   
 WHEN fin.Code = ''NTIP'' THEN ''Specialty''  
 ELSE NULL END AS ProductGroup  
, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'') THEN ''Leisure''  
 WHEN fin.Code = ''BUS'' THEN ''Business''  
 WHEN fin.Code = ''CRP'' THEN ''Corporate''  
 WHEN fin.Code = ''NTIP'' THEN ''Event''  
 ELSE NULL END AS PolicyType  
, fin.[Name] AS ProductClassification  
, CASE WHEN opa.Domestic = 1 THEN ''Domestic''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Domestic Inbound''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 0 THEN ''International''  
 ELSE NULL END AS PlanType  
, CASE WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D1'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D2'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''STC'' AND pl.PlanCode = ''STC'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CBP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMH'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMT'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMY'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''FCO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''FPP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''IAL'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''NCC'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''STA'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CIA'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''IAG'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''NZO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''PNO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''RDA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHID'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHII'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''VAR'' AND pl.PlanCode = ''VARD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCA'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRAD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRA'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRBD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRB'' THEN ''Car Hire''  
 WHEN fin.Code = ''NTIP'' THEN ''Cancellation''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Inbound''  
 WHEN plt.PlanType = ''Annual Multi Trip'' THEN ''AMT''   
 ELSE plt.PlanType END AS TripType  
, CASE WHEN fin.Code = ''NTIP'' THEN fin.Code  
 WHEN opa.Domestic = 1 THEN ''D'' + fin.Code  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''DI'' + fin.Code  
 WHEN opa.Domestic = 0 THEN ''I'' + fin.Code  
 ELSE ''Error'' END AS FinanceProductCode  
-- Additional fields  
, '''' AS FinanceProductCode_OLD  
, pl.PlanCode  
, '''' AS Updated  
, r.[Value] AS PurchasePathName  
, pl.DisplayName  
, fin.Code FinanceCodeOnPlan  
, finprd.Code AS FinanceCodeOnProduct  
, prd.ProductId, pl.UniquePlanID, pl.PlanId, opa.Domestic, opa.NonResident  
, ROW_NUMBER() OVER (PARTITION BY (d.CountryCode + ''-CM'' + cast(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName) ORDER BY pl.UniquePlanID DESC) AS LatestPlan  
FROM [AU_TIP_PenguinSharp_Active]..tblProduct prd WITH (NOLOCK)  
INNER JOIN [AU_TIP_PenguinSharp_Active]..tblDomain d WITH (NOLOCK) ON d.DomainId = prd.DomainId  
INNER JOIN [AU_TIP_PenguinSharp_Active]..tblProductVersion prdv WITH (NOLOCK) ON prdv.ProductID = prd.ProductId and prdv.VersionStatus = ''ACTIVE''  
INNER JOIN [AU_TIP_PenguinSharp_Active]..tblPlan pl WITH (NOLOCK) ON pl.ProductVersionID = prdv.ProductVersionID  
INNER JOIN [AU_TIP_PenguinSharp_Active]..tblPlanType plt WITH (NOLOCK) ON plt.PlanTypeId = pl.PlanTypeId  
INNER JOIN [AU_TIP_PenguinSharp_Active]..tblReferenceValue r WITH (NOLOCK) ON r.id = prd.PurchasePathID  
LEFT JOIN [AU_TIP_PenguinSharp_Active]..tblFinanceProduct fin WITH (NOLOCK) ON fin.FinanceProductId = pl.FinanceProductId AND fin.[Status] = ''ACTIVE''  
LEFT JOIN [AU_TIP_PenguinSharp_Active]..tblFinanceProduct finprd WITH (NOLOCK) ON finprd.FinanceProductId = prd.FinanceProductId AND finprd.[Status] = ''ACTIVE''  
OUTER APPLY (SELECT DISTINCT a.Domestic, a.NonResident  
 FROM [AU_TIP_PenguinSharp_Active]..tblPlanArea pa WITH (NOLOCK)  
 INNER JOIN [AU_TIP_PenguinSharp_Active]..tblArea a WITH (NOLOCK) ON a.AreaId = pa.AreaID  
 WHERE pa.PlanID = pl.PlanId) opa')  
  
-- UK  
UNION  
SELECT * FROM OPENQUERY([SQLIREPRODAGL01],  
'SELECT d.CountryCode AS CountryKey  
, ''CM'' AS CompanyKey  
, d.CountryCode + ''-CM'' + CAST(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName AS ProductKey  
, prd.ProductCode  
, prd.ProductName  
, prd.ProductDisplayName  
, prd.DomainId  
, pl.PlanName  
, ''Insurance'' AS ProductType  
, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'', ''BUS'', ''CRP'') THEN ''Travel''   
 WHEN fin.Code = ''NTIP'' THEN ''Specialty''  
 ELSE NULL END AS ProductGroup  
, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'') THEN ''Leisure''  
 WHEN fin.Code = ''BUS'' THEN ''Business''  
 WHEN fin.Code = ''CRP'' THEN ''Corporate''  
 WHEN fin.Code = ''NTIP'' THEN ''Event''  
 ELSE NULL END AS PolicyType  
, fin.[Name] AS ProductClassification  
, CASE WHEN opa.Domestic = 1 THEN ''Domestic''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Domestic Inbound''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 0 THEN ''International''  
 ELSE NULL END AS PlanType  
, CASE WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D1'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D2'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''STC'' AND pl.PlanCode = ''STC'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CBP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMH'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMT'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMY'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''FCO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''FPP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''IAL'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''NCC'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''STA'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CIA'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''IAG'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''NZO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''PNO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''RDA'' THEN ''Cancellation''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHID'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHII'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3D'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3I'' THEN ''Car Hire''  
 WHEN prd.DomainId = 7 AND prd.ProductCode = ''VAR'' AND pl.PlanCode = ''VARD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCA'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRAD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRA'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRBD'' THEN ''Car Hire''  
 WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRB'' THEN ''Car Hire''  
 WHEN fin.Code = ''NTIP'' THEN ''Cancellation''  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Inbound''  
 WHEN plt.PlanType = ''Annual Multi Trip'' THEN ''AMT''   
 ELSE plt.PlanType END AS TripType  
, CASE WHEN fin.Code = ''NTIP'' THEN fin.Code  
 WHEN opa.Domestic = 1 THEN ''D'' + fin.Code  
 WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''DI'' + fin.Code  
 WHEN opa.Domestic = 0 THEN ''I'' + fin.Code  
 ELSE ''Error'' END AS FinanceProductCode  
-- Additional fields  
, '''' AS FinanceProductCode_OLD  
, pl.PlanCode  
, '''' AS Updated  
, r.[Value] AS PurchasePathName  
, pl.DisplayName  
, fin.Code FinanceCodeOnPlan  
, finprd.Code AS FinanceCodeOnProduct  
, prd.ProductId, pl.UniquePlanID, pl.PlanId, opa.Domestic, opa.NonResident  
, ROW_NUMBER() OVER (PARTITION BY (d.CountryCode + ''-CM'' + cast(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName) ORDER BY pl.UniquePlanID DESC) AS LatestPlan  
FROM [UK_PenguinSharp_Active]..tblProduct prd WITH (NOLOCK)  
INNER JOIN [UK_PenguinSharp_Active]..tblDomain d WITH (NOLOCK) ON d.DomainId = prd.DomainId  
INNER JOIN [UK_PenguinSharp_Active]..tblProductVersion prdv WITH (NOLOCK) ON prdv.ProductID = prd.ProductId and prdv.VersionStatus = ''ACTIVE''  
INNER JOIN [UK_PenguinSharp_Active]..tblPlan pl WITH (NOLOCK) ON pl.ProductVersionID = prdv.ProductVersionID  
INNER JOIN [UK_PenguinSharp_Active]..tblPlanType plt WITH (NOLOCK) ON plt.PlanTypeId = pl.PlanTypeId  
INNER JOIN [UK_PenguinSharp_Active]..tblReferenceValue r WITH (NOLOCK) ON r.id = prd.PurchasePathID  
LEFT JOIN [UK_PenguinSharp_Active]..tblFinanceProduct fin WITH (NOLOCK) ON fin.FinanceProductId = pl.FinanceProductId AND fin.[Status] = ''ACTIVE''  
LEFT JOIN [UK_PenguinSharp_Active]..tblFinanceProduct finprd WITH (NOLOCK) ON finprd.FinanceProductId = prd.FinanceProductId AND finprd.[Status] = ''ACTIVE''  
OUTER APPLY (SELECT DISTINCT a.Domestic, a.NonResident  
 FROM [UK_PenguinSharp_Active]..tblPlanArea pa WITH (NOLOCK)  
 INNER JOIN [UK_PenguinSharp_Active]..tblArea a WITH (NOLOCK) ON a.AreaId = pa.AreaID  
 WHERE pa.PlanID = pl.PlanId) opa')  
  
---- US  
--UNION  
--SELECT * FROM OPENQUERY([AZUSSQL02],  
--'SELECT d.CountryCode AS CountryKey  
--, ''CM'' AS CompanyKey  
--, d.CountryCode + ''-CM'' + CAST(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName AS ProductKey  
--, prd.ProductCode  
--, prd.ProductName  
--, prd.ProductDisplayName  
--, prd.DomainId  
--, pl.PlanName  
--, ''Insurance'' AS ProductType  
--, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'', ''BUS'', ''CRP'') THEN ''Travel''   
-- WHEN fin.Code = ''NTIP'' THEN ''Specialty''  
-- ELSE NULL END AS ProductGroup  
--, CASE WHEN fin.Code IN (''STD'', ''CMP'', ''VAL'') THEN ''Leisure''  
-- WHEN fin.Code = ''BUS'' THEN ''Business''  
-- WHEN fin.Code = ''CRP'' THEN ''Corporate''  
-- WHEN fin.Code = ''NTIP'' THEN ''Event''  
-- ELSE NULL END AS PolicyType  
--, fin.[Name] AS ProductClassification  
--, CASE WHEN opa.Domestic = 1 THEN ''Domestic''  
-- WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Domestic Inbound''  
-- WHEN opa.Domestic = 0 AND opa.NonResident = 0 THEN ''International''  
-- ELSE NULL END AS PlanType  
--, CASE WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D1'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''ANC'' AND pl.PlanCode = ''D2'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''STC'' AND pl.PlanCode = ''STC'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''CBP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMH'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMT'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''CMY'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''FCO'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''FPP'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''IAL'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''NCC'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''STA'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''CIA'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''CME'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''CMO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''IAG'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''NZO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''PNO'' AND pl.PlanCode = ''C'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''DA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''RDA'' THEN ''Cancellation''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2D'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA2'' AND pl.PlanCode = ''CH2I'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3D'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''AA3'' AND pl.PlanCode = ''CH3I'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHID'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''RCI'' AND pl.PlanCode = ''CHII'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3D'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''RV3'' AND pl.PlanCode = ''CHR3I'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 7 AND prd.ProductCode = ''VAR'' AND pl.PlanCode = ''VARD'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCA'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''ANR'' AND pl.PlanCode = ''ANRCD'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRAD'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRA'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRBD'' THEN ''Car Hire''  
-- WHEN prd.DomainId = 8 AND prd.ProductCode = ''VNR'' AND pl.PlanCode = ''VWRB'' THEN ''Car Hire''  
-- WHEN fin.Code = ''NTIP'' THEN ''Cancellation''  
-- WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''Inbound''  
-- WHEN plt.PlanType = ''Annual Multi Trip'' THEN ''AMT''   
-- ELSE plt.PlanType END AS TripType  
--, CASE WHEN fin.Code = ''NTIP'' THEN fin.Code  
-- WHEN opa.Domestic = 1 THEN ''D'' + fin.Code  
-- WHEN opa.Domestic = 0 AND opa.NonResident = 1 THEN ''DI'' + fin.Code  
-- WHEN opa.Domestic = 0 THEN ''I'' + fin.Code  
-- ELSE ''Error'' END AS FinanceProductCode  
---- Additional fields  
--, '''' AS FinanceProductCode_OLD  
--, pl.PlanCode  
--, '''' AS Updated  
--, r.[Value] AS PurchasePathName  
--, pl.DisplayName  
--, fin.Code FinanceCodeOnPlan  
--, finprd.Code AS FinanceCodeOnProduct  
--, prd.ProductId, pl.UniquePlanID, pl.PlanId, opa.Domestic, opa.NonResident  
--, ROW_NUMBER() OVER (PARTITION BY (d.CountryCode + ''-CM'' + cast(prd.DomainId AS VARCHAR(2)) + ''-'' + prd.ProductCode + ''-'' + prd.ProductName + ''-'' + prd.ProductDisplayName + ''-'' + pl.PlanName) ORDER BY pl.UniquePlanID DESC) AS LatestPlan  
--FROM [US_PenguinSharp_Active]..tblProduct prd WITH (NOLOCK)  
--INNER JOIN [US_PenguinSharp_Active]..tblDomain d WITH (NOLOCK) ON d.DomainId = prd.DomainId  
--INNER JOIN [US_PenguinSharp_Active]..tblProductVersion prdv WITH (NOLOCK) ON prdv.ProductID = prd.ProductId and prdv.VersionStatus = ''ACTIVE''  
--INNER JOIN [US_PenguinSharp_Active]..tblPlan pl WITH (NOLOCK) ON pl.ProductVersionID = prdv.ProductVersionID  
--INNER JOIN [US_PenguinSharp_Active]..tblPlanType plt WITH (NOLOCK) ON plt.PlanTypeId = pl.PlanTypeId  
--INNER JOIN [US_PenguinSharp_Active]..tblReferenceValue r WITH (NOLOCK) ON r.id = prd.PurchasePathID  
--LEFT JOIN [US_PenguinSharp_Active]..tblFinanceProduct fin WITH (NOLOCK) ON fin.FinanceProductId = pl.FinanceProductId AND fin.[Status] = ''ACTIVE''  
--LEFT JOIN [US_PenguinSharp_Active]..tblFinanceProduct finprd WITH (NOLOCK) ON finprd.FinanceProductId = prd.FinanceProductId AND finprd.[Status] = ''ACTIVE''  
--OUTER APPLY (SELECT DISTINCT a.Domestic, a.NonResident  
-- FROM [US_PenguinSharp_Active]..tblPlanArea pa WITH (NOLOCK)  
-- INNER JOIN [US_PenguinSharp_Active]..tblArea a WITH (NOLOCK) ON a.AreaId = pa.AreaID  
-- WHERE pa.PlanID = pl.PlanId) opa')  
)  
  
SELECT (cte.CountryKey COLLATE Latin1_General_CI_AS) AS CountryKey  
, (cte.CompanyKey COLLATE Latin1_General_CI_AS) AS CompanyKey  
, (cte.ProductKey COLLATE Latin1_General_CI_AS) AS ProductKey  
, (cte.ProductCode COLLATE Latin1_General_CI_AS) AS ProductCode  
, (cte.ProductName COLLATE Latin1_General_CI_AS) AS ProductName  
, (cte.ProductDisplayName COLLATE Latin1_General_CI_AS) AS ProductDisplayName  
, cte.DomainId  
, (cte.PlanName COLLATE Latin1_General_CI_AS) AS PlanName  
, (cte.ProductType COLLATE Latin1_General_CI_AS) AS ProductType  
, (cte.ProductGroup COLLATE Latin1_General_CI_AS) AS ProductGroup  
, (cte.PolicyType COLLATE Latin1_General_CI_AS) AS PolicyType  
, (cte.ProductClassification COLLATE Latin1_General_CI_AS) AS ProductClassification  
, (cte.PlanType COLLATE Latin1_General_CI_AS) AS PlanType  
, (cte.TripType COLLATE Latin1_General_CI_AS) AS TripType  
, (cte.FinanceProductCode COLLATE Latin1_General_CI_AS) AS FinanceProductCode  
, (cte.FinanceProductCode_OLD COLLATE Latin1_General_CI_AS) AS FinanceProductCode_OLD  
, (cte.PlanCode COLLATE Latin1_General_CI_AS) AS PlanCode  
, cte.Updated  
, (cte.PurchasePathName COLLATE Latin1_General_CI_AS) AS PurchasePathName  
, (cte.DisplayName COLLATE Latin1_General_CI_AS) AS DisplayName  
, (cte.FinanceCodeOnPlan COLLATE Latin1_General_CI_AS) AS FinanceCodeOnPlan  
, (cte.FinanceCodeOnProduct COLLATE Latin1_General_CI_AS) AS FinanceCodeOnProduct  
, cte.ProductId  
, cte.UniquePlanID  
, cte.PlanId  
, cte.Domestic  
, cte.NonResident  
, cte.LatestPlan  
, dimProduct1.IsMapped  
FROM cte  
OUTER APPLY (SELECT 1 AS IsMapped  
 FROM [db-au-star]..dimProduct WITH (NOLOCK)  
 WHERE ProductKey COLLATE Latin1_General_CI_AS = cte.ProductKey) dimProduct1  
WHERE cte.LatestPlan = 1  
  
  
GO

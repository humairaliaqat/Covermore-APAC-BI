USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vCBClientGroup]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vCBClientGroup] as
/*
    20160119, LS,   rebase vcbClientGroup to cbClient
	20170104, LT,   added HIF to Cover-More ClientGroup
	20181116, SD,   Moved (DTC) BENESTAR to Cover-More Client Group, and added COMMONWEALTH BANK,BANKWEST,COLES,DEPLOYMENT SERVICES,WESTPAC CV NZ to COver-More Client Group
	20190110, YY,	Add "No CONTRACT CLIENT" to Cover-Mover Client Group, add "BERKSHIRE HATHAWAY FULLERTON" 
						and "BERKSHIRE HATHAWAY LEISURE" and "BERKSHIRE HATHAWAY CORPORATE"to a new Client Group BERKSHIRE.
	20190201, SD,   Changed Cover-More client from (DTC) BENESTAR to BENESTAR
	20190614, SD	Changed the case statement to refer Client Codes, instead of Client names
*/
select
    CountryKey,
    ClientCode,
    ClientName,
    EvacDebtorCode,
    NonEvacDebtorCode,
    CurrencyCode,
    IsCovermoreClient,
    case
    --    when rtrim(ltrim(cc.ClientName)) in 
    --        (
    --            'AAA AUTO CLUBS', 
    --            'AUSTRALIA POST', 
    --            'CONCORDE SMART TRAVEL',
    --            'COVERMORE INSUR. SERVICES', 
    --            'COVERMORE -  NEW ZEALAND',
    --            'COVERMORE UK',
    --            'HARVEY WORLD TRAVEL', 
    --            'HELLOWORLD',
    --            'MEDIBANK', 
    --            'TRAVELSCENE', 
    --            'TRAVELSURE - NEW ZEALAND', 
    --            'TRAVELSURE -  NEW ZEALAND',
    --            'TRAVELSURE - AUST',
    --            'IAG NZ',
    --            'COVERMORE INDIA',
    --            'VIRGIN AIRLINES AU',
    --            'VIRGIN AIRLINES NZ',
    --            'SIMASNET INDONESIA',
				--'HIF',
				--'COMMONWEALTH BANK',
				--'BANKWEST',
				--'COLES',
				--'BENESTAR',
				--'DEPLOYMENT SERVICES',
				--'WESTPAC CV NZ',
				--'NO CONTRACT CLIENT'		
    --        ) then 'Cover-More'
		When
			cc.ClientCode in ('AA', 'AU', 'TT', 'CV','TZ', 'UK', 'HW', 'HO', 'ME','TI', 'TS', 'IN', 'CM', 'VA', 'VN', 'SN', 'HI', 'CB', 'BW', 'CZ', 'DT', 'DS', 'WZ', 'WB')
			then 'Cover-More'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'CHUBB INSURANCE', 
        --        'CHUBB  INSURANCE',
        --        'AMEX NAC',
        --        'CHUBB  INSURANCE (LEGACY)',
        --        'CHUBB FULLERTON HEALTH  (ACE ISN)',
        --        'CHUBB INSURANCE (ACE)',
        --        'UNVERIFIED ACE'
        --    ) then 'Chubb'
		when
			cc.ClientCode in ('CH', 'AE', 'AC','IS','UV')
			then 'Chubb'
        --when rtrim(ltrim(cc.ClientName)) in ('ACE INSURANCE', 'ACE NEW ZEALAND', 'ACE CSN') then 'ACE'
		when cc.ClientCode in ('AI') then 'ACE'
        --when rtrim(ltrim(cc.ClientName)) in ('CUST CARE CORP PROTECTION') then 'CCCPP'
		when cc.ClientCode in ('CP') then 'CCCPP'
        when rtrim(ltrim(cc.ClientName)) like '%ZURICH%' then 'Zurich'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'BUPA - TRAVEL INSURANCE', 
        --        'BUPA INBOUND', 
        --        'BUPA ULTIMATE HEALTH'
        --    ) then 'BUPA'
		when cc.ClientCode in ('BP', 'BR','BU','YA') then 'BUPA'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'MALAYSIA AIR - AUSTRALIA',
        --        'MALAYSIA AIR - MALAYSIA',
        --        'MALAYSIA AIR - NZ',
        --        'MALAYSIA AIR - SINGAPORE',
        --        'MALAYSIA AIR - STAFF',
        --        'MALAYSIA INTERNATIONAL',
        --        'MALAYSIA AIR - INDIA',
        --        'MALAYSIA ENRICH',
        --        'MALAYSIA AIR - MASWINGS',
        --        'MALAYSIA AIRLINES - INDONESIA'
        --    ) then 'MALAYSIA AIR'
		when cc.ClientCode in ('MA','MM','MN','MS','MX','MI','MR','MW','MD','MT') then 'MALAYSIA AIR'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'AIR NEW ZEALAND - AUS',
        --        'AIR NEW ZEALAND - NZ',
        --        'AIR NEW ZEALAND - UK'
        --    ) then 'AIR NEW ZEALAND'
		when cc.ClientCode in ('AT','AW','AK') then 'AIR NEW ZEALAND'
        when rtrim(ltrim(cc.ClientName)) in 
            (
                'ISN CSN'
            ) then 'Corporate Service Network'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'INTL ASSISTANCE GROUP'
        --    ) then 'IAG'
		when cc.ClientCode in ('IA') then 'IAG'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'ADAC',
        --        'ALMEDA',
        --        'ASSISTANCE ON LINE (AOL)',
        --        'ARAG',
        --        'AXA',
        --        'CEGA',
        --        'CLUB ASISTENCIA',
        --        'EUROP ASSISTANCE',
        --        'FALCK TRAVEL CARE',
        --        'JAPAN EMERGENCY ASSIST',
        --        'MUTUAIDE',
        --        'ROWLAND ASSIST',
        --        'SOS INT DENMARK'
        --    ) then 'Inbound'
		when cc.ClientCode in ('AD','AL','AO','AR','AX','CG','YC','CL','EA','FA','JA','MU','RA','SO') then 'Inbound'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'CARD SERVICES - CITIBANK',
        --        'CITIBANK',
        --        'COLES PLATINUM MCARD',
        --        'WESTPAC NZ',
        --        'CONCIERGE'
        --    ) then 'Concierge'
		when cc.ClientCode in ('CA','CI','CZ','WE','TW','GE') then 'Concierge'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'IAL'
        --    ) then 'IAL'
		when cc.ClientCode in ('IL') then 'IAL'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'BEAZLEY LEISURE',
        --        'BEAZLEY CORPORATE',
        --        'BEAZLEY SAVANNAH',
        --        'BERKSHIRE HATHAWAY'
        --    ) then 'BEAZLEY'
		when cc.ClientCode in ('BS','BZ') then 'BEAZLEY'
		 --when rtrim(ltrim(cc.ClientName)) in		-- YY 20190110 Add new client codes and client group BERKSHIRE
   --         (
   --             'BERKSHIRE HATHAWAY FULLERTON',
   --             'BERKSHIRE HATHAWAY LEISURE',
   --             'BERKSHIRE HATHAWAY CORPORATE'
   --           ) then 'BERKSHIRE'
		when cc.ClientCode in ('BF','BH','BC') then 'BERKSHIRE'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'ORBIT PROTECT'
        --    ) then 'BENESTAR'
		when cc.ClientCode in ('OP') then 'BENESTAR'
        --when rtrim(ltrim(cc.ClientName)) in 
        --    (
        --        'GO INSURANCE',
        --        'PEN UNDERWRITING',
        --        'PREMIUM EXECUTIVE  (CVCA)',
        --        'SOLUTION UNDERWRITING'
        --    ) then 'GO INSURANCE'
		when cc.ClientCode in ('GO','PN','PE','SL') then 'GO INSURANCE'
        else 'Other'
    end ClientGroup
from
    cbClient cc



GO

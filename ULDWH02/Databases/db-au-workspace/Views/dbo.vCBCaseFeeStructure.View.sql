USE [db-au-workspace]
GO
/****** Object:  View [dbo].[vCBCaseFeeStructure]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE view [dbo].[vCBCaseFeeStructure] as 

--/*
--    20140826, LS,   F21174, change formula
--    20140912, LS,   F21174, add FeeMethod
--    20140923, LS,   F21174, conditional Incident Fee (invalid cases should be 0)
--    20150417, LS,   F24024, remove incident fee
--    20150720, LS,   T16930, Carebase 4.6, change of source data
--    20151215, LS,   CurrencyCode
--    20160119, LS,   rebase vcbClientGroup to cbClient
--	  20161013,	PZ,   TFS27450, Added new casefee calculation based on casetype in cbcase table instead of derivedcasetype
--    20170223, LL,   new case type fees
--	  20170803, SD,	  Added logic to calculate Casefee for new casetype 'PAYMENT ONLY'
--	  20180305, SD,   Changed join from program Code to Program Description, as new file does not provide Program code, INC0059024
--	  20180423, SD,   Changed CaseFee logic to compare correct Case Type
--    20180502, SD,   Changed Derived Case type and Case fee logic to incorporate new mapping for client codes AC and EA
--	  20180522, SD,   Changed Derived Case Type and Case Fee logic to incorporate new mapping for AE,BE,CH,IS,OP,PE,AV,BH,VH,MC,AD,AM,AR,BG,BS,BZ,PN,SL,CG,CL,CM,CP,CR,FA,HT,IA,IZ,NZ,RA,RC,SO,WA and ZU
--	  20180530, SD,   Changed dreived case logic for AE,BE,CH,IS,OP,PE,AV,BH,VH,MC,AD,AM,AR,BG,BS,BZ,PN,SL,CG,CL,CM,CP,CR,FA,HT,IA,IZ,NZ,RA,RC,SO,WA and ZU
--	  20180531, SD,	  AC and AE Technical cases will always be mapped to Simple
--	  20180601, SD,   Some more changes applied to Derived Case type logic
--	  20180621, SD,	  Added mapping for internal clients
--	  20181120, SD,	  Mapped GP Consult to Travel GP, and added GO client into the mapping
--*/


select 
    cc.CaseKey,
	dc.DebtorCode as DebtorsCode,
    Case
		When cc.ClientCode In ('DT', 'DS', 'WE', 'GE') Then 'Simple'
		When cc.CaseType = 'Travel GP' Then 'Travel GP'
		When cc.CaseType = 'Evacuation' Then 'Evacuation'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Inpatient' Then 'Complex'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Mortal Remains' Then 'Complex'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient' Then 'Simple'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient Multiple' Then 'Simple'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType in ('MEDIUM','Medium') Then 'Simple'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType in ('UW Request') Then 'Simple'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 Then 'Complex'
		when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <=5 Then 'Simple'
		When cc.CaseType = 'No Charge' Then 'NA'
		When cc.CaseType = 'HTH LOG only' Then 'NA'
		When cc.CaseType = '13 SICK' Then 'NA'
		When cc.CaseType = 'ARAG and HTH Medium' Then 'Medium'
		When cc.CaseType = 'UW Request' Then 'NA'
		When cc.CaseType = 'CN Mortal Remain' Then 'NA'
		When cc.CaseType = 'Outpatient Multiple' Then 'Multiple Outpatient'
		When cc.CaseType = 'CN Evacuation AA' Then 'NA'
		When cc.CaseType = 'TRAVEL BOOKING (ORBIT ONLY)' Then 'Travel Booking'
		When cc.CaseType = 'Review' Then 'NA'
		When cc.CaseType = 'Simple Case,Very Simple' Then 'Simple'
		When cc.CaseType = 'PAYMENT ONLY' Then 'PAYMENT ONLY'
		When cc.CaseType = 'Repatriation' Then 'Evacuation'
		When cc.CaseType = 'Simple Case' Then 'Simple'
		When cc.CaseType = 'GP Consult' Then 'Travel GP'
		When cc.CaseType = 'Invalid Case' Then 'NA'
		When cc.CaseType = 'M/C Involvement' Then 'NA'
		When cc.CaseType = 'Quotation' Then 'Quotation'
		When cc.CaseType = 'Evacuation AA' Then 'Evacuation'
		When cc.CaseType = 'Mortal Remans' Then 'Mortal Remains'
		When cc.CaseType = 'Mortal Remains' Then 'Mortal Remains'
		When cc.CaseType = 'Death of Cust' Then 'NA'
		When cc.CaseType = 'Evacuation GA' Then 'Evacuation'
		When cc.CaseType = 'Complex Case,Major Distaster' Then 'Complex'
		When cc.CaseType = 'Medium' Then 'Medium'
		When cc.CaseType = 'ARAG Medium' Then 'Medium'
		When cc.CaseType = 'Complex Case' Then 'Complex'
		when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 And cc.ProtocolCode = 'M' Then 'Inpatient'
		when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'M' Then 'Outpatient'
		when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'T' Then 'Simple'
		when cc.ClientCode in ('GO','AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 And cc.ProtocolCode = 'M' Then 'Complex'
		when cc.ClientCode in ('GO','AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'M' Then 'Simple'
		when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.CaseType not in ('Inpatient', 'Outpatient') and cc.CaseType = 'Complex' And cc.ProtocolCode = 'M' Then 'Inpatient'
		when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.CaseType not in ('Inpatient', 'Outpatient') and cc.CaseType = 'Simple' And cc.ProtocolCode = 'M' Then 'Outpatient'
		when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.ProtocolCode = 'T' Then 'Simple'
		when cc.ClientCode in ('GO','AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseFee = '' or cc.CaseFee is null or cc.CaseFee = 0) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 and cc.CaseType not in ('Simple', 'Complex') And cc.ProtocolCode = 'M' Then 'Complex'
		when cc.ClientCode in ('GO','AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseFee = '' or cc.CaseFee is null or cc.CaseFee = 0) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 and cc.CaseType not in ('Simple', 'Complex') And cc.ProtocolCode = 'M' Then 'Simple'
		When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) > 5 And cc.ProtocolCode <> 'M' Then 'Complex'
		When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) > 5 And cc.ProtocolCode = 'M' Then 'Inpatient'
		When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) <= 5 And cc.ProtocolCode <> 'M' Then 'Simple'
		When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) <= 5 And cc.ProtocolCode = 'M' Then 'Outpatient'
		When cc.CaseType = 'Inpatient' Then 'Inpatient'
		When cc.CaseType = 'Outpatient' Then 'Outpatient'
		When cc.CaseType = 'Simple' Then 'Simple'
		When cc.CaseType = 'Complex' Then 'Complex'
		Else cc.CaseType
	End DerivedCaseType,
    FeeMethod,
    case
        when isnull(cc.CaseFee, 0) <> 0 then cc.CaseFee
        else isnull(casefee.CaseFee, 0) 
    end as CaseFee,
    case
        when isnull(cc.CaseFee, 0) <> 0 then 0
        else isnull(casefee.GST / 100.0, 0) * isnull(casefee.CaseFee, 0)
    end as GST,
    case
        when isnull(cc.CaseFee, 0) <> 0 then cc.CaseFee
        else isnull(casefee.CaseFee, 0) + isnull(casefee.GST / 100.0, 0) * isnull(casefee.CaseFee, 0)
    end as TotalCaseFee,
	case
        when isnull(cc.CaseFee, 0) <> 0 then cc.CaseFee
        else isnull(cf_new.CaseFee, 0) 
    end as CaseFee_CaseType,
    case
        when isnull(cc.CaseFee, 0) <> 0 then 0
        else isnull(cfs.GST / 100.0, 0) * isnull(cf_new.CaseFee, 0)
    end as GST_CaseType,
    case
        when isnull(cc.CaseFee, 0) <> 0 then cc.CaseFee
        else isnull(cf_new.CaseFee, 0) + isnull(cfs.GST / 100.0, 0) * isnull(cf_new.CaseFee, 0)
    end as TotalCaseFee_CaseType,
    cg.CurrencyCode
from
   [db-au-cmdwh].dbo.cbCase cc
    cross apply
    (
        select top 1
            cg.ClientGroup,
            cg.EvacDebtorCode,
            cg.NonEvacDebtorCode,
            cg.CurrencyCode
        from
              [db-au-cmdwh].dbo. vcbClientGroup cg
        where
            cg.ClientCode = cc.ClientCode
    ) cg
    cross apply
    (
        /* pivot looks nicer but need 2 statements just to get Other count */
        select
            count(distinct case when NoteCode = 'EV' then NoteKey else null end) EV,
            count(distinct case when NoteCode = 'FN' then NoteKey else null end) FN,
            count(distinct case when NoteCode = 'QU' then NoteKey else null end) QU,
            count(distinct case when NoteCode = 'UC' then NoteKey else null end) UC,
            count(distinct case when NoteCode = 'UD' then NoteKey else null end) UD,
            count(distinct case when NoteCode = 'BR' then NoteKey else null end) BR,
            count(distinct case when NoteCode = 'EM' then NoteKey else null end) EM,
            count(distinct case when NoteCode = 'LM' then NoteKey else null end) LM,
            count(distinct case when NoteCode = 'MC' then NoteKey else null end) MC,
            count(distinct case when NoteCode not in ('EV', 'FN', 'QU', 'UC', 'UD', 'BR', 'EM', 'LM', 'MC') then NoteKey else null end) Other
        from
               [db-au-cmdwh].dbo.cbNote cn
        where
            cn.CaseKey = cc.CaseKey
    ) cn
    cross apply
    (
        select
            count(ClientReportKey) CR
        from
               [db-au-cmdwh].dbo.cbClientReport cr
        where
            cr.CaseKey = cc.CaseKey
    ) cr
    outer apply
    (
        select top 1 
            SimpleMedicalCaseFee,
            SimpleTechnicalCaseFee,
            MediumMedicalCaseFee,
            MediumTechnicalCaseFee,
            ComplexMedicalCaseFee,
            ComplexTechnicalCaseFee,
            EvacuationCaseFee,
			RetroFee,--test
            QuotationMedicalCaseFee,
			OutpatientMultiple,
            QuotationTechnicalCaseFee,
            InpatientCaseFee,
            MortalRemainsCaseFee,
            OutpatientCaseFee,
            TravelGPCaseFee,
            TechnicalCaseFee,
			PaymentOnlyMedicalCaseFee,
			PaymentOnlyTechnicalCaseFee,
            GST
        from
            (
                select 
                    ClientCode,
                    Protocol,
					CaseType,
                    sum(
                        case
                            when CaseType = 'Simple' and Protocol = 'Medical' then Fee
                            else 0
                        end 
                    ) SimpleMedicalCaseFee,
                    sum(
                        case
                            when CaseType = 'Simple' and Protocol = 'Technical' then Fee
                            else 0
                        end 
                    ) SimpleTechnicalCaseFee,
					--test
					             sum(
                        case
                            when CaseType = 'Outpatient Multiple' and Protocol = 'Medical' then Fee
                            else 0
                        end 
                    ) OutpatientMultiple,
					--test
					--test
					             sum(
                        case
                            when CaseType = 'RETRO CLAIMS SUPPORT (CHUBB)' and Protocol = 'Medical' then Fee
                            else 0
                        end 
                    ) RetroFee,
					--test
                    sum(
                        case
                            when CaseType = 'Medium' and Protocol = 'Medical' then Fee
                            else 0
                        end 
                    ) MediumMedicalCaseFee,
                    sum(
                        case
                            when CaseType = 'Medium' and Protocol = 'Technical' then Fee
                            else 0
                        end 
                    ) MediumTechnicalCaseFee,
                    sum(
                        case
                            when CaseType = 'Complex' and Protocol = 'Medical' then Fee
                            else 0
                        end 
                    ) ComplexMedicalCaseFee,
                    sum(
                        case
                            when CaseType = 'Complex' and Protocol = 'Technical' then Fee
                            else 0
                        end 
                    ) ComplexTechnicalCaseFee,
                    sum(
                        case
                            when CaseType = 'Evacuation' then Fee
                            else 0
                        end 
                    ) EvacuationCaseFee,
                    sum(
                        case
                            when CaseType = 'Quotation' and Protocol = 'Medical' then Fee
                            else 0
                        end 
                    ) QuotationMedicalCaseFee,
                    sum(
                        case
                            when CaseType = 'Quotation' and Protocol = 'Technical' then Fee
                            else 0
                        end 
                    ) QuotationTechnicalCaseFee,
                    sum(
                        case
                            when CaseType = 'Inpatient' then Fee
                            else 0
                        end 
                    ) InpatientCaseFee,
                    sum(
                        case
                            when CaseType = 'Mortal Remains' then Fee
                            else 0
                        end 
                    ) MortalRemainsCaseFee,
                    sum(
                        case
                            when CaseType = 'Outpatient' then Fee
                            else 0
                        end 
                    ) OutpatientCaseFee,
                    sum(
                        case
                            when CaseType = 'Travel GP' then Fee
                            else 0
                        end 
                    ) TravelGPCaseFee,
                    sum(
                        case
                            when CaseType = 'Technical' then Fee
                            else 0
                        end 
                    ) TechnicalCaseFee,
                    sum(
                        case
                            when CaseType = 'PAYMENT ONLY' and Protocol = 'Medical' then Fee
                            else 0
                        end 
                    ) PaymentOnlyMedicalCaseFee,
                    sum(
                        case
                            when CaseType = 'PAYMENT ONLY' and Protocol = 'Technical' then Fee
                            else 0
                        end 
                    ) PaymentOnlyTechnicalCaseFee,
                    10 GST
                from
                       [db-au-cmdwh].dbo.cbCaseTypeFee cf
                group by
                    ClientCode,
                    Protocol,
					CaseType
            ) t
        where
            t.ClientCode = cc.ClientCode and
            t.Protocol = cc.Protocol and
			t.CaseType = cc.CaseType
    ) cfs

    outer apply
    (
        select
            case
                when datediff(day, cc.OpenDate, isnull(cc.FirstCloseDate, getdate())) > 30 then 'Complex'
                when cc.CaseType in ('No Charge', 'Invalid Case') then cc.CaseType
                when cg.ClientGroup = 'IAG' then cc.CaseType
                when cg.ClientGroup = 'Inbound' then cc.CaseType
                when cc.ClientCode in ('CB', 'WP', 'BO', 'SG', 'SA', 'BW') then cc.CaseType
                when cn.EV >= 1 then 'Evacuation'
                when cg.ClientGroup = 'ACE' and cn.FN >= 1 then 'Evacuation'
                when (cn.QU + cn.UC + cn.UD + cn.BR + cn.EM + cn.FN + cn.LM + cn.MC) >= 1 then 'Complex'
                when cr.CR > 2 then 'Complex'
                when cn.Other >= 12 then 'Complex'
                else 'Simple'
            end DerivedCaseType,
            case
                when datediff(day, cc.OpenDate, isnull(cc.FirstCloseDate, getdate())) > 30 then 'Age'
                when cc.CaseType in ('No Charge', 'Invalid Case') then 'Closed Type'
                when cg.ClientGroup = 'IAG' then 'Closed Type'
                when cg.ClientGroup = 'Inbound' then 'Closed Type'
                when cc.ClientCode in ('CB', 'WP', 'BO', 'SG', 'SA', 'BW') then 'Closed Type'
                when cn.EV >= 1 then 'Case Note'
                when cg.ClientGroup = 'ACE' and cn.FN >= 1 then 'Case Note'
                when (cn.QU + cn.UC + cn.UD + cn.BR + cn.EM + cn.FN + cn.LM + cn.MC) >= 1 then 'Case Note'
                when cr.CR > 2 then 'Case Note'
                when cn.Other >= 12 then 'Case Note'
                else 'Case Note'
            end FeeMethod
    ) ct
    outer apply
    (
        select
            case
                when cc.CaseType = 'Quotation' and cc.ProtocolCode = 'M' then cfs.QuotationMedicalCaseFee
                when cc.CaseType = 'Quotation' and cc.ProtocolCode = 'T' then cfs.QuotationTechnicalCaseFee
				when cc.CaseType = 'PAYMENT ONLY' and cc.ProtocolCode = 'M' then cfs.PaymentOnlyMedicalCaseFee
                when cc.CaseType = 'PAYMENT ONLY' and cc.ProtocolCode = 'T' then cfs.PaymentOnlyTechnicalCaseFee
                when cc.CaseType = 'Inpatient' then cfs.InpatientCaseFee
                when cc.CaseType = 'Mortal Remains' then cfs.MortalRemainsCaseFee
                when cc.CaseType = 'Outpatient' then cfs.OutpatientCaseFee
                when cc.CaseType = 'Travel GP' then cfs.TravelGPCaseFee
                when ct.DerivedCaseType in ('No Charge', 'Invalid Case') then 0
                when ct.DerivedCaseType = 'Evacuation' then cfs.EvacuationCaseFee
                when ct.DerivedCaseType = 'Complex' then
                    case
                        when cc.ProtocolCode = 'T' then cfs.ComplexTechnicalCaseFee
                        else cfs.ComplexMedicalCaseFee
                    end
                when ct.DerivedCaseType = 'Medium' then
                    case
                        when cc.ProtocolCode = 'T' then cfs.MediumTechnicalCaseFee
                        else cfs.MediumMedicalCaseFee
                    end
                when ct.DerivedCaseType = 'Simple' then
                    case
                        when cc.ProtocolCode = 'T' then cfs.SimpleTechnicalCaseFee
                        else cfs.SimpleMedicalCaseFee
                    end
                else 0
            end CaseFee
    ) cf
	/*
	outer apply
    (
        select top 1 
            CaseFee,
            GST
        from
            (
                select 
                    ClientCode,
                    Protocol,
					CaseType,
                    sum(Fee) CaseFee,
                    sum(Tax) GST
                from
                       [db-au-cmdwh].dbo.cbCaseTypeFee cf
                group by
                    ClientCode,
                    Protocol,
					CaseType
            ) t
        where
            t.ClientCode = cc.ClientCode and
            t.Protocol = cc.Protocol and
			t.CaseType = Case
							When cc.ClientCode In ('DT', 'DS', 'WE', 'GE') Then 'Simple'
							When cc.CaseType = 'Travel GP' Then 'Travel GP'
							When cc.CaseType = 'Evacuation' Then 'Evacuation'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Inpatient' Then 'Complex'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Mortal Remains' Then 'Complex'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient' Then 'Simple'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient Multiple' Then 'Simple'
						--TEST---	
						when cc.ClientCode In ('VH','OU','OP','CH','BT','MC','AX','VV') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient Multiple' Then 'Outpatient Multiple '
						--TEST---	
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType in ('MEDIUM','Medium') Then 'Simple'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType in ('UW Request') Then 'Simple'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 Then 'Complex'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <=5 Then 'Simple'
							When cc.CaseType = 'No Charge' Then 'NA'
							When cc.CaseType = 'HTH LOG only' Then 'NA'
							When cc.CaseType = '13 SICK' Then 'NA'
							When cc.CaseType = 'ARAG and HTH Medium' Then 'Medium'
							When cc.CaseType = 'UW Request' Then 'NA'
							When cc.CaseType = 'CN Mortal Remain' Then 'NA'
							When cc.CaseType = 'Outpatient Multiple' Then 'Multiple Outpatient'
							When cc.CaseType = 'CN Evacuation AA' Then 'NA'
							When cc.CaseType = 'TRAVEL BOOKING (ORBIT ONLY)' Then 'Travel Booking'
							When cc.CaseType = 'Review' Then 'NA'
							When cc.CaseType = 'Simple Case,Very Simple' Then 'Simple'
							When cc.CaseType = 'PAYMENT ONLY' Then 'PAYMENT ONLY'
							When cc.CaseType = 'Repatriation' Then 'Evacuation'
							When cc.CaseType = 'Simple Case' Then 'Simple'
							When cc.CaseType = 'GP Consult' Then 'GP Travel'
							When cc.CaseType = 'Invalid Case' Then 'NA'
							When cc.CaseType = 'M/C Involvement' Then 'NA'
							When cc.CaseType = 'Quotation' Then 'Quotation'
							When cc.CaseType = 'Evacuation AA' Then 'Evacuation'
							When cc.CaseType = 'Mortal Remans' Then 'Mortal Remains'
							When cc.CaseType = 'Mortal Remains' Then 'Mortal Remains'
							When cc.CaseType = 'Death of Cust' Then 'NA'
							When cc.CaseType = 'Evacuation GA' Then 'Evacuation'
							When cc.CaseType = 'Complex Case,Major Distaster' Then 'Complex'
							When cc.CaseType = 'Medium' Then 'Medium'
							When cc.CaseType = 'ARAG Medium' Then 'Medium'
							When cc.CaseType = 'Complex Case' Then 'Complex'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 And cc.ProtocolCode = 'M' Then 'Inpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'M' Then 'Outpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'T' Then 'Simple'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 And cc.ProtocolCode = 'M' Then 'Complex'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'M' Then 'Simple'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.CaseType not in ('Inpatient', 'Outpatient') and cc.CaseType = 'Complex' And cc.ProtocolCode = 'M' Then 'Inpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.CaseType not in ('Inpatient', 'Outpatient') and cc.CaseType = 'Simple' And cc.ProtocolCode = 'M' Then 'Outpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.ProtocolCode = 'T' Then 'Simple'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseFee = '' or cc.CaseFee is null or cc.CaseFee = 0) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 and cc.CaseType not in ('Simple', 'Complex') And cc.ProtocolCode = 'M' Then 'Complex'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseFee = '' or cc.CaseFee is null or cc.CaseFee = 0) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 and cc.CaseType not in ('Simple', 'Complex') And cc.ProtocolCode = 'M' Then 'Simple'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) > 5 And cc.ProtocolCode <> 'M' Then 'Complex'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) > 5 And cc.ProtocolCode = 'M' Then 'Inpatient'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) <= 5 And cc.ProtocolCode <> 'M' Then 'Simple'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) <= 5 And cc.ProtocolCode = 'M' Then 'Outpatient'
							When cc.CaseType = 'Inpatient' Then 'Inpatient'
							When cc.CaseType = 'Outpatient' Then 'Outpatient'
							When cc.CaseType = 'Simple' Then 'Simple'
							When cc.CaseType = 'Complex' Then 'Complex'
							Else cc.CaseType
						End
    ) casefee*/
    outer apply
    ( -- cf_new
        select
            case
                when cc.CaseType = 'Quotation' and cc.ProtocolCode = 'M' then cfs.QuotationMedicalCaseFee
                when cc.CaseType = 'Quotation' and cc.ProtocolCode = 'T' then cfs.QuotationTechnicalCaseFee
				when cc.CaseType = 'PAYMENT ONLY' and cc.ProtocolCode = 'M' then cfs.PaymentOnlyMedicalCaseFee
                when cc.CaseType = 'PAYMENT ONLY' and cc.ProtocolCode = 'T' then cfs.PaymentOnlyTechnicalCaseFee
                when cc.CaseType = 'Inpatient' then cfs.InpatientCaseFee
                when cc.CaseType = 'Mortal Remains' then cfs.MortalRemainsCaseFee
                when cc.CaseType = 'Outpatient' then cfs.OutpatientCaseFee
                when cc.CaseType = 'Travel GP' then cfs.TravelGPCaseFee
                when cc.CaseType in ('No Charge', 'Invalid Case') then 0
                when cc.CaseType = 'Evacuation' then cfs.EvacuationCaseFee
			--	when cc.CaseType = 'Outpatient Multiple' and cc.Protocol = 'Medical' then casefee.CaseFee

			---TEST
				when cc.ClientCode In ('VH','OU','OP','CH','BT','MC','AX','VV') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and
			cc.CaseType = 'Outpatient Multiple' Then cfs.OutpatientMultiple
			when cc.ClientCode In ('CH') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and
			cc.CaseType = 'RETRO CLAIMS SUPPORT (CHUBB)' Then cfs.RetroFee
			--TEST---	

                when cc.CaseType = 'Complex' then
                    case
                        when cc.ProtocolCode = 'T' then cfs.ComplexTechnicalCaseFee
                        else cfs.ComplexMedicalCaseFee
                    end
                when cc.CaseType = 'Medium' then
                    case
                        when cc.ProtocolCode = 'T' then cfs.MediumTechnicalCaseFee
                        else cfs.MediumMedicalCaseFee
                    end
                when cc.CaseType = 'Simple' then
                    case
                        when cc.ProtocolCode = 'T' then cfs.SimpleTechnicalCaseFee
                        else cfs.SimpleMedicalCaseFee
                    end
                else 0
            end CaseFee
    ) cf_new
    outer apply
    (
        select top 1
            --20161005, revert to excel file, chase assistance team for implementation on source system
            --case
            --    when ct.DerivedCaseType = 'Evacuation' then cg.EvacDebtorCode
            --    else cg.NonEvacDebtorCode
            --end DebtorCode
            cf.DebtorsCode DebtorCode
        from
               [db-au-cmdwh].dbo.usrCBCaseFee cf
        where
            cf.ClientCode = cc.ClientCode and
            cf.ProgramCode = cc.ProgramCode
    ) dc
	
	outer apply
    (
        select top 1 
            CaseFee,
            GST
        from
            (
                select 
                    ClientCode,
                    Protocol,
					CaseType,
                    sum(Fee) CaseFee,
                    sum(Tax) GST
                from
                       [db-au-cmdwh].dbo.cbCaseTypeFee cf
                group by
                    ClientCode,
                    Protocol,
					CaseType
            ) t
        where
            t.ClientCode = cc.ClientCode and
            t.Protocol = cc.Protocol and
			t.CaseType = Case
							When cc.ClientCode In ('DT', 'DS', 'WE', 'GE') Then 'Simple'
							When cc.CaseType = 'Travel GP' Then 'Travel GP'
							When cc.CaseType = 'Evacuation' Then 'Evacuation'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Inpatient' Then 'Complex'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Mortal Remains' Then 'Complex'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient' Then 'Simple'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient Multiple' Then 'Simple'
						--TEST---	
					--	when cc.ClientCode In ('VH','OU','OP','CH','BT','MC','AX','VV') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient Multiple' Then 'Multiple Outpatient'
						--TEST---	
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType in ('MEDIUM','Medium') Then 'Simple'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType in ('UW Request') Then 'Simple'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 Then 'Complex'
							when cc.ClientCode In ('CV','ME','AU','HO','VA','TT','AW','IL','TZ','UK','IN','AT','TI') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <=5 Then 'Simple'
							When cc.CaseType = 'No Charge' Then 'NA'
							When cc.CaseType = 'HTH LOG only' Then 'NA'
							When cc.CaseType = '13 SICK' Then 'NA'
							When cc.CaseType = 'ARAG and HTH Medium' Then 'Medium'
							When cc.CaseType = 'UW Request' Then 'NA'
							When cc.CaseType = 'CN Mortal Remain' Then 'NA'
							When cc.CaseType = 'Outpatient Multiple' Then 'Multiple Outpatient'
							When cc.CaseType = 'CN Evacuation AA' Then 'NA'
							When cc.CaseType = 'TRAVEL BOOKING (ORBIT ONLY)' Then 'Travel Booking'
							When cc.CaseType = 'Review' Then 'NA'
							When cc.CaseType = 'Simple Case,Very Simple' Then 'Simple'
							When cc.CaseType = 'PAYMENT ONLY' Then 'PAYMENT ONLY'
							When cc.CaseType = 'Repatriation' Then 'Evacuation'
							When cc.CaseType = 'Simple Case' Then 'Simple'
							When cc.CaseType = 'GP Consult' Then 'GP Travel'
							When cc.CaseType = 'Invalid Case' Then 'NA'
							When cc.CaseType = 'M/C Involvement' Then 'NA'
							When cc.CaseType = 'Quotation' Then 'Quotation'
							When cc.CaseType = 'Evacuation AA' Then 'Evacuation'
							When cc.CaseType = 'Mortal Remans' Then 'Mortal Remains'
							When cc.CaseType = 'Mortal Remains' Then 'Mortal Remains'
							When cc.CaseType = 'Death of Cust' Then 'NA'
							When cc.CaseType = 'Evacuation GA' Then 'Evacuation'
							When cc.CaseType = 'Complex Case,Major Distaster' Then 'Complex'
							When cc.CaseType = 'Medium' Then 'Medium'
							When cc.CaseType = 'ARAG Medium' Then 'Medium'
							When cc.CaseType = 'Complex Case' Then 'Complex'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 And cc.ProtocolCode = 'M' Then 'Inpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'M' Then 'Outpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'T' Then 'Simple'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 And cc.ProtocolCode = 'M' Then 'Complex'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseType = '' or cc.CaseType is null) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 And cc.ProtocolCode = 'M' Then 'Simple'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.CaseType not in ('Inpatient', 'Outpatient') and cc.CaseType = 'Complex' And cc.ProtocolCode = 'M' Then 'Inpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.CaseType not in ('Inpatient', 'Outpatient') and cc.CaseType = 'Simple' And cc.ProtocolCode = 'M' Then 'Outpatient'
							when cc.ClientCode In ('AC','AE','BE','CH','IS','OP','PE','AV','BH','VH','MC') and cc.ProtocolCode = 'T' Then 'Simple'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseFee = '' or cc.CaseFee is null or cc.CaseFee = 0) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) > 5 and cc.CaseType not in ('Simple', 'Complex') And cc.ProtocolCode = 'M' Then 'Complex'
							when cc.ClientCode in ('AD','AM','AR','BG','BS','BZ','PN','SL','CG','CL','CM','CP','CR','EA','FA','HT','IA','IZ','NZ','RA','RC','SO','WA','ZU') and (cc.CaseFee = '' or cc.CaseFee is null or cc.CaseFee = 0) And datediff(day, cc.opendate, (Case When cc.FirstCloseDate is not null then cc.FirstCloseDate Else EOMONTH(cc.OpenDate) End)) <= 5 and cc.CaseType not in ('Simple', 'Complex') And cc.ProtocolCode = 'M' Then 'Simple'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) > 5 And cc.ProtocolCode <> 'M' Then 'Complex'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) > 5 And cc.ProtocolCode = 'M' Then 'Inpatient'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) <= 5 And cc.ProtocolCode <> 'M' Then 'Simple'
							When cc.CaseType = '' And datediff(day, cc.opendate, EOMONTH(cc.OpenDate)) <= 5 And cc.ProtocolCode = 'M' Then 'Outpatient'
							When cc.CaseType = 'Inpatient' Then 'Inpatient'
							When cc.CaseType = 'Outpatient' Then 'Outpatient'
							When cc.CaseType = 'Simple' Then 'Simple'
							When cc.CaseType = 'Complex' Then 'Complex'
					
						---CHG0034301
							when cc.ClientCode In ('VH','OU','OP','BT','MC','AX','VV') and cc.CaseType not in ('Travel GP','Evacuation','Simple', 'Complex') and cc.CaseType = 'Outpatient Multiple' Then 'Outpatient Multiple '
						---CHG0034301
							Else cc.CaseType
						End
    ) casefee 
GO

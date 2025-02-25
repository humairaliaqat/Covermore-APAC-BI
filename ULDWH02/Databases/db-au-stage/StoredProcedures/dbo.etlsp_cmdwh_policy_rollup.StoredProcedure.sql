USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_policy_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_policy_rollup]
as
begin

/************************************************************************************************************************************
Author:         Linus Tor
Date:
Prerequisite:
Description:
Change History:
                20130129 - LS - case 18180, NZ: use the same TRIPS schema as AU
                20130212 - LS - case 18232, Include PPACT - AccountingDate
                                code formatting (tabs/indents)
                20130430 - LT - added CompanyKey, AreaType and AreaNo columns. These are sourced from Penguin, therefore, this must
								run after Penguin ETL
				20130506 - LT - added another update statement to populate trips policies not in penguin.
				20130902 - LT - added isTripsPolicy column to denote Penguin or Trips policy
				20130912 - LT - added an update statement to override NZ FLN0001 consultant initial/name due to duplicate initials in
								Consultant table.
*************************************************************************************************************************************/

    set nocount on


    --ETL logic
    --1. Combine Policy records from AU, NZ, and UK
    --2. Insert the combined policy records into Policy table
    --3. update Policy records with respective AgencySKey values from Agency table
    --4. Process oldpolicyno, oldproductcode, oldplancode for new policy records

    --create etl_policy table if null
    if object_id('[db-au-stage].dbo.etl_policy') is null
    begin

        create table [db-au-stage].dbo.etl_policy
        (
            CountryKey varchar(2) not null,
            PolicyKey varchar(41) null,
            AgencySKey bigint null,
            AgencyKey varchar(10) null,
            CustomerKey varchar(41) null,
            ConsultantKey varchar(13) null,
            CountryPolicyKey varchar(13) null,
            BatchNo varchar(8) null,
            PolicyNo int not null,
            CreateDate datetime null,
            CreateTime datetime null,
            IssuedDate datetime null,
            AccountingDate datetime null,
            PolicyType varchar(1) null,
            ProductCode varchar(5) null,
            OldPolicyNo int null,
            NumberOfChildren smallint null,
            NumberOfAdults smallint null,
            NumberOfPersons smallint null,
            DepartureDate datetime null,
            ReturnDate datetime null,
            NumberOfDays smallint null,
            NumberOfBonusDays tinyint null,
            NumberOfWeeks tinyint null,
            NumberOfMonths tinyint null,
            Destination varchar(50) null,
            TripCost varchar(100) null,
            AgencyCode varchar(7) null,
            StoreCode varchar(10) null,
            ConsultantInitial varchar(2) null,
            ConsultantName varchar(50) null,
            PlanCode varchar(6) null,
            Excess smallint null,
            SingleFamily varchar(1) null,
            PolicyComment varchar(250) null,
            BasePremium money null,
            MedicalPremium money null,
            LuggagePremium money null,
            MotorcyclePremium money null,
            RentalCarPremium money null,
            WinterSportPremium money null,
            GrossPremiumExGSTBeforeDiscount money null,
            NetPremium money null,
            NetRate float null,
            CommissionRate float null,
            CommissionAmount money null,
            CommissionTierID varchar(25) null,
            GSTonGrossPremium money null,
            GSTonCommission money null,
            StampDuty money null,
            ActualCommissionAfterDiscount money null,
            ActualGrossPremiumAfterDiscount money null,
            ActualLuggagePremiumAfterDiscount money null,
            ActualMedicalPremiumAfterDiscount money null,
            ActualRentalCarPremiumAfterDiscount money null,
            RentalCarPremiumCovered float null,
            ActualAdminFee money null,
            ActualAdminFeeAfterDiscount money null,
            RiskNet float null,
            VolumePercentage float null,
            NetAdjustmentFactor float null,
            CancellationPremium money null,
            ActualCancellationPremiumAfterDiscount money null,
            CancellationCoverValue varchar(100) null,
            PaymentDate datetime null,
            BankPaymentRecord int null,
            AgentReference varchar(50) null,
            ModeOfTransport varchar(10) null,
            CompanyKey varchar(5) null,
            AreaType varchar(50) null,
            AreaNo varchar(20) null,
            isTripsPolicy bit null           
        )

    end
    else
        truncate table [db-au-stage].dbo.etl_policy

    /*************************************************************/
    --combine policies from AU, NZ, AU and insert into temp policy table
    /*************************************************************/
    insert [db-au-stage].dbo.etl_policy
    (
        CountryKey,
        PolicyKey,
        AgencySKey,
        AgencyKey,
        CustomerKey,
        ConsultantKey,
        CountryPolicyKey,
        BatchNo,
        PolicyNo,
        CreateDate,
        CreateTime,
        IssuedDate,
        AccountingDate,
        PolicyType,
        ProductCode,
        OldPolicyNo,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        DepartureDate,
        ReturnDate,
        NumberOfDays,
        NumberOfBonusDays,
        NumberOfWeeks,
        NumberOfMonths,
        Destination,
        TripCost,
        AgencyCode,
        StoreCode,
        ConsultantInitial,
        ConsultantName,
        PlanCode,
        Excess,
        SingleFamily,
        PolicyComment,
        BasePremium,
        MedicalPremium,
        LuggagePremium,
        MotorcyclePremium,
        RentalCarPremium,
        WinterSportPremium,
        GrossPremiumExGSTBeforeDiscount,
        NetPremium,
        NetRate,
        CommissionRate,
        CommissionAmount,
        CommissionTierID,
        GSTonGrossPremium,
        GSTonCommission,
        StampDuty,
        ActualCommissionAfterDiscount,
        ActualGrossPremiumAfterDiscount,
        ActualLuggagePremiumAfterDiscount,
        ActualMedicalPremiumAfterDiscount,
        ActualRentalCarPremiumAfterDiscount,
        RentalCarPremiumCovered,
        ActualAdminFee,
        ActualAdminFeeAfterDiscount,
        RiskNet,
        VolumePercentage,
        NetAdjustmentFactor,
        CancellationPremium,
        ActualCancellationPremiumAfterDiscount,
        CancellationCoverValue,
        PaymentDate,
        BankPaymentRecord,
        AgentReference,
        ModeOfTransport,
        CompanyKey,
        AreaType,
        AreaNo,
        isTripsPolicy
    )
    select
        'AU' as CountryKey,
        left('AU-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as PolicyKey,
        convert(bigint,null) as AgencySKey,
        'AU-' + ltrim(rtrim(left(p.PPALPHA,7))) as AgencyKey,
        left('AU-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as CustomerKey,
        left('AU-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + ltrim(rtrim(left(p.PPTC,2))),13) as ConsultantKey,
        'AU-' + cast(p.PPPOLYN as varchar(10)) as CountryPolicyKey,
        p.PPBATCH as BatchNo,
        p.PPPOLYN as PolicyNo,
        convert(datetime,convert(varchar(10),p.PPDATE1,120)) as CreateDate,
        p.PPTIME as CreateTime,
        convert(datetime,convert(varchar(10),p.PPDISS,120)) as IssuedDate,
        convert(datetime,convert(varchar(10),p.PPACT,120)) as AccountingDate,
        p.PPNER as PolicyType,
        p.PPPOLTP as ProductCode,
        p.PPPOLD as OldPolicyNo,
        p.PPCHILD as NumberOfChildren,
        p.PPADULT as NumberOfAdults,
        p.PPPERS as NumberOfPersons,
        p.PPDEP as DepartureDate,
        p.PPRET as ReturnDate,
        p.PPDAYS as NumberOfDays,
        p.PPBONUSDAYS as NumberOfBonusDays,
        p.PPWKS as NumberOfWeeks,
        p.PPMTHS as NumberOfMonths,
        p.PPDESN as Destination,
        convert(varchar(100),p.PPTripCost) as TripCost,
        p.PPALPHA as AgencyCode,
        p.StoreCode,
        p.PPTC as ConsultantInitial,
        (
            select top 1 [Name]
            from
                [db-au-stage].dbo.trips_consultant_au
            where
                CLALPHA = p.PPALPHA and
                Initials = p.PPTC
        ) as ConsultantName,
        p.PPPCODE as PlanCode,
        p.PPEXCESS as Excess,
        p.PPFAM as SingleFamily,
        left(p.PPCOMMENTS, 250) as PolicyComment,
        p.PPPRG as BasePremium,
        p.PPDETC as MedicalPremium,
        p.PPVTOT as LuggagePremium,
        p.PPHRTOT as MotorcyclePremium,
        p.PPHIRECARXS as RentalCarPremium,
        p.PPSSKI_PPSBRD_TOT as WinterSportPremium,
        p.PPPRGT as GrossPremiumExGSTBeforeDiscount,
        p.PPPRN as NetPremium,
        p.PPPRP as NetRate,
        p.PPACP as CommissionRate,
        p.PPPSD as CommissionAmount,
        p.COMMISSIONTIERID as CommissionTierID,
        p.PPRGTGST as GSTonGrossPremium,
        p.PPSDGST as GSTonCommission,
        p.PPRGTSTAMP as StampDuty,
        p.PPPASD as ActualCommissionAfterDiscount,
        p.PPPRAGT as ActualGrossPremiumAfterDiscount,
        p.PPAVTOT as ActualLuggagePremiumAfterDiscount,
        p.PPADETC as ActualMedicalPremiumAfterDiscount,
        P.PPAHIRECARXS as ActualRentalCarPremiumAfterDiscount,
        p.PPHIRECAR_AMOUNTCOVERED as RentalCarPremiumCovered,
        p.PPPAF as ActualAdminFee,
        p.PPPAAF as ActualAdminFeeAfterDiscount,
        p.RISKNET as RiskNet,
        p.VOLUMEPERCENTAGE as VolumePercentage,
        p.PPNAF as NetAdjustmentFactor,
        p.PPCANX as CancellationPremium,
        p.PPACANX as ActualCancellationPremiumAfterDiscount,
        p.PPCANXTC as CancellationCoverValue,
        p.PPPDATE as PaymentDate,
        p.PPBKREC as BankPaymentRecord,
        p.PPREF as AgentReference,
        case
            when p.PPTRANSCODEX = 'COA' then 'Coach Tour'
            when p.PPTRANSCODEX = 'HIR' then 'Hire Car'
            when p.PPTRANSCODEX = 'RAI' then 'Rail'
            when p.PPTRANSCODEX = 'CRU' then 'Cruise'
            when p.PPTRANSCODEX = 'OTH' then 'Other'
        end ModeOfTransport,
        null as CompanyKey,
        null as AreaType,
        null as AreaNo,
        case when p.PPPENGUIN = 1 then 0 else 1 end as isTripsPolicy
    from
        [db-au-stage].dbo.trips_ppreg_au p

    union all

    select
        'NZ' as CountryKey,
        left('NZ-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as PolicyKey,
        convert(bigint,null) as AgencySKey,
        'NZ-' + ltrim(rtrim(left(p.PPALPHA,7))) as AgencyKey,
        left('NZ-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as CustomerKey,
        left('NZ-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + ltrim(rtrim(left(p.PPTC,2))),13) as ConsultantKey,
        'NZ-' + cast(p.PPPOLYN as varchar(10)) as CountryPolicyKey,
        p.PPBATCH as BatchNo,
        p.PPPOLYN as PolicyNo,
        convert(datetime,convert(varchar(10),p.PPDATE1,120)) as CreateDate,
        p.PPTIME as CreateTime,
        convert(datetime,convert(varchar(10),p.PPDISS,120)) as IssuedDate,
        convert(datetime,convert(varchar(10),p.PPACT,120)) as AccountingDate,
        p.PPNER as PolicyType,
        p.PPPOLTP as ProductCode,
        p.PPPOLD as OldPolicyNo,
        p.PPCHILD as NumberOfChildren,
        p.PPADULT as NumberOfAdults,
        p.PPPERS as NumberOfPersons,
        p.PPDEP as DepartureDate,
        p.PPRET as ReturnDate,
        p.PPDAYS as NumberOfDays,
        p.PPBONUSDAYS as NumberOfBonusDays,
        p.PPWKS as NumberOfWeeks,
        p.PPMTHS as NumberOfMonths,
        p.PPDESN as Destination,
        convert(varchar(100),p.PPTripCost) as TripCost,
        p.PPALPHA as AgencyCode,
        p.StoreCode,
        p.PPTC as ConsultantInitial,
        (
            select top 1 [Name]
            from
                [db-au-stage].dbo.trips_consultant_nz
            where
                CLALPHA = p.PPALPHA and
                Initials = p.PPTC
        ) as ConsultantName,
        p.PPPCODE as PlanCode,
        p.PPEXCESS as Excess,
        p.PPFAM as SingleFamily,
        left(p.PPCOMMENTS, 250) as PolicyComment,
        p.PPPRG as BasePremium,
        p.PPDETC as MedicalPremium,
        p.PPVTOT as LuggagePremium,
        p.PPHRTOT as MotorcyclePremium,
        p.PPHIRECARXS as RentalCarPremium,
        p.PPSSKI_PPSBRD_TOT as WinterSportPremium,
        p.PPPRGT as GrossPremiumExGSTBeforeDiscount,
        p.PPPRN as NetPremium,
        p.PPPRP as NetRate,
        p.PPACP as CommissionRate,
        p.PPPSD as CommissionAmount,
        p.COMMISSIONTIERID as CommissionTierID,
        p.PPRGTGST as GSTonGrossPremium,
        p.PPSDGST as GSTonCommission,
        p.PPRGTSTAMP as StampDuty,
        p.PPPASD as ActualCommissionAfterDiscount,
        p.PPPRAGT as ActualGrossPremiumAfterDiscount,
        p.PPAVTOT as ActualLuggagePremiumAfterDiscount,
        p.PPADETC as ActualMedicalPremiumAfterDiscount,
        P.PPAHIRECARXS as ActualRentalCarPremiumAfterDiscount,
        p.PPHIRECAR_AMOUNTCOVERED as RentalCarPremiumCovered,
        p.PPPAF as ActualAdminFee,
        p.PPPAAF as ActualAdminFeeAfterDiscount,
        p.RISKNET as RiskNet,
        p.VOLUMEPERCENTAGE as VolumePercentage,
        p.PPNAF as NetAdjustmentFactor,
        p.PPCANX as CancellationPremium,
        p.PPACANX as ActualCancellationPremiumAfterDiscount,
        p.PPCANXTC as CancellationCoverValue,
        p.PPPDATE as PaymentDate,
        p.PPBKREC as BankPaymentRecord,
        p.PPREF as AgentReference,
        case
            when p.PPTRANSCODEX = 'COA' then 'Coach Tour'
            when p.PPTRANSCODEX = 'HIR' then 'Hire Car'
            when p.PPTRANSCODEX = 'RAI' then 'Rail'
            when p.PPTRANSCODEX = 'CRU' then 'Cruise'
            when p.PPTRANSCODEX = 'OTH' then 'Other'
        end ModeOfTransport,
        null as CompanyKey,
        null as AreaType,
        null as AreaNo,
        case when p.PPPENGUIN = 1 then 0 else 1 end as isTripsPolicy        
    from
        [db-au-stage].dbo.trips_ppreg_nz p

    union all

    select
        'UK' as CountryKey,
        left('UK-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as PolicyKey,
        convert(bigint,null) as AgencySKey,
        'UK-' + ltrim(rtrim(left(p.PPALPHA,7))) as AgencyKey,
        left('UK-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as CustomerKey,
        left('UK-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + ltrim(rtrim(left(p.PPTC,2))),13) as ConsultantKey,
        'UK-' + cast(p.PPPOLYN as varchar(10)) as CountryPolicyKey,
        p.PPBATCH as BatchNo,
        p.PPPOLYN as PolicyNo,
        convert(datetime,convert(varchar(10),p.PPDATE1,120)) as CreateDate,
        p.PPTIME as CreateTime,
        convert(datetime,convert(varchar(10),p.PPDISS,120)) as IssuedDate,
        convert(datetime,convert(varchar(10),p.PPACT,120)) as AccountingDate,
        p.PPNER as PolicyType,
        p.PPPOLTP as ProductCode,
        p.PPPOLD as OldPolicyNo,
        p.PPCHILD as NumberOfChildren,
        p.PPADULT as NumberOfAdults,
        p.PPPERS as NumberOfPersons,
        p.PPDEP as DepartureDate,
        p.PPRET as ReturnDate,
        p.PPDAYS as NumberOfDays,
        null as NumberOfBonusDays,
        p.PPWKS as NumberOfWeeks,
        p.PPMTHS as NumberOfMonths,
        p.PPDESN as Destination,
        convert(varchar(100),p.PPTripCost) as TripCost,
        p.PPALPHA as AgencyCode,
        null StoreCode,
        p.PPTC as ConsultantInitial,
        (
            select top 1 [Name]
            from
                [db-au-stage].dbo.trips_consultant_uk
            where
                CLALPHA = p.PPALPHA and
                Initials = p.PPTC
        ) as ConsultantName,
        p.PPPCODE as PlanCode,
        p.PPEXCESS as Excess,
        p.PPFAM as SingleFamily,
        null as PolicyComment,
        p.PPPRG as BasePremium,
        p.PPDETC as MedicalPremium,
        p.PPVTOT as LuggagePremium,
        p.PPHRTOT as MotorcyclePremium,
        p.PPHIRECARXS as RentalCarPremium,
        null as WinterSportPremium,
        p.PPPRGT as GrossPremiumExGSTBeforeDiscount,
        p.PPPRN as NetPremium,
        p.PPPRP as NetRate,
        p.PPACP as CommissionRate,
        p.PPPSD as CommissionAmount,
        null as CommissionTierID,
        p.PPRGTGST as GSTonGrossPremium,
        p.PPSDGST as GSTonCommission,
        p.PPRGTSTAMP as StampDuty,
        p.PPPASD as ActualCommissionAfterDiscount,
        p.PPPRAGT as ActualGrossPremiumAfterDiscount,
        p.PPAVTOT as ActualLuggagePremiumAfterDiscount,
        p.PPADETC as ActualMedicalPremiumAfterDiscount,
        P.PPAHIRECARXS as ActualRentalCarPremiumAfterDiscount,
        null as RentalCarPremiumCovered,
        null as ActualAdminFee,
        null as ActualAdminFeeAfterDiscount,
        null as RiskNet,
        null as VolumePercentage,
        null as NetAdjustmentFactor,
        null as CancellationPremium,
        null as ActualCancellationPremiumAfterDiscount,
        null as CancellationCoverValue,
        p.PPPDATE as PaymentDate,
        p.PPBKREC as BankPaymentRecord,
        p.PPREF as AgentReference,
        case
            when p.PPTRANSCODEX = 'COA' then 'Coach Tour'
            when p.PPTRANSCODEX = 'HIR' then 'Hire Car'
            when p.PPTRANSCODEX = 'RAI' then 'Rail'
            when p.PPTRANSCODEX = 'CRU' then 'Cruise'
            when p.PPTRANSCODEX = 'OTH' then 'Other'
        end ModeOfTransport,
        null as CompanyKey,
        null as AreaType,
        null as AreaNo,
        case when p.PPPENGUIN = 1 then 0 else 1 end as isTripsPolicy        
    from
        [db-au-stage].dbo.trips_ppreg_uk p

    union all

    select
        'MY' as CountryKey,
        left('MY-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as PolicyKey,
        convert(bigint,null) as AgencySKey,
        'MY-' + ltrim(rtrim(left(p.PPALPHA,7))) as AgencyKey,
        left('MY-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as CustomerKey,
        left('MY-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + ltrim(rtrim(left(p.PPTC,2))),13) as ConsultantKey,
        'MY-' + cast(p.PPPOLYN as varchar(10)) as CountryPolicyKey,
        p.PPBATCH as BatchNo,
        p.PPPOLYN as PolicyNo,
        convert(datetime,convert(varchar(10),p.PPDATE1,120)) as CreateDate,
        p.PPTIME as CreateTime,
        convert(datetime,convert(varchar(10),p.PPDISS,120)) as IssuedDate,
        convert(datetime,convert(varchar(10),p.PPACT,120)) as AccountingDate,
        p.PPNER as PolicyType,
        p.PPPOLTP as ProductCode,
        p.PPPOLD as OldPolicyNo,
        p.PPCHILD as NumberOfChildren,
        p.PPADULT as NumberOfAdults,
        p.PPPERS as NumberOfPersons,
        p.PPDEP as DepartureDate,
        p.PPRET as ReturnDate,
        p.PPDAYS as NumberOfDays,
        p.PPBONUSDAYS as NumberOfBonusDays,
        p.PPWKS as NumberOfWeeks,
        p.PPMTHS as NumberOfMonths,
        p.PPDESN as Destination,
        convert(varchar(100),p.PPTripCost) as TripCost,
        p.PPALPHA as AgencyCode,
        p.StoreCode,
        p.PPTC as ConsultantInitial,
        (
            select top 1 [Name]
            from
                [db-au-stage].dbo.trips_consultant_my
            where
                CLALPHA = p.PPALPHA and
                Initials = p.PPTC
        ) as ConsultantName,
        p.PPPCODE as PlanCode,
        p.PPEXCESS as Excess,
        p.PPFAM as SingleFamily,
        left(p.PPCOMMENTS, 250) as PolicyComment,
        p.PPPRG as BasePremium,
        p.PPDETC as MedicalPremium,
        p.PPVTOT as LuggagePremium,
        p.PPHRTOT as MotorcyclePremium,
        p.PPHIRECARXS as RentalCarPremium,
        p.PPSSKI_PPSBRD_TOT as WinterSportPremium,
        p.PPPRGT as GrossPremiumExGSTBeforeDiscount,
        p.PPPRN as NetPremium,
        p.PPPRP as NetRate,
        p.PPACP as CommissionRate,
        p.PPPSD as CommissionAmount,
        p.COMMISSIONTIERID as CommissionTierID,
        p.PPRGTGST as GSTonGrossPremium,
        p.PPSDGST as GSTonCommission,
        p.PPRGTSTAMP as StampDuty,
        p.PPPASD as ActualCommissionAfterDiscount,
        p.PPPRAGT as ActualGrossPremiumAfterDiscount,
        p.PPAVTOT as ActualLuggagePremiumAfterDiscount,
        p.PPADETC as ActualMedicalPremiumAfterDiscount,
        P.PPAHIRECARXS as ActualRentalCarPremiumAfterDiscount,
        p.PPHIRECAR_AMOUNTCOVERED as RentalCarPremiumCovered,
        p.PPPAF as ActualAdminFee,
        p.PPPAAF as ActualAdminFeeAfterDiscount,
        p.RISKNET as RiskNet,
        p.VOLUMEPERCENTAGE as VolumePercentage,
        p.PPNAF as NetAdjustmentFactor,
        p.PPCANX as CancellationPremium,
        p.PPACANX as ActualCancellationPremiumAfterDiscount,
        p.PPCANXTC as CancellationCoverValue,
        p.PPPDATE as PaymentDate,
        p.PPBKREC as BankPaymentRecord,
        p.PPREF as AgentReference,
        case
            when p.PPTRANSCODEX = 'COA' then 'Coach Tour'
            when p.PPTRANSCODEX = 'HIR' then 'Hire Car'
            when p.PPTRANSCODEX = 'RAI' then 'Rail'
            when p.PPTRANSCODEX = 'CRU' then 'Cruise'
            when p.PPTRANSCODEX = 'OTH' then 'Other'
        end ModeOfTransport,
        null as CompanyKey,
        null as AreaType,
        null as AreaNo,
        case when p.PPPENGUIN = 1 then 0 else 1 end as isTripsPolicy        
    from
        [db-au-stage].dbo.trips_ppreg_my p

    union all

    select
        'SG' as CountryKey,
        left('SG-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as PolicyKey,
        convert(bigint,null) as AgencySKey,
        'SG-' + ltrim(rtrim(left(p.PPALPHA,7))) as AgencyKey,
        left('SG-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + convert(varchar,p.PPPOLYN),41) as CustomerKey,
        left('SG-' + ltrim(rtrim(left(p.PPALPHA,7))) + '-' + ltrim(rtrim(left(p.PPTC,2))),13) as ConsultantKey,
        'SG-' + cast(p.PPPOLYN as varchar(10)) as CountryPolicyKey,
        p.PPBATCH as BatchNo,
        p.PPPOLYN as PolicyNo,
        convert(datetime,convert(varchar(10),p.PPDATE1,120)) as CreateDate,
        p.PPTIME as CreateTime,
        convert(datetime,convert(varchar(10),p.PPDISS,120)) as IssuedDate,
        convert(datetime,convert(varchar(10),p.PPACT,120)) as AccountingDate,
        p.PPNER as PolicyType,
        p.PPPOLTP as ProductCode,
        p.PPPOLD as OldPolicyNo,
        p.PPCHILD as NumberOfChildren,
        p.PPADULT as NumberOfAdults,
        p.PPPERS as NumberOfPersons,
        p.PPDEP as DepartureDate,
        p.PPRET as ReturnDate,
        p.PPDAYS as NumberOfDays,
        p.PPBONUSDAYS as NumberOfBonusDays,
        p.PPWKS as NumberOfWeeks,
        p.PPMTHS as NumberOfMonths,
        p.PPDESN as Destination,
        convert(varchar(100),p.PPTripCost) as TripCost,
        p.PPALPHA as AgencyCode,
        p.StoreCode,
        p.PPTC as ConsultantInitial,
        (
            select top 1 [Name]
            from
                [db-au-stage].dbo.trips_consultant_sg
            where
                CLALPHA = p.PPALPHA and
                Initials = p.PPTC
        ) as ConsultantName,
        p.PPPCODE as PlanCode,
        p.PPEXCESS as Excess,
        p.PPFAM as SingleFamily,
        left(p.PPCOMMENTS, 250) as PolicyComment,
        p.PPPRG as BasePremium,
        p.PPDETC as MedicalPremium,
        p.PPVTOT as LuggagePremium,
        p.PPHRTOT as MotorcyclePremium,
        p.PPHIRECARXS as RentalCarPremium,
        p.PPSSKI_PPSBRD_TOT as WinterSportPremium,
        p.PPPRGT as GrossPremiumExGSTBeforeDiscount,
        p.PPPRN as NetPremium,
        p.PPPRP as NetRate,
        p.PPACP as CommissionRate,
        p.PPPSD as CommissionAmount,
        p.COMMISSIONTIERID as CommissionTierID,
        p.PPRGTGST as GSTonGrossPremium,
        p.PPSDGST as GSTonCommission,
        p.PPRGTSTAMP as StampDuty,
        p.PPPASD as ActualCommissionAfterDiscount,
        p.PPPRAGT as ActualGrossPremiumAfterDiscount,
        p.PPAVTOT as ActualLuggagePremiumAfterDiscount,
        p.PPADETC as ActualMedicalPremiumAfterDiscount,
        P.PPAHIRECARXS as ActualRentalCarPremiumAfterDiscount,
        p.PPHIRECAR_AMOUNTCOVERED as RentalCarPremiumCovered,
        p.PPPAF as ActualAdminFee,
        p.PPPAAF as ActualAdminFeeAfterDiscount,
        p.RISKNET as RiskNet,
        p.VOLUMEPERCENTAGE as VolumePercentage,
        p.PPNAF as NetAdjustmentFactor,
        p.PPCANX as CancellationPremium,
        p.PPACANX as ActualCancellationPremiumAfterDiscount,
        p.PPCANXTC as CancellationCoverValue,
        p.PPPDATE as PaymentDate,
        p.PPBKREC as BankPaymentRecord,
        p.PPREF as AgentReference,
        case
            when p.PPTRANSCODEX = 'COA' then 'Coach Tour'
            when p.PPTRANSCODEX = 'HIR' then 'Hire Car'
            when p.PPTRANSCODEX = 'RAI' then 'Rail'
            when p.PPTRANSCODEX = 'CRU' then 'Cruise'
            when p.PPTRANSCODEX = 'OTH' then 'Other'
        end ModeOfTransport,
        null as CompanyKey,
        null as AreaType,
        null as AreaNo,
        case when p.PPPENGUIN = 1 then 0 else 1 end as isTripsPolicy        
    from
        [db-au-stage].dbo.trips_ppreg_sg p


	/*************************************************************/
	--Update Penguin-sourced columns - CompanyKey, AreaType, AreaNo
	--Prerequisite: penPolicy and penPolicyTransaction tables exist with latest data
	/*************************************************************/
	update [db-au-stage].dbo.etl_Policy
	set 
        AreaType = pol.AreaType,
        AreaNo = pol.AreaNumber,
        CompanyKey = pol.CompanyKey
	from
		[db-au-stage].dbo.etl_Policy p
		cross apply
		(
			select top 1 
			    pp.AreaType, 
			    pp.AreaNumber, 
			    pp.CompanyKey
			from
				[db-au-cmdwh].dbo.penPolicy pp
			where
				pp.PolicyNumber = 
                    case 
                        when p.PolicyType in ('R','E','A') then convert(varchar, p.OldPolicyNo)
                        else convert(varchar, p.PolicyNo)
                    end and
				pp.CountryKey = p.CountryKey and
				pp.AlphaCode = p.AgencyCode
		) pol


	/*************************************************************/
	--Update Penguin-sourced columns - CompanyKey, AreaType, AreaNo
	--where policy does not exist in Penguin
	/*************************************************************/	
	update [db-au-stage].dbo.etl_Policy
	set AreaType = case when CountryKey = 'NZ' then
							case when PlanCode IN ('X',' XM', 'X15', 'X2', 'X4', 'X6', 'X8', 'XBA8', 'C', 'C2', 'C4', 'C6', 'C8', 'C15', 'PBA8') or PlanCode like '%D%' then 'Domestic'
								 when Destination <> 'New Zealand' then 'International'
								 when Destination = 'New Zealand' then 'Domestic'
								 else 'International'
							end
						when CountryKey = 'AU' then
							case when PlanCode IN ('X',' XM', 'XBA5') OR PlanCode like '%D%' THEN 'Domestic' 
								  when PlanCode like 'XA%' AND PlanCode NOT IN ('XA',' XA+') THEN 'Domestic' 
								  when PlanCode IN ('PBA5', 'CPBA5') THEN 'Domestic (Inbound)'
								  when Destination <> 'Australia' then 'International'
								  when Destination = 'Australia' then 'Domestic'
								  else 'International'
							 end						
						else case when PlanCode IN ('X',' XM', 'XBA5') OR PlanCode like '%D%' THEN 'Domestic' 
								  when PlanCode like 'XA%' AND PlanCode NOT IN ('XA',' XA+') THEN 'Domestic' 
								  when PlanCode IN ('PBA5', 'CPBA5') THEN 'Domestic (Inbound)'
								  else 'International'
							 end
					end,
		AreaNo = case when CountryKey = 'AU' then
						case when PlanCode in ('PBA5','CPBA5') then 'Area 6'
							 when PlanCode like '%1' and PlanCode not like '%D%' then 'Area 1'
							 when PlanCode like '%2' and PlanCode not like '%D%' then 'Area 2'
							 when PlanCode like '%3' and PlanCode not like '%D%' then 'Area 3'
							 when (PlanCode like '%4' or PlanCode like '%5') and PlanCode not like '%D%' then 'Area 4'
							 when (PlanCode in ('X','XM') or PlanCode like '%D%') then 'Area 5'
							 else 'Unknown'
						end
					  when CountryKey = 'NZ' then
						case when PlanCode like 'C%' or PlanCode like 'D%' then 'Area 8'
							 when PlanCode like 'A%' and Destination = 'Worldwide' then 'Area 10'
							 when PlanCode like 'A%' and Destination = 'Restricted Worldwide' then 'Area 11'
							 when PlanCode like 'A%' and Destination = 'South Pacific and Australia' then 'Area 12'
							 when PlanCode like 'A%' and Destination = 'New Zealand Only' then 'Area 13'
							 when PlanCode like 'A%' then 'Area 0'
							 when PlanCode like 'X%' or len(PlanCode) > 3 then 
								case when PlanCode like '%M%' then 'Area ' + convert(varchar, convert(int, substring(PlanCode, patindex('%[0-9]%', PlanCode), len(PlanCode) - patindex('%[0-9]%', PlanCode) + 1)) + 9)
									 else 'Area ' + substring(PlanCode, patindex('%[0-9]%', PlanCode), len(PlanCode) - patindex('%[0-9]%', PlanCode) + 1)
								end
							 else 'Unknown'
						end
					  else case when PlanCode like '%1' then 'Area 1'
								when PlanCode like '%2' then 'Area 2'
								when PlanCode like '%3' then 'Area 3'
								when PlanCode like '%4' then 'Area 4'
								when PlanCode like '%5' then 'Area 5'
								when PlanCode like '%6' then 'Area 6'
								when PlanCode like '%7' then 'Area 7'
								else 'Unknown'
						   end
				end,
				CompanyKey = case when CountryKey = 'AU' and left(AgencyCode,2) in ('AN','AP','AW','MB','NR','RA','RC','RQ','RT','RV') then 'TIP' 
								  else 'CM'
							 end
	where 
		AreaType is null and
		left(AgencyCode,2) not in ('AN','AP','AW','MB','NR','RA','RC','RQ','RT','RV')

	
    /*************************************************************/
    --Update AgencySKey in [db-au-stage].dbo.etl_Policy records
    --For Agency AgencyStatus = Current
    /*************************************************************/
    update [db-au-stage].dbo.etl_Policy
    set AgencySKey = a.AgencySKey
    from
        [db-au-stage].dbo.etl_Policy p
        join [db-au-cmdwh].dbo.Agency a on
            p.AgencyKey collate database_default = a.AgencyKey collate database_default and
            a.AgencyStatus = 'Current'

    /*************************************************************/
    --Update AgencySKey in [db-au-stage].dbo.etl_Policy records
    --For Agency AgencyStatus = Not Current AND
    --Policy CreateDate between AgencyStartDate and AgencyEndDate
    /*************************************************************/

    update [db-au-stage].dbo.etl_Policy
    set AgencySKey = a.AgencySKey
    from
        [db-au-stage].dbo.etl_Policy p
        join [db-au-cmdwh].dbo.Agency a on
            p.AgencyKey collate database_default = a.AgencyKey collate database_default and
            a.AgencyStatus = 'Not Current' and
            p.CreateDate between a.AgencyStartDate and a.AgencyEndDate



    /*************************************************************/
    --delete existing policies or create table if table doesnt exist
    /*************************************************************/
    if object_id('[db-au-cmdwh].dbo.Policy') is null
    begin

        create table [db-au-cmdwh].dbo.Policy
        (
            CountryKey varchar(2) not null,
            PolicyKey varchar(41) null,
            AgencySKey bigint null,
            AgencyKey varchar(10) null,
            CustomerKey varchar(41) null,
            ConsultantKey varchar(13) null,
            CountryPolicyKey varchar(13) null,
            BatchNo varchar(8) null,
            PolicyNo int not null,
            CreateDate datetime null,
            CreateTime datetime null,
            IssuedDate datetime null,
            AccountingDate datetime null,
            PolicyType varchar(5) null,
            ProductCode varchar(5) null,
            OldPolicyNo int null,
            OldPolicyType varchar(5) null,
            OldProductCode varchar(5) null,
            OldPlanCode varchar(6) null,
            NumberOfChildren smallint null,
            NumberOfAdults smallint null,
            NumberOfPersons smallint null,
            DepartureDate datetime null,
            ReturnDate datetime null,
            NumberOfDays smallint null,
            NumberOfBonusDays tinyint null,
            NumberOfWeeks tinyint null,
            NumberOfMonths tinyint null,
            Destination varchar(50) null,
            TripCost varchar(100) null,
            AgencyCode varchar(7) null,
            StoreCode varchar(10) null,
            ConsultantInitial varchar(2) null,
            ConsultantName varchar(50) null,
            PlanCode varchar(6) null,
            Excess smallint null,
            SingleFamily varchar(1) null,
            PolicyComment varchar(250) null,
            BasePremium money null,
            MedicalPremium money null,
            LuggagePremium money null,
            MotorcyclePremium money null,
            RentalCarPremium money null,
            WinterSportPremium money null,
            GrossPremiumExGSTBeforeDiscount money null,
            NetPremium money null,
            NetRate float null,
            CommissionRate float null,
            CommissionAmount money null,
            CommissionTierID varchar(25) null,
            GSTonGrossPremium money null,
            GSTOnCommission money null,
            StampDuty money null,
            ActualCommissionAfterDiscount money null,
            ActualGrossPremiumAfterDiscount money null,
            ActualLuggagePremiumAfterDiscount money null,
            ActualMedicalPremiumAfterDiscount money null,
            ActualRentalCarPremiumAfterDiscount money null,
            RentalCarPremiumCovered float null,
            ActualAdminFee money null,
            ActualAdminFeeAfterDiscount money null,
            RiskNet float null,
            VolumePercentage float null,
            NetAdjustmentFactor float null,
            CancellationPremium money null,
            ActualCancellationPremiumAfterDiscount money null,
            CancellationCoverValue varchar(100) null,
            PaymentDate datetime null,
            BankPaymentRecord int null,
            AgentReference varchar(50) null,
            ModeOfTransport varchar(10) null,
            YAGOIssuedDate datetime null,
            CompanyKey varchar(5) null,
            AreaType varchar(50) null,
            AreaNo varchar(20) null,
            isTripsPolicy bit null
        )

        create clustered index idx_Policy_IssuedDate on [db-au-cmdwh].dbo.Policy(IssuedDate)
        create index idx_Policy_AgencyKey on [db-au-cmdwh].dbo.Policy(AgencyKey)
        create index idx_Policy_AgencySKey on [db-au-cmdwh].dbo.Policy(AgencySKey)
        create index idx_Policy_BankPaymentRecord on [db-au-cmdwh].dbo.Policy(BankPaymentRecord, CountryKey, AgencyCode)
        create index idx_Policy_ConsultantKey on [db-au-cmdwh].dbo.Policy(ConsultantKey)
        create index idx_Policy_CountryKey on [db-au-cmdwh].dbo.Policy(CountryKey)
        create index idx_Policy_CountryPolicyKey on [db-au-cmdwh].dbo.Policy(CountryPolicyKey)
        create index idx_Policy_CreateDate on [db-au-cmdwh].dbo.Policy(CreateDate)
        create index idx_Policy_CustomerKey on [db-au-cmdwh].dbo.Policy(CustomerKey)
        create index idx_Policy_DepartureDate on [db-au-cmdwh].dbo.Policy(DepartureDate)
        create index idx_Policy_OldPolicyNo on [db-au-cmdwh].dbo.Policy(OldPolicyNo, CountryKey, PolicyType)
        create index idx_Policy_PaymentDate on [db-au-cmdwh].dbo.Policy(PaymentDate, AgencyKey)
        create index idx_Policy_PolicyKey on [db-au-cmdwh].dbo.Policy(PolicyKey)
        create index idx_Policy_PolicyNo on [db-au-cmdwh].dbo.Policy(PolicyNo)
        create index idx_Policy_PolicyType on [db-au-cmdwh].dbo.Policy(PolicyType)
        create index idx_Policy_ProductCode on [db-au-cmdwh].dbo.Policy(ProductCode)
        create index idx_Policy_ReturnDate on [db-au-cmdwh].dbo.Policy(ReturnDate, CountryKey, PolicyType)
        create index idx_Policy_YAGOIssuedDate on [db-au-cmdwh].dbo.Policy(YAGOIssuedDate)

    end
    else
    begin

        delete [db-au-cmdwh].dbo.Policy
        from
            [db-au-cmdwh].dbo.Policy a
            join [db-au-stage].dbo.etl_policy b on
                a.CountryKey collate database_default = b.CountryKey collate database_default and
                a.PolicyNo = b.PolicyNo

    end


    /*************************************************************/
    -- Transfer data from [db-au-stage].dbo.etl_policy to [db-au-cmdwh].dbo.Policy
    /*************************************************************/

    insert into [db-au-cmdwh].dbo.Policy with (tablock)
    (
        CountryKey,
        PolicyKey,
        AgencySKey,
        AgencyKey,
        CustomerKey,
        ConsultantKey,
        CountryPolicyKey,
        BatchNo,
        PolicyNo,
        CreateDate,
        CreateTime,
        IssuedDate,
        YAGOIssuedDate,
        AccountingDate,
        PolicyType,
        ProductCode,
        OldPolicyNo,
        OldPolicyType,
        OldProductCode,
        OldPlanCode,
        NumberOfChildren,
        NumberOfAdults,
        NumberOfPersons,
        DepartureDate,
        ReturnDate,
        NumberOfDays,
        NumberOfBonusDays,
        NumberOfWeeks,
        NumberOfMonths,
        Destination,
        TripCost,
        AgencyCode,
        StoreCode,
        ConsultantInitial,
        ConsultantName,
        PlanCode,
        Excess,
        SingleFamily,
        PolicyComment,
        BasePremium,
        MedicalPremium,
        LuggagePremium,
        MotorcyclePremium,
        RentalCarPremium,
        WinterSportPremium,
        GrossPremiumExGSTBeforeDiscount,
        NetPremium,
        NetRate,
        CommissionRate,
        CommissionAmount,
        CommissionTierID,
        GSTonGrossPremium,
        GSTOnCommission,
        StampDuty,
        ActualCommissionAfterDiscount,
        ActualGrossPremiumAfterDiscount,
        ActualLuggagePremiumAfterDiscount,
        ActualMedicalPremiumAfterDiscount,
        ActualRentalCarPremiumAfterDiscount,
        RentalCarPremiumCovered,
        ActualAdminFee,
        ActualAdminFeeAfterDiscount,
        RiskNet,
        VolumePercentage,
        NetAdjustmentFactor,
        CancellationPremium,
        ActualCancellationPremiumAfterDiscount,
        CancellationCoverValue,
        PaymentDate,
        BankPaymentRecord,
        AgentReference,
        ModeOfTransport,
        CompanyKey,
        AreaType,
        AreaNo,
        isTripsPolicy
    )
    select
        p.CountryKey,
        p.PolicyKey,
        p.AgencySKey,
        p.AgencyKey,
        p.CustomerKey,
        p.ConsultantKey,
        p.CountryPolicyKey,
        p.BatchNo,
        p.PolicyNo,
        p.CreateDate,
        p.CreateTime,
        p.IssuedDate,
        dateadd(year, 1, p.IssuedDate) YAGOIssuedDate,
        p.AccountingDate,
        p.PolicyType,
        p.ProductCode,
        p.OldPolicyNo,
        null as OldPolicyType,
        null as OldProductCode,
        null as OldPlanCode,
        p.NumberOfChildren,
        p.NumberOfAdults,
        p.NumberOfPersons,
        p.DepartureDate,
        p.ReturnDate,
        p.NumberOfDays,
        p.NumberOfBonusDays,
        p.NumberOfWeeks,
        p.NumberOfMonths,
        p.Destination,
        p.TripCost,
        p.AgencyCode,
        p.StoreCode,
        p.ConsultantInitial,
        p.ConsultantName,
        p.PlanCode,
        p.Excess,
        p.SingleFamily,
        p.PolicyComment,
        p.BasePremium,
        p.MedicalPremium,
        p.LuggagePremium,
        p.MotorcyclePremium,
        p.RentalCarPremium,
        p.WinterSportPremium,
        p.GrossPremiumExGSTBeforeDiscount,
        p.NetPremium,
        p.NetRate,
        p.CommissionRate,
        p.CommissionAmount,
        p.CommissionTierID,
        p.GSTonGrossPremium,
        p.GSTOnCommission,
        p.StampDuty,
        p.ActualCommissionAfterDiscount,
        p.ActualGrossPremiumAfterDiscount,
        p.ActualLuggagePremiumAfterDiscount,
        p.ActualMedicalPremiumAfterDiscount,
        p.ActualRentalCarPremiumAfterDiscount,
        p.RentalCarPremiumCovered,
        p.ActualAdminFee,
        p.ActualAdminFeeAfterDiscount,
        p.RiskNet,
        p.VolumePercentage,
        p.NetAdjustmentFactor,
        p.CancellationPremium,
        p.ActualCancellationPremiumAfterDiscount,
        p.CancellationCoverValue,
        p.PaymentDate,
        p.BankPaymentRecord,
        p.AgentReference,
        p.ModeOfTransport,
        p.CompanyKey,
        p.AreaType,
        p.AreaNo,
        p.isTripsPolicy
    from
        [db-au-stage].dbo.etl_policy p


	--Override NZ FLN0001 consultant initial/name due to duplicate initials in Consultant table.	
	update [db-au-cmdwh].dbo.Policy
	set ConsultantName = case when ConsultantInitial = 'DB' then 'Donna Barker'
							  when ConsultantInitial = 'DO' then 'Dominic Burbidge'
							  else ConsultantName
						 end
	where
		CountryKey = 'NZ' and
		AgencyCode = 'FLN0001' and
		IssuedDate >= '2013-09-01'
	
	
    --create temp table to store old policy if null
    if object_id('[db-au-stage].dbo.etl_PolicyOld') is null
    begin

        create table [db-au-stage].dbo.etl_PolicyOld
        (
            CountryKey varchar(2) not null,
            PolicyNo int not null,
            OldPolicyNo int null,
            OldPolicyType varchar(1) not null,
            OldProductCode varchar(5) null,
            OldPlanCode varchar(6) null
        )

        create index idx_PolicyOld_CountryKey on [db-au-stage].dbo.etl_PolicyOld(CountryKey)
        create index idx_PolicyOld_PolicyNo on [db-au-stage].dbo.etl_PolicyOld(PolicyNo)
        create index idx_PolicyOld_OldPolicyNo on [db-au-stage].dbo.etl_PolicyOld(OldPolicyNo)

    end
    else
        truncate table [db-au-stage].dbo.etl_PolicyOld

    /*************************************************************/
    --select cancelled policies and store in etl_PolicyOld table
    /*************************************************************/

    --if we strip the 9 prefix from cancelled policyno and that doesn't equal oldpolicyno then this is an addon or extension cancellation.
    --else it is a base policy cancellation
    insert [db-au-stage].dbo.etl_PolicyOld
    select
        p.CountryKey,
        p.PolicyNo,
        case
            when (right(cast(p.PolicyNo as varchar),len(cast(p.PolicyNo as varchar))-1) <> cast(p.OldPolicyNo as varchar)) then convert(int,right(cast(p.PolicyNo as varchar),len(cast(p.PolicyNo as varchar))-1))
            else p.OldPolicyNo
        end as OldPolicyNo,
        '' as OldPolicyType,
        cast('' as varchar(5)) as OldProductCode,
        cast('' as varchar(6)) as OldPlanCode
    from
        [db-au-stage].dbo.etl_Policy p
    where
        p.PolicyType = 'R'


    --update the cancelled policies that may have been created within the etl date range
    --with actual oldpolicytype, oldproductcode, and oldplancode
    update [db-au-stage].dbo.etl_PolicyOld
    set
        OldPolicyType = p.PolicyType,
        OldProductCode = p.ProductCode,
        OldPlanCode = p.PlanCode
    from
        [db-au-stage].dbo.etl_PolicyOld t
        join [db-au-stage].dbo.etl_Policy p on
            t.CountryKey = p.CountryKey and
            t.OldPolicyNo = p.PolicyNo

    --update the cancelled policies that may have been created outside the etl date range
    --with actual oldpolicytype, oldproductcode, and oldplancode
    update [db-au-stage].dbo.etl_PolicyOld
    set
        OldPolicyType = p.PolicyType,
        OldProductCode = p.ProductCode,
        OldPlanCode = p.PlanCode
    from
        [db-au-stage].dbo.etl_PolicyOld t
        join [db-au-cmdwh].dbo.Policy p on
            t.CountryKey = p.CountryKey and
            t.OldPolicyNo = p.PolicyNo

    --update cancelled policies with the correct oldpolicytype, oldproductcode, and oldplancode
    update [db-au-cmdwh].dbo.Policy
    set
        OldPolicyNo = t.OldPolicyNo,
        OldPolicyType = t.OldPolicyType,
        OldProductCode = t.OldProductCode,
        OldPlanCode = t.OldPlanCode
    from
        [db-au-cmdwh].dbo.Policy p
        join [db-au-stage].dbo.etl_PolicyOld t on
            p.CountryKey = t.CountryKey and
            p.PolicyNo = t.PolicyNo and
            p.OldPolicyNo <> 0

end

GO

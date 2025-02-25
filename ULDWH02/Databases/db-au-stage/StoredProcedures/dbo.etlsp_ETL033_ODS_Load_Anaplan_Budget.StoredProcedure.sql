USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL033_ODS_Load_Anaplan_Budget]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL033_ODS_Load_Anaplan_Budget]
as
begin

    --------------------------------------------------------------------- Premium (4700)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = '4700' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            isnull([subChannel_RevenueModelling: Code], 99) Channel,
            [subProduct_Revenue Modelling: Code] Product,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Premium-GL4700$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '4700' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        t.Channel ChannelCode,
        '' DepartmentCode,
        t.Product ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r
    ;

    --------------------------------------------------------------------- Assistance (4470,4740,4741)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = '4740' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            isnull([subChannel_RevenueModelling: Code], 99) Channel,
            [subProduct_Revenue Modelling: Code] Product,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Assistance-GL4470,4740 & 4741$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '4740' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        t.Channel ChannelCode,
        '' DepartmentCode,
        isnull(t.Product, '') ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r

    ;
    --------------------------------------------------------------------- Distributor Recovery (4730)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = '4730' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Distributor Recovery-GL4730$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '4730' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        '' DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r

    ;
    --------------------------------------------------------------------- Ancillary Income (4450)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = '4450' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Ancillary Income-GL4450&Dept51$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '4450' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        '51' DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r

    ;
    --------------------------------------------------------------------- Other Revenue (4600,4401,4100)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = '4100' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Other Revenue-GL4600,4401,4100$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '4100' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        '' DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r

    ;
    --------------------------------------------------------------------- Commission (5200)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = '5200' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            isnull([subChannel_RevenueModelling: Code], 99) Channel,
            [subProduct_Revenue Modelling: Code] Product,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Commission-GL5200$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '5200' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        t.Channel ChannelCode,
        '' DepartmentCode,
        t.Product ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r

    ;
    --------------------------------------------------------------------- Acquisition Cost (4103)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = '4103' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Acquisition Cost-4103 etc$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '4103' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        '' DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r

    ;
    --------------------------------------------------------------------- Medical assistance (5340, 5310)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode in ('5340', '5310') and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            case
                when charindex(' -', [#BU to JV: JV List]) > 0 then left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) 
                else ''
            end JVCode,
            [#BU to JV: BU Code] BU,
            isnull([subChannel_RevenueModelling: Code], 99) Channel,
            [subProduct_Revenue Modelling: Code] Product,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Medical assistance-GL5340 &5310$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '5340' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        t.Channel ChannelCode,
        '' DepartmentCode,
        t.Product ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r
    where
        t.Product is not null

    union all

    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '5310' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        '' DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r
    where
        t.Product is null and
        t.BU is not null
    ;
    --------------------------------------------------------------------- Claim Expenses (5320, 5300)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode in ('5320') and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            isnull([subChannel_RevenueModelling: Code], 99) Channel,
            [subProduct_Revenue Modelling: Code] Product,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Claim Expenses-GL5320&5300$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '5320' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        t.Channel ChannelCode,
        '' DepartmentCode,
        t.Product ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r
    ;
    --------------------------------------------------------------------- UW Margin (5330)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode in ('5330') and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [UW Margin-GL5330$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '5330' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        '' DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r
    ;

    --------------------------------------------------------------------- Profit Share (4300)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode in ('4300') and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            left([#BU to JV: JV List], charindex(' -', [#BU to JV: JV List]) - 1) JVCode,
            [#BU to JV: BU Code] BU,
            [Jan-18],
            [Feb-18],
            [Mar-18],
            [Apr-18],
            [May-18],
            [Jun-18],
            [Jul-18],
            [Aug-18],
            [Sep-18],
            [Oct-18],
            [Nov-18],
            [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Profit share - GL4300$A2:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        '4300' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        t.GLAmount,
        t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        '' DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r
    ;

    --------------------------------------------------------------------- Emp & Other & Variable Ind Expenses
    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode in 
        (
            select 
                AccountCode
            from
                [db-au-cmdwh]..glAccounts
            where
                AccountCategory = 'Expense'
        ) and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            [F1] BU,
            convert(varchar, [F2]) Department,
            convert(varchar, [F3]) JVCode,
            convert(varchar, [F4]) StateCode,
            convert(varchar, [F6]) AccountCode,
            [F8] [Jan-18],
            [F9] [Feb-18],
            [F10] [Mar-18],
            [F11] [Apr-18],
            [F12] [May-18],
            [F13] [Jun-18],
            [F14] [Jul-18],
            [F15] [Aug-18],
            [F16] [Sep-18],
            [F17] [Oct-18],
            [F18] [Nov-18],
            [F19] [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=NO;IMEX=1;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Emp&Other&Variable Ind Expenses$A2:U40000]
                '
            )
        where
            [F1] not in ('sPlan BU Dept JV State: BU Code', 'Month') and
            [F7] <> ''

        union all

        select 
            [F1] BU,
            convert(varchar, [F2]) Department,
            convert(varchar, [F3]) JVCode,
            convert(varchar, [F4]) StateCode,
            convert(varchar, [F6]) AccountCode,
            [F8] [Jan-18],
            [F9] [Feb-18],
            [F10] [Mar-18],
            [F11] [Apr-18],
            [F12] [May-18],
            [F13] [Jun-18],
            [F14] [Jul-18],
            [F15] [Aug-18],
            [F16] [Sep-18],
            [F17] [Oct-18],
            [F18] [Nov-18],
            [F19] [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=NO;IMEX=1;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Emp&Other&Variable split$A2:U40000]
                '
            )
        where
            [F1] not in ('#BU Department JV to State: BU Code', 'sPlan BU Dept JV State: BU Code', 'Month') and
            [F7] <> ''

        union all

        select 
            [F1] BU,
            convert(varchar, [F2]) Department,
            convert(varchar, [F3]) JVCode,
            convert(varchar, [F4]) StateCode,
            convert(varchar, [F6]) AccountCode,
            [F8] [Jan-18],
            [F9] [Feb-18],
            [F10] [Mar-18],
            [F11] [Apr-18],
            [F12] [May-18],
            [F13] [Jun-18],
            [F14] [Jul-18],
            [F15] [Aug-18],
            [F16] [Sep-18],
            [F17] [Oct-18],
            [F18] [Nov-18],
            [F19] [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=NO;IMEX=1;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [CCA&DTC&ETC split$A2:U40000]
                '
            )
        where
            [F1] not in ('sPlanAllocMonths: Time Period') and
            [F7] <> ''

        union all

        select 
            [F1] BU,
            convert(varchar, [F2]) Department,
            convert(varchar, [F3]) JVCode,
            convert(varchar, [F4]) StateCode,
            convert(varchar, [F6]) AccountCode,
            [F8] [Jan-18],
            [F9] [Feb-18],
            [F10] [Mar-18],
            [F11] [Apr-18],
            [F12] [May-18],
            [F13] [Jun-18],
            [F14] [Jul-18],
            [F15] [Aug-18],
            [F16] [Sep-18],
            [F17] [Oct-18],
            [F18] [Nov-18],
            [F19] [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=NO;IMEX=1;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Entity allocation Data$A2:U40000]
                '
            )
        where
            [F1] not in ('sPlanAllocMonths: Time Period') and
            [F7] <> ''

        union all

        select 
            [F1] BU,
            convert(varchar, [F2]) Department,
            convert(varchar, [F3]) JVCode,
            convert(varchar, [F4]) StateCode,
            convert(varchar, [F6]) AccountCode,
            [F8] [Jan-18],
            [F11] [Feb-18],
            [F14] [Mar-18],
            [F17] [Apr-18],
            [F20] [May-18],
            [F23] [Jun-18],
            [F26] [Jul-18],
            [F29] [Aug-18],
            [F32] [Sep-18],
            [F35] [Oct-18],
            [F38] [Nov-18],
            [F41] [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=NO;IMEX=1;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [Entity allocation Data-CMA$A2:AZ40000]
                '
            )
        where
            [F1] not in ('sPlanAllocMonths: Time Period', '#BU Department JV to State: BU Code') and
            [F7] <> ''
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        t.AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        round(t.GLAmount, 6) GLAmount,
        round(t.GLAmount, 6) OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        t.Department DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        t.StateCode StateCode,
        '' ClientCode,
        '' SourceCode,
        t.JVCode JointVentureCode,
        'G99' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r


    ;

    --------------------------------------------------------------------- FTE (M0003)

    --select *
    delete
    from
        [db-au-cmdwh]..glTransactions
    where
        ScenarioCode = 'B' and
        Period between 2018007 and 2019006 and
        AccountCode = 'M0003' and
        TransactionReference = 'Anaplan budget'

    ;with 
    cte_raw as
    (
        select 
            [BU] BU,
            Dept [Department],
            convert(decimal(10,2), [Jan-18]) [Jan-18],
            convert(decimal(10,2), [Feb-18]) [Feb-18],
            convert(decimal(10,2), [Mar-18]) [Mar-18],
            convert(decimal(10,2), [Apr-18]) [Apr-18],
            convert(decimal(10,2), [May-18]) [May-18],
            convert(decimal(10,2), [Jun-18]) [Jun-18],
            convert(decimal(10,2), [Jul-18]) [Jul-18],
            convert(decimal(10,2), [Aug-18]) [Aug-18],
            convert(decimal(10,2), [Sep-18]) [Sep-18],
            convert(decimal(10,2), [Oct-18]) [Oct-18],
            convert(decimal(10,2), [Nov-18]) [Nov-18],
            convert(decimal(10,2), [Dec-18]) [Dec-18]
        from 
            openrowset
            (
                'Microsoft.ACE.OLEDB.12.0',
                'Excel 12.0 Xml;HDR=YES;Database=E:\ETL\Data\CMG Budget - CY18.xls',
                '
                select 
                    *
                from 
                    [FTE$A1:U10000]
                '
            )
    ),
    cte_up as
    (
        select 
            *
        from
            cte_raw

        unpivot 

        (
            [GLAmount] for [Month] in 
            (
                [Jan-18],
                [Feb-18],
                [Mar-18],
                [Apr-18],
                [May-18],
                [Jun-18],
                [Jul-18],
                [Aug-18],
                [Sep-18],
                [Oct-18],
                [Nov-18],
                [Dec-18]
            )
        ) u
    )
    insert into [db-au-cmdwh]..glTransactions
    (
        BusinessUnit,
        ScenarioCode,
        AccountCode,
        Period,
        JournalNo,
        JournalLine,
        JournalType,
        JournalSource,
        TransactionDate,
        EntryDate,
        DueDate,
        PostingDate,
        OriginatedDate,
        AfterPostingDate,
        BaseRate,
        ConversionRate,
        ReversalFlag,
        GLAmount,
        OtherAmount,
        ReportAmount,
        DebitCreditFlag,
        AllocationFlag,
        TransactionReference,
        Description,
        ChannelCode,
        DepartmentCode,
        ProductCode,
        BDMCode,
        ProjectCode,
        StateCode,
        ClientCode,
        SourceCode,
        JointVentureCode,
        GSTCode,
        CaseNumber,
        CreateBatchID
    )
    select 
        t.BU BusinessUnit,
        'B' ScenarioCode,
        'M0003' AccountCode,
        r.SUNPeriod Period,
        '' JournalNo,
        '' JournalLine,
        '' JournalType,
        '' JournalSource,
        r.[Date] TransactionDate,
        getdate() EntryDate,
        getdate() DueDate,
        getdate() PostingDate,
        r.[Date] OriginatedDate,
        null AfterPostingDate,
        1 BaseRate,
        1 ConversionRate,
        'N' ReversalFlag,
        -t.GLAmount,
        -t.GLAmount OtherAmount,
        0 ReportAmount,
        'C' DebitCreditFlag,
        '' AllocationFlag,
        'Anaplan budget' TransactionReference,
        'Anaplan budget' Description,
        '' ChannelCode,
        t.Department DepartmentCode,
        '' ProductCode,
        '' BDMCode,
        '' ProjectCode,
        '' StateCode,
        '' ClientCode,
        '' SourceCode,
        '11' JointVentureCode,
        '' GSTCode,
        '' CaseNumber,
        -999 CreateBatchID
    from
        cte_up t
        cross apply
        (
            select top 1
                d.[Date],
                d.SUNPeriod
            from
                [db-au-cmdwh]..Calendar d
            where
                d.[Date] = convert(date, '01-' + t.[Month])
        ) r
    ;

end
GO

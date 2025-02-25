USE [db-au-workspace]
GO
/****** Object:  View [dbo].[RPT0752]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[RPT0752]
as
select * 
from 
    openrowset
    (
        'SQLNCLI', 
        'server=localhost;Trusted_Connection=yes',
        '
        set fmtonly off 
        exec [db-au-cmdwh].dbo.rptsp_rpt0752
        with result sets
        (
            (
                [Country] varchar(2),
                [SuperGroupName] nvarchar(25),
                [GroupCode] nvarchar(50),
                [GroupName] nvarchar(50),
                [SubGroupCode] nvarchar(50),
                [SubGroupName] nvarchar(50),
                [OutletName] nvarchar(50),
                [AlphaCode] nvarchar(20),
                [SalesChannel] nvarchar(50),
                [Date] date,
                [SellPrice] money,
                [PolicyCount] int,
                [Commission] money,
                [NetPrice] money,
                [QuoteCount] int,
                [StartDate] datetime,
                [EndDate] datetime
            )
        )
        '
    )
GO

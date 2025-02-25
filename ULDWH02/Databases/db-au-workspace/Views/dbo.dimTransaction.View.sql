USE [db-au-workspace]
GO
/****** Object:  View [dbo].[dimTransaction]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[dimTransaction] as
select 
    [Transaction],
    TransactionType,
    TransactionStatus
from
    fActuarialClaimPayment

union

select
    [Transaction],
    TransactionType,
    TransactionStatus
from
    fActuarialClaimEstimate
GO

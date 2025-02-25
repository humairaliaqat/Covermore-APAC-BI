USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vPenPolicyLuggage]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vPenPolicyLuggage]
as
select
    ptt.PolicyTransactionKey,
    pta.AddOnText Item,
    pta.CoverIncrease
from 
    penPolicyTravellerTransaction ptt
    inner join penPolicyTravellerAddOn pta on
        pta.PolicyTravellerTransactionKey = ptt.PolicyTravellerTransactionKey
where AddOnGroup = 'Luggage'
GO

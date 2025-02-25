USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vrssProductReview]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE view [dbo].[vrssProductReview] as
select top 50
    ReviewID,
    ReviewTopic,
    replace(ReviewDescription, ' Read More', '') ReviewDescription,
    ReviewDate,
    CustomerRating,
    UserLink,
    Label,
    PostContents,
    case
        when PostContents like '%Cover-More Official%' then 'Yes'
        else 'No'
    end Responded
from
    --bhdwh02.[db-au-cmdwh].dbo.web_ProductReview 
    [db-au-cmdwh].dbo.web_ProductReview 
--where
--    CustomerRating <= 3
order by
    ReviewDate desc








GO

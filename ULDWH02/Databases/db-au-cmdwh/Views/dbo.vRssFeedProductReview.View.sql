USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vRssFeedProductReview]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vRssFeedProductReview] as
select
    '<?xml version="1.0" encoding="utf-8" ?>' +
    (
        select
            '2.0' as '@version',
            (
                select
                    'Product Review' as title,
                    '' as link,
                    '' as description,
                    left(datename(dw, getdate()),3) + ', ' + stuff(convert(nvarchar, getdate(), 113), 21, 4,' AEST') as lastBuildDate,
                    '' as ttl,
                    (
                        select 
                            '[' + isnull(Label, 'General') + '] ' + ReviewTopic + ' (' + case when Responded = 'Yes' then 'Responded' else 'Not Responded' end + ')'  as title,
                            UserLink as link,
                            isnull(Label, 'General') as category,
                            left(ReviewDescription, 450) as description,
                            'http://bi.covermore.com/Dashboard/Claims/' + convert(varchar, isnull(CustomerRating, 1)) + '.jpg' as 'enclosure/@url',
                            'image/jpg' as 'enclosure/@type',
                            '' as enclosure,
                            'true' as 'guid/@isPermaLink',
                            ReviewID as guid,
                            left(datename(dw, ReviewDate),3) + ', ' + stuff(convert(nvarchar, ReviewDate, 113), 21, 4,' AEST') as pubDate
                        from 
                            vrssProductReview feed
                        for xml path('item'), type
                    )
                for xml path('channel'), type
            )
        for xml path('rss') 
    ) FeedXML

GO

USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vpenOutletJV_20241126test]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vpenOutletJV_20241126test]     
as    
   
select     
    OutletKey,    
    isnull(do.Distributor, 'Unknown') DistributionType,    
    coalesce(djv.JVCode, o.JVCode, 'Unknown') JVCode,    
    coalesce(djv.JVDescription, o.JV, 'Unknown') JVDescription,    
    isnull(djv.JVDistributionType, 'Unknown') JVDistributionType,    
    isnull(djv.JVCategory, 'Unknown') JVCategory,    
    coalesce(do.Channel, o.Channel, 'Unknown') Channel,    
    case    
        when djv.JVCode is null then 0    
        else 1    
    end MappedFlag    
from    
    penOutlet_20241128test o    
    outer apply    
    (    
        select top 1    
            case    
                when rtrim(do.Distributor) = '' then null    
                else do.Distributor    
            end Distributor,    
            case    
                when rtrim(do.Channel) = '' then null    
                else do.Channel    
            end Channel,    
            case    
                when rtrim(do.JV) = '' then null    
                else do.JV    
            end JV    
        from    
            [db-au-star]..dimOutlet do    
        where    
            do.OutletKey = o.OutletKey and    
            do.isLatest = 'Y'    
        order by    
            do.OutletSK desc    
    ) do    
    outer apply    
    (    
        select top 1    
            jv.Joint_Venture_Code JVCode,    
            jv.Joint_Venture_Desc JVDescription,    
            jv.Distribution_Type_Desc JVDistributionType,    
            jv.Joint_Venture_Category_Desc JVCategory    
        from    
            [db-au-star]..Dim_Joint_Venture jv     
        where    
            jv.Joint_Venture_Code = do.JV    
    ) djv    
where    
    OutletStatus = 'Current' 
GO

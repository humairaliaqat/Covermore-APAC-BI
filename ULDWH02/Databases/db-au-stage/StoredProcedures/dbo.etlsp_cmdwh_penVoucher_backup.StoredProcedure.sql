USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penVoucher_backup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
          
          
CREATE procedure [dbo].[etlsp_cmdwh_penVoucher_backup]              
as              
begin              
/************************************************************************************************************************************              
Author:         Siddhesh Shinde              
Date:           20241211              
Prerequisite:       
Description:    Script to store data in voucher data in penVoucher    
Change History: CHG0040192             
*************************************************************************************************************************************/              
              
    set nocount on              
              
    if object_id('etl_penVoucher') is not null              
        drop table etl_penVoucher              
        
 select               
 d.DomainId,        
 Name 'Partner',        
 IssueDate 'CreatedDate',        
 vt.PolicyNumber,      
 tv.VoucherCode 'VoucherNumber',        
 tv.VoucherAmount 'Amount',        
 tv.StartDate 'StartDate',         
 tv.EndDate 'ExpiryDate',         
 tv.VoucherStatus 'Status',         
 vt.RedeemAmount 'RedemptionValue',         
 vt.RedemptionDate 'RedemptionDate',         
 tv.VoucherType 'VoucherType'         
 into etl_penVoucher        
 from penguin_tblVouchers_autp tv         
 outer apply (select PolicyNumber,RedeemAmount,RedemptionDate from penguin_tblVoucherTransactions_autp tvt where tvt.VoucherID = tv.VoucherID) vt        
 outer apply (select Name from penguin_tblGroup_autp where ID = tv.GroupID ) g        
 outer apply (select * from penguin_tblDomain_autp where DomainID = tv.DomainID ) d        
        
    create index idx_etl_penVoucher_VoucherNumber on etl_penVoucher(VoucherNumber)              
              
              
    --create Voucher table if not already created              
    if object_id('[db-au-cmdwh].dbo.penVoucher') is null              
    begin              
              
        create table [db-au-cmdwh].dbo.[penVoucher]              
        (              
  [DomainId] [int] NULL,        
 [Partner] [nvarchar](50) NULL,        
 [CreatedDate] [datetime] NOT NULL,        
 [PolicyNumber] [nvarchar](25) NULL,        
 [VoucherNumber] [nvarchar](20) NOT NULL,        
 [Amount] [money] NOT NULL,        
 [StartDate] [datetime] NOT NULL,        
 [ExpiryDate] [datetime] NOT NULL,        
 [Status] [nvarchar](20) NOT NULL,        
 [RedemptionValue] [money] NULL,        
 [RedemptionDate] [datetime] NULL,        
 [VoucherType] [nvarchar](20) NOT NULL        
        )              
              
    end              
       
   ---- Delete duplicate records     
    delete a          
        from          
            [db-au-cmdwh]..penVoucher a          
            inner join etl_penVoucher b on          
                b.VoucherNumber COLLATE DATABASE_DEFAULT = a.VoucherNumber COLLATE DATABASE_DEFAULT    
    and b.CreatedDate = a.CreatedDate    
    and isnull(b.RedemptionDate,0) = isnull(b.RedemptionDate,0)        
           
    --insert new/modified voucher              
    insert into [db-au-cmdwh].dbo.penVoucher with (tablockx)              
    (              
        [DomainId],        
 [Partner],        
 [CreatedDate],       
 [PolicyNumber],       
 [VoucherNumber],        
 [Amount],        
 [StartDate],        
 [ExpiryDate],        
 [Status],        
 [RedemptionValue],        
 [RedemptionDate],        
 [VoucherType]        
    )              
    select              
        [DomainId],        
 [Partner],        
 [CreatedDate],      
 [PolicyNumber],        
 [VoucherNumber],        
 [Amount],        
 [StartDate],        
 [ExpiryDate],        
 [Status],        
 [RedemptionValue],        
 [RedemptionDate],        
 [VoucherType]        
    from              
        etl_penVoucher        
              
end     
GO

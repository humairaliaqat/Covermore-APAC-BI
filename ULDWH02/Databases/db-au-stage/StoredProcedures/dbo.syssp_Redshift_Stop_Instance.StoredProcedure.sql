USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[syssp_Redshift_Stop_Instance]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[syssp_Redshift_Stop_Instance]
as



/************************************************************************************************************************************
Author:         Linus Tor
Date:           20160704
Prerequisite:   Requires AWSCLI installed and configured correctly on ULDWH01;
				Requires Redshift Cluster is running;
				Requires 
Description:    This stored proc checks if Cluster is running or not. If it is running, then shutdown Redshift cluster with a Finalsnapshot
Change History:
                20160704 - LT - Procedure created
 
*************************************************************************************************************************************/

declare @SQL varchar(8000)

if object_id('tempdb..##redshift_snapshot_check') is not null drop table ##redshift_snapshot_check
create table ##redshift_snapshot_check (ClusterDescription varchar(8000) null)

if object_id('tempdb..##redshift_cluster_check') is not null drop table ##redshift_cluster_check
create table ##redshift_cluster_check (ClusterDescription varchar(8000) null)

select @SQL = 'master..xp_cmdshell ''"c:\program files\amazon\awscli\aws.exe" redshift describe-cluster-snapshots --output text'''

insert ##redshift_snapshot_check
exec(@SQL)

select @SQL = 'master..xp_cmdshell ''"c:\program files\amazon\awscli\aws.exe" redshift describe-clusters --output text'''

insert ##redshift_cluster_check
exec(@SQL)


if (select top 1 * from ##redshift_cluster_check) is null																				--cluster is not active, abort!
	raiserror('Cluster is not active. Cannot delete and shutdown cluster',20,-1) with log
else if (select top 1 * from ##redshift_snapshot_check where ClusterDescription like '%prod-finalsnapshot%') is not null
	 begin																																--finalsnapshot exists, delete it
		select @SQL = 'master..xp_cmdshell ''"c:\program files\amazon\awscli\aws.exe" redshift delete-cluster-snapshot --snapshot-identifier cmdwh-prod-finalsnapshot'''
		exec(@SQL)		

		--delete cluster and take a final snapshot
		select @SQL = 'master..xp_cmdshell ''"c:\program files\amazon\awscli\aws.exe" redshift delete-cluster --cluster-identifier cmdwh-redshift-prod --final-cluster-snapshot-identifier cmdwh-prod-finalsnapshot'''
		exec(@SQL)
	 end
	else
		raiserror('Final Snapshot not found. Nothing to delete',20,-1) with log

--drop temp table
drop table ##redshift_cluster_check
drop table ##redshift_snapshot_check

GO

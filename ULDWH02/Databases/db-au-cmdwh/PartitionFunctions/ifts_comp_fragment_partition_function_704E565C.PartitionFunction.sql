USE [db-au-cmdwh]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_704E565C]    Script Date: 24/02/2025 12:39:33 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_704E565C](varbinary(128)) AS RANGE LEFT FOR VALUES (0x003800320037003600330030, 0x006E006E0032003900350035003900380033)
GO

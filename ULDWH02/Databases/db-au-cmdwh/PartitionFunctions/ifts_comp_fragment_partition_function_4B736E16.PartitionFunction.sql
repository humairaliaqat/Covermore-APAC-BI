USE [db-au-cmdwh]
GO
/****** Object:  PartitionFunction [ifts_comp_fragment_partition_function_4B736E16]    Script Date: 24/02/2025 12:39:33 PM ******/
CREATE PARTITION FUNCTION [ifts_comp_fragment_partition_function_4B736E16](varbinary(128)) AS RANGE LEFT FOR VALUES (0x00360031003400310033003500350034003400390037, 0x0061006C006500780067006F0072006D0061006E0062006D007800400067006D00610069006C002E0063006F006D, 0x006E006E00310031, 0x006E006E00360031003400350031003700390035003500360039)
GO

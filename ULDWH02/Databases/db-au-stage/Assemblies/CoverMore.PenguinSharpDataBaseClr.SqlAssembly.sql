USE [db-au-stage]
GO
/****** Object:  SqlAssembly [CoverMore.PenguinSharpDataBaseClr]    Script Date: 24/02/2025 5:08:02 PM ******/
CREATE ASSEMBLY [CoverMore.PenguinSharpDataBaseClr]
FROM 0x4D5A90000300000004000000FFFF0000B800000000000000400000000000000000000000000000000000000000000000000000000000000000000000800000000E1FBA0E00B409CD21B8014CCD21546869732070726F6772616D2063616E6E6F742062652072756E20696E20444F53206D6F64652E0D0D0A2400000000000000504500004C0103007C507F500000000000000000E00002210B0108000010000000060000000000009E2F000000200000004000000000400000200000000200000400000000000000040000000000000000800000000200000B490000030040850000100000100000000010000010000000000000100000000000000000000000442F00005700000000400000F803000000000000000000000000000000000000006000000C00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000080000000000000000000000082000004800000000000000000000002E74657874000000A40F0000002000000010000000020000000000000000000000000000200000602E72737263000000F8030000004000000004000000120000000000000000000000000000400000402E72656C6F6300000C0000000060000000020000001600000000000000000000000000004000004200000000000000000000000000000000802F00000000000048000000020005001026000034090000090000000000000000000000000000005020000080000000000000000000000000000000000000000000000000000000000000000000000025FBC2AC9B962F677459E0145139A382D2442AB488C62C450A72104E1182E86C111D7C69C71E899633BB0C92AA257774324020014A43826211DBABAA05E1B60A877A9635445EA5DA3B9FFE018A7A137860B1C47762CE8B020E54F577DA83BBC9EF48754B156EEDFD1D4C97EBED0AADB517CCEB93A31183EAEBB40F795B8FF9431B300900C50000000100001112000F00280E00000A13051205280F00000A0F00280E00000A13061206281000000A0F00280E00000A13071207281100000A0F00280E00000A13081208281200000A0F00280E00000A13091209281300000A0F00280E00000A130A120A281400000A0F00280E00000A130B120B281500000A18281600000A281700000A6F1800000A281900000A0B0F01FE16030000016F1A00000A281900000A0C06076F1B00000A086F1B00000A281C00000A0D09281D00000A1304DE0A267E1E00000A1304DE0011042A0000000110000000000000B8B8000A010000011B300900C00000000100001112000F00280E00000A13051205280F00000A0F00280E00000A13061206281000000A0F00280E00000A13071207281100000A0F00280E00000A13081208281200000A0F00280E00000A13091209281300000A0F00280E00000A130A120A281400000A0F00280E00000A130B120B281500000A17281600000A7201000070281900000A0B0F01FE16030000016F1A00000A281900000A0C06076F1B00000A086F1B00000A281C00000A0D09281D00000A1304DE0A267E1E00000A1304DE0011042A0110000000000000B3B3000A010000011B300900C50000000100001112000F00280E00000A13051205280F00000A0F00280E00000A13061206281000000A0F00280E00000A13071207281100000A0F00280E00000A13081208281200000A0F00280E00000A13091209281300000A0F00280E00000A130A120A281400000A0F00280E00000A130B120B281500000A16281600000A0F01FE16030000016F1A00000A281900000A0B281700000A6F1800000A281900000A0C06076F1B00000A086F1B00000A281C00000A0D09281D00000A1304DE0A267E1E00000A1304DE0011042A0000000110000000000000B8B8000A010000011B300900C00000000100001112000F00280E00000A13051205280F00000A0F00280E00000A13061206281000000A0F00280E00000A13071207281100000A0F00280E00000A13081208281200000A0F00280E00000A13091209281300000A0F00280E00000A130A120A281400000A0F00280E00000A130B120B281500000A16281600000A0F01FE16030000016F1A00000A281900000A0B7201000070281900000A0C06076F1B00000A086F1B00000A281C00000A0D09281D00000A1304DE0A267E1E00000A1304DE0011042A0110000000000000B3B3000A010000011B300900BD0000000100001112000F00280E00000A13051205280F00000A0F00280E00000A13061206281000000A0F00280E00000A13071207281100000A0F00280E00000A13081208281200000A0F00280E00000A13091209281300000A0F00280E00000A130A120A281400000A0F00280E00000A130B120B281500000A18281600000A281700000A6F1800000A281900000A0B7201000070281900000A0C06076F1B00000A086F1B00000A281C00000A0D09281D00000A1304DE0A267E1E00000A1304DE0011042A0000000110000000000000B0B0000A010000011B300900BD0000000100001112000F00280E00000A13051205280F00000A0F00280E00000A13061206281000000A0F00280E00000A13071207281100000A0F00280E00000A13081208281200000A0F00280E00000A13091209281300000A0F00280E00000A130A120A281400000A0F00280E00000A130B120B281500000A17281600000A7201000070281900000A0B281700000A6F1800000A281900000A0C06076F1B00000A086F1B00000A281C00000A0D09281D00000A1304DE0A267E1E00000A1304DE0011042A0000000110000000000000B0B0000A010000011E02281F00000A2A42534A4201000100000000000C00000076322E302E35303732370000000005006C000000EC020000237E0000580300002804000023537472696E677300000000800700000C000000235553008C0700001000000023475549440000009C0700009801000023426C6F620000000000000002000001471502000900000000FA253300160000010000001400000002000000070000000A0000001F0000001000000001000000010000000300000000000A00010000000000060055004E000A007D0068000A0089006800060050013E01060067013E01060084013E010600A3013E010600BC013E010600D5013E010600F0013E0106000B023E01060043022402060057023E010600900270020600B00270020A000B03F002060020034E0006007D034E0006008A034E000E00C4034E0000000000010000000000010001000100100030000000050001000100D02000000000960093000A000100B421000000009600A9000A0003009022000000009600BC000A0005007423000000009600D2000A0007005024000000009600E500130009002C25000000009600F90013000A0008260000000086180D011A000B00000001001301000002001C01000001001301000002001C01000001001301000002002D01000001001301000002002D0100000100130100000100130121000D011E0029000D011E0031000D011E0039000D011E0041000D011E0049000D011E0051000D011E0059000D011E0061000D01230069000D011E0071000D01280079000D011A0081000D011A0011002903D40089003303D90089003C03D90089004603D90089004E03D90089005703D90089006203D90089006D03D90089000D01DD0099009303EA009900A703EF00A100D103F3000900E803EF00A100F103EF00A100F803F90011001604020111002204090109000D011A0020006B00CF002E0013004F012E001B004F012E0023004F012E00630076012E000B0028012E00330055012E005B006D012E002B0028012E003B004F012E004B004F0140006B00CF0060006B00CF0080006B00CF00A0006B00CF00C0006B00CF000D01048000000100000042125652010000002D00CE020000020000000000000000000000010045000000000002000000000000000000000001005C00000000000300050000000000000000000100B803000000000000003C4D6F64756C653E00436F7665724D6F72652E50656E6775696E53686172704461746142617365436C722E646C6C0055736572446566696E656446756E6374696F6E73006D73636F726C69620053797374656D004F626A6563740053797374656D2E446174610053797374656D2E446174612E53716C54797065730053716C4461746554696D650053716C537472696E6700536572766572546F4C6F63616C54696D655A6F6E6500557463546F4C6F63616C54696D655A6F6E65004C6F63616C546F53657276657254696D655A6F6E65004C6F63616C546F55746354696D655A6F6E6500536572766572546F55746354696D655A6F6E6500557463546F53657276657254696D655A6F6E65002E63746F72006461746554696D650074617267657454696D655A6F6E65496400736F7572636554696D655A6F6E6549640053797374656D2E5265666C656374696F6E00417373656D626C795469746C6541747472696275746500417373656D626C794465736372697074696F6E41747472696275746500417373656D626C79436F6E66696775726174696F6E41747472696275746500417373656D626C79436F6D70616E7941747472696275746500417373656D626C7950726F6475637441747472696275746500417373656D626C79436F7079726967687441747472696275746500417373656D626C7954726164656D61726B41747472696275746500417373656D626C7943756C747572654174747269627574650053797374656D2E52756E74696D652E496E7465726F70536572766963657300436F6D56697369626C6541747472696275746500417373656D626C7956657273696F6E4174747269627574650053797374656D2E52756E74696D652E436F6D70696C6572536572766963657300436F6D70696C6174696F6E52656C61786174696F6E734174747269627574650052756E74696D65436F6D7061746962696C69747941747472696275746500436F7665724D6F72652E50656E6775696E53686172704461746142617365436C72004D6963726F736F66742E53716C5365727665722E5365727665720053716C46756E6374696F6E417474726962757465004461746554696D65006765745F56616C7565006765745F59656172006765745F4D6F6E7468006765745F446179006765745F486F7572006765745F4D696E757465006765745F5365636F6E64006765745F4D696C6C697365636F6E64004461746554696D654B696E640054696D655A6F6E65006765745F43757272656E7454696D655A6F6E65006765745F5374616E646172644E616D650053797374656D2E436F72650054696D655A6F6E65496E666F0046696E6453797374656D54696D655A6F6E654279496400546F537472696E67006765745F496400436F6E7665727454696D65427953797374656D54696D655A6F6E654964006F705F496D706C69636974004E756C6C00000007550054004300000000004EDABE1747BAEF4F9ED5055DD8E54B7F0008B77A5C561934E08908000211091109110D0600011109110903200001042001010E0420010102042001010880A00024000004800000940000000602000000240000525341310004000001000100796B16A2251FC3DA36D9B11C17C79139DC3229FFF95A9EDF07CFF01AD1349DB606C002316C1807109649EB36F01146CDA06C190FA7ACDB4C415804B495CCE92A75ADEEF6B63A5419EDCBD89F2D84488D2D09B1F08BAA14185BC63BBAEB3FA3F19530B307F739B1DB365F35B5208BF93AFFB500AB7AD328348FF9165C276556C904010000000420001145032000080C200801080808080808081149040000124D0320000E05000112510E080003114511450E0E06000111091145030611091A070C11451251125111451109114511451145114511451145114526010021436F7665724D6F72652E50656E6775696E53686172704461746142617365436C72000005010000000017010012436F7079726967687420C2A920203230313200000801000800000000001E01000100540216577261704E6F6E457863657074696F6E5468726F7773010000006C2F000000000000000000008E2F0000002000000000000000000000000000000000000000000000802F00000000000000000000000000000000000000005F436F72446C6C4D61696E006D73636F7265652E646C6C0000000000FF2500204000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100100000001800008000000000000000000000000000000100010000003000008000000000000000000000000000000100000000004800000058400000A00300000000000000000000A00334000000560053005F00560045005200530049004F004E005F0049004E0046004F0000000000BD04EFFE00000100000001005652421200000100565242123F000000000000000400000002000000000000000000000000000000440000000100560061007200460069006C00650049006E0066006F00000000002400040000005400720061006E0073006C006100740069006F006E00000000000000B00400030000010053007400720069006E006700460069006C00650049006E0066006F000000DC02000001003000300030003000300034006200300000006C0022000100460069006C0065004400650073006300720069007000740069006F006E000000000043006F007600650072004D006F00720065002E00500065006E006700750069006E00530068006100720070004400610074006100420061007300650043006C007200000040000F000100460069006C006500560065007200730069006F006E000000000031002E0030002E0034003600370034002E0032003100300037003800000000006C002600010049006E007400650072006E0061006C004E0061006D006500000043006F007600650072004D006F00720065002E00500065006E006700750069006E00530068006100720070004400610074006100420061007300650043006C0072002E0064006C006C0000004800120001004C006500670061006C0043006F007000790072006900670068007400000043006F0070007900720069006700680074002000A90020002000320030003100320000007400260001004F0072006900670069006E0061006C00460069006C0065006E0061006D006500000043006F007600650072004D006F00720065002E00500065006E006700750069006E00530068006100720070004400610074006100420061007300650043006C0072002E0064006C006C000000640022000100500072006F0064007500630074004E0061006D0065000000000043006F007600650072004D006F00720065002E00500065006E006700750069006E00530068006100720070004400610074006100420061007300650043006C007200000044000F000100500072006F006400750063007400560065007200730069006F006E00000031002E0030002E0034003600370034002E00320031003000370038000000000048000F00010041007300730065006D0062006C0079002000560065007200730069006F006E00000031002E0030002E0034003600370034002E0032003100300037003800000000000000000000000000002000000C000000A03F00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
WITH PERMISSION_SET = UNSAFE
GO

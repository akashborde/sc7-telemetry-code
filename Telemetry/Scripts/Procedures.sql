SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_LoadReferenceTables]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sys_LoadReferenceTables]
GO

CREATE PROCEDURE sys_LoadReferenceTables
AS

    SET NOCOUNT ON
    
    /* Loads reference table data */
    
    /* Summary Types */
    DELETE FROM tblValidSummaryType
    
    INSERT INTO tblValidSummaryType (ID, SummaryType) VALUES (0, 'None')
    INSERT INTO tblValidSummaryType (ID, SummaryType) VALUES (1, 'Average')
    INSERT INTO tblValidSummaryType (ID, SummaryType) VALUES (2, 'Minimum')
    INSERT INTO tblValidSummaryType (ID, SummaryType) VALUES (3, 'Maximum')
   
    /* Data Types */
    
    DELETE FROM tblValidDataType
    
    INSERT INTO tblValidDataType (ID, DataType) VALUES (1, 'System.Int16')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (2, 'System.Int32')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (3, 'System.Double')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (4, 'System.Decimal')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (5, 'System.DateTime')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (6, 'System.Float')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (7, 'System.UInt16')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (8, 'System.UInt32')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (9, 'System.UInt64')
    INSERT INTO tblValidDataType (ID, DataType) VALUES (10, 'System.Byte(8)')


GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sys_LoadDataItems]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[sys_LoadDataItems]
GO

CREATE PROCEDURE sys_LoadDataItems
AS

    /* Defines the data items used by the telemetry system */
    
DECLARE @type_none int,
        @type_average int,
        @type_minimum int,
        @type_maximum int,
        @datatype_Int16 int,
        @datatype_Int32 int,
        @datatype_Double int,
        @datatype_Decimal int,
        @datatype_DateTime int,
        @datatype_Float int,
        @datatype_UInt16 int,
        @datatype_UInt32 int,
        @datatype_UInt64 int,
        @datatype_Byte8 int,
        @chart_yes bit,
        @chart_no bit
        
    SET NOCOUNT ON
    
    DELETE FROM tblDataItems
    EXEC sys_LoadReferenceTables
    
    SELECT @chart_yes = 0, @chart_no = 1
    
    /* Lookup reference values */
    
    SELECT @type_none = ID FROM tblValidSummaryType WHERE SummaryType = 'None'
    SELECT @type_average = ID FROM tblValidSummaryType WHERE SummaryType = 'Average'
    SELECT @type_minimum = ID FROM tblValidSummaryType WHERE SummaryType = 'Minimum'
    SELECT @type_maximum = ID FROM tblValidSummaryType WHERE SummaryType = 'Maximum'
    
    SELECT @datatype_Int16 = ID FROM tblValidDataType WHERE DataType = 'System.Int16'
    SELECT @datatype_Int32 = ID FROM tblValidDataType WHERE DataType = 'System.Int32'
    SELECT @datatype_Double = ID FROM tblValidDataType WHERE DataType = 'System.Double'
    SELECT @datatype_Decimal = ID FROM tblValidDataType WHERE DataType = 'System.Decimal'
    SELECT @datatype_DateTime = ID FROM tblValidDataType WHERE DataType = 'System.DateTime'
    SELECT @datatype_Float = ID FROM tblValidDataType WHERE DataType = 'System.Float'
    SELECT @datatype_UInt16 = ID FROM tblValidDataType WHERE DataType = 'System.UInt16'
    SELECT @datatype_UInt32 = ID FROM tblValidDataType WHERE DataType = 'System.UInt32'
    SELECT @datatype_UInt64 = ID FROM tblValidDataType WHERE DataType = 'System.UInt64'
    SELECT @datatype_Byte8 = ID FROM tblValidDataType WHERE DataType = 'System.Byte(8)'
 
    /* Define data items */
    
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('RowNum', 'ROWN', NULL, @type_none, 'Row Number', '#,##0', @datatype_Int32, @chart_no, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TimeStamp', 'TS', NULL, @type_none, 'Time Stamp', 'T', @datatype_DateTime, @chart_no, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentMotor', 'CMOT', '501', @type_average, 'Motor Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Float)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentArray', 'CARR', 'CARR', @type_average, 'Array Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentBattery', 'CBAT', 'CBAT', @type_average, 'Battery Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageMax', 'VMAX', 'VMAX', @type_maximum, 'Maximum Battery Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageAvg', 'VAVG', 'VAVG', @type_average, 'Average Battery Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageMin', 'VMIN', 'VMIN', @type_minimum, 'Minimum Battery Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempMax', 'TMAX', 'TMAX', @type_maximum, 'Maximum Battery Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempAvg', 'TAVG', 'TAVG', @type_average, 'Average Battery Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempMin', 'TMIN', 'TMIN', @type_minimum, 'Minimum Battery Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell01', 'VC01', '602', @type_average, 'Cell 1 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell02', 'VC02', '602', @type_average, 'Cell 2 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell03', 'VC03', '602', @type_average, 'Cell 3 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell04', 'VC04', '602', @type_average, 'Cell 4 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell05', 'VC05', '603', @type_average, 'Cell 5 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell06', 'VC06', '603', @type_average, 'Cell 6 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell07', 'VC07', '603', @type_average, 'Cell 7 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell08', 'VC08', '603', @type_average, 'Cell 8 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell09', 'VC09', '605', @type_average, 'Cell 9 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell10', 'VC10', '605', @type_average, 'Cell 10 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell11', 'VC11', '605', @type_average, 'Cell 11 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell12', 'VC12', '605', @type_average, 'Cell 12 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell13', 'VC13', '606', @type_average, 'Cell 13 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell14', 'VC14', '606', @type_average, 'Cell 14 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell15', 'VC15', '606', @type_average, 'Cell 15 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell16', 'VC16', '606', @type_average, 'Cell 16 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell17', 'VC17', '608', @type_average, 'Cell 17 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell18', 'VC18', '608', @type_average, 'Cell 18 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell19', 'VC19', '608', @type_average, 'Cell 19 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell20', 'VC20', '608', @type_average, 'Cell 20 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell21', 'VC21', '609', @type_average, 'Cell 21 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell22', 'VC22', '609', @type_average, 'Cell 22 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell23', 'VC23', '609', @type_average, 'Cell 23 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell24', 'VC24', '609', @type_average, 'Cell 24 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell25', 'VC25', '60B', @type_average, 'Cell 25 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell26', 'VC26', '60B', @type_average, 'Cell 26 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell27', 'VC27', '60B', @type_average, 'Cell 27 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell28', 'VC28', '60B', @type_average, 'Cell 28 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell29', 'VC29', '60C', @type_average, 'Cell 29 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell30', 'VC30', '60C', @type_average, 'Cell 30 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 2, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell31', 'VC31', '60C', @type_average, 'Cell 31 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Int16)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageCell32', 'VC32', '60C', @type_average, 'Cell 32 Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 6, @datatype_Int16)
     INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell01', 'TC01', 'TC01', @type_average, 'Cell 1 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell02', 'TC02', 'TC02', @type_average, 'Cell 2 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell03', 'TC03', 'TC03', @type_average, 'Cell 3 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell04', 'TC04', 'TC04', @type_average, 'Cell 4 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell05', 'TC05', 'TC05', @type_average, 'Cell 5 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell06', 'TC06', 'TC06', @type_average, 'Cell 6 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell07', 'TC07', 'TC07', @type_average, 'Cell 7 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell08', 'TC08', 'TC08', @type_average, 'Cell 8 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell09', 'TC09', 'TC09', @type_average, 'Cell 9 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell10', 'TC10', 'TC10', @type_average, 'Cell 10 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell11', 'TC11', 'TC11', @type_average, 'Cell 11 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell12', 'TC12', 'TC12', @type_average, 'Cell 12 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell13', 'TC13', 'TC13', @type_average, 'Cell 13 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell14', 'TC14', 'TC14', @type_average, 'Cell 14 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell15', 'TC15', 'TC15', @type_average, 'Cell 15 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell16', 'TC16', 'TC16', @type_average, 'Cell 16 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell17', 'TC17', 'TC17', @type_average, 'Cell 17 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell18', 'TC18', 'TC18', @type_average, 'Cell 18 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell19', 'TC19', 'TC19', @type_average, 'Cell 19 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell20', 'TC20', 'TC20', @type_average, 'Cell 20 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell21', 'TC21', 'TC21', @type_average, 'Cell 21 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell22', 'TC22', 'TC22', @type_average, 'Cell 22 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell23', 'TC23', 'TC23', @type_average, 'Cell 23 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell24', 'TC24', 'TC24', @type_average, 'Cell 24 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell25', 'TC25', 'TC25', @type_average, 'Cell 25 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell26', 'TC26', 'TC26', @type_average, 'Cell 26 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell27', 'TC27', 'TC27', @type_average, 'Cell 27 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell28', 'TC28', 'TC28', @type_average, 'Cell 28 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell29', 'TC29', 'TC29', @type_average, 'Cell 29 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell30', 'TC30', 'TC30', @type_average, 'Cell 30 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell31', 'TC31', 'TC31', @type_average, 'Cell 31 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TemperatureCell32', 'TC32', 'TC32', @type_average, 'Cell 32 Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VelocityMotor', 'VELM', '403', @type_average, 'Motor Velocity', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Float)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VelocityVehicle', 'VELV', '403', @type_average, 'Vehicle Velocity', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 4, @datatype_Float)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentBus', 'IBUS', 'IBUS', @type_average, 'Bus Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageBus', 'VBUS', 'VBUS', @type_average, 'Bus Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentPhaseA', 'IPHA', 'IPHA', @type_average, 'Phase A Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentPhaseB', 'IPHB', 'IPHB', @type_average, 'Phase B Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageMotorImag', 'VMIM', 'VMIM', @type_average, 'Imaginary Motor Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageMotorReal', 'VMRL', 'VMRL', @type_average, 'Real Motor Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentMotorImag', 'IMIM', 'IMIM', @type_average, 'Imaginary Motor Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('CurrentMotorReal', 'IMRL', 'IMRL', @type_average, 'Real Motor Current', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('BackEMFMotorImag', 'EMFI', 'EMFI', @type_average, 'Imaginary Motor Back EMF', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('BackEMFMotorReal', 'EMFR', 'EMFR', @type_average, 'Real Motor Back EMF', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageFifteenVSupply', '15VS', '15VS', @type_average, '15 Volt Supply Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageOnePtSixtyFiveVRef', '165R', '165R', @type_average, '1.65 Voltage Reference', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageTwoPtFiveVSupply', '25VS', '25VS', @type_average, '2.5 Volt Supply Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VoltageOnePtTwoVSupply', '12VS', '12VS', @type_average, '1.2 Volt Supply Voltage', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('FanDriveRPM', 'FRPM', 'FRPM', @type_average, 'Fan RPM', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('FanDrivePercent', 'FPER', 'FPER', @type_average, 'Fan Drive Percent', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempHeatsink', 'THTS', 'THTS', @type_average, 'Heat Sink Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempMotor', 'TMOT', 'TMOT', @type_average, 'Motor Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempAirInlet', 'TINL', 'TINL', @type_average, 'Air Inlet Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempAirOutlet', 'TOUT', 'TOUT', @type_average, 'Air Outlet Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempProcessor', 'TPRO', 'TPRO', @type_average, 'Processor Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TempCapacitor', 'TCAP', 'TCAP', @type_average, 'Capacitor Temperature', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('AmpHoursDCBus', 'AMPH', 'AMPH', @type_average, 'DC Bus Amp Hours', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('Odometer', 'ODO', 'ODO', @type_average, 'Odometer', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('EnableCruise', 'CRUS', 'CRUS', @type_average, 'Cruise Control Enabled', '#,##0.00;#,##0.00', @datatype_Int16, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('EnableRegen', 'RGEN', 'RGEN', @type_average, 'Regen Enabled', '#,##0.00;#,##0.00', @datatype_Int16, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('VelocityCruise', 'CRSP', 'CRSP', @type_average, 'Cruise Control Velocity', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('PotBrake', 'BRPT', 'BRPT', @type_average, 'Brake Pedal Position', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('PotAccel', 'ACPT', 'ACPT', @type_average, 'Accelerator Position', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('Latitude', 'LATI', 'LATI', @type_average, 'Latitude', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('Longitude', 'LONG', 'LONG', @type_average, 'Longitude', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('Speed', 'SPEED', 'SPEED', @type_average, 'GPS Speed', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('Course', 'CORS', 'CORS', @type_average, 'GPS Course', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('Altitude', 'ALTI', 'ALTI', @type_average, 'GPS Altitude', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('SatellitesSeen', 'SATT', 'SATT', @type_average, 'GPS Satellites Seen', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('UTCTime', 'UTCT', 'UTCT', @type_average, 'UTC Time', '#,##0.00;#,##0.00', @datatype_DateTime, @chart_no, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('UTCDate', 'UTCD', 'UTCD', @type_average, 'UTC Date', '#,##0.00;#,##0.00', @datatype_DateTime, @chart_no, 0, @datatype_Byte8)
    INSERT INTO tblDataItems (FieldName, Tag, CANTag, SummaryType, Description, DisplayFormat, DataType, NoCharting, CANByteOffset, CANDataType)
                      VALUES ('TripCode', 'TC', 'TC', @type_average, 'Trip Code', '#,##0.00;#,##0.00', @datatype_Double, @chart_yes, 0, @datatype_Byte8)

 GO
 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[p_GetCANFields]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[p_GetCANFields]
GO

CREATE PROCEDURE p_GetCANFields
AS

    SET NOCOUNT ON
    
    /* Return all telemetry fields that are collectable from CAN */
    
    SELECT * FROM tblDataItems WHERE IsCanValue = 1
                               ORDER BY CANTag, CANByteOffset

GO
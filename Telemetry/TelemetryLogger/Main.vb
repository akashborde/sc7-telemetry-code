﻿Imports System.Data.SqlClient
Imports System.IO.Ports
Imports System.Collections.Concurrent
Imports System.Threading

Module Main
    '-----------------------------TYPE DEFINITIONS-------------------------------'
    ' state enums
    Enum LogState
        OPEN
        RUN
        CLOSE
        QUIT
    End Enum

    Enum COMState
        OPEN
        RUN
        CLOSE
        QUIT
    End Enum

    Enum SQLState
        OPEN
        RUN
        CLOSE
        QUIT
    End Enum

    Enum COMResult
        OK
        FAILED
        NO_DATA
    End Enum

    ' object representing data for one CAN tag
    Class CANMessageData
        Public CANTag As String
        Public CANFields As New Collection
        Public WriteOnly Property NewDataValue As cCANData
            Set(value As cCANData)
                For Each field As cDataField In CANFields
                    field.NewDataValue = value
                Next
            End Set
        End Property
    End Class

    '------------------------------SHARED DATA-------------------------------------'
    ' log variables
    Private _ErrorWriter As LogWriter
    Private _DebugWriter As LogWriter
    Private _LogState As LogState
    Private _LogThread As Thread

    ' COM variables
    Private _Port As SerialPort
    Private _LastCOMWrite As Long
    Private _COMState As COMState
    Private _COMThread As Thread
    Private _COMLock As New Object

    ' SQL variables
    Private _SQLConn As SqlConnection
    Private _InsertCommand As String
    Private _Values As String
    Private _CANMessages As ConcurrentDictionary(Of String, CANMessageData)
    Private _CANMessagesLock As New Object
    Private _SQLState As SQLState
    Private _SQLThread As Thread

    '--------------------------------CODE------------------------------------------'
    Sub Main()
        ' init state
        _COMState = COMState.OPEN
        _SQLState = SQLState.OPEN
        _LogState = LogState.OPEN

        ' init error and debug loggers
        _ErrorWriter = New LogWriter("error_log " & Format(Now, "M-d-yyyy") & " " & Format(Now, "hh.mm.ss tt") & ".txt", True)
        _ErrorWriter.ClearLog()
        _DebugWriter = New LogWriter("debug_log " & Format(Now, "M-d-yyyy") & " " & Format(Now, "hh.mm.ss tt") & ".txt", My.Settings.EnableDebug)
        _DebugWriter.ClearLog()
        _LogState = LogState.RUN
        _LogThread = New Thread(AddressOf RunLog)
        _LogThread.Start()

        ' open SQL and load data fields
        If OpenSqlConnection() Then
            If LoadCANFields() Then
                _SQLState = SQLState.RUN
            Else
                Console.WriteLine("Failed to load fields from database.")
                CloseSqlConnection()
            End If
        Else
            Console.WriteLine("Failed to connected to database.")
        End If
        _SQLThread = New Thread(AddressOf RunSQL)
        _SQLThread.Start()

        ' open COM port
        If OpenCOMPort() Then
            _COMState = COMState.RUN
        Else
            Console.WriteLine("Failed to open COM port.")
        End If
        _LastCOMWrite = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond
        _COMThread = New Thread(AddressOf RunCOM)
        _COMThread.Start()
    End Sub

    Sub Close()
        ' request close of COM
        SyncLock _COMLock
            If _COMState <> COMState.OPEN Then
                _COMState = COMState.CLOSE
            Else
                _COMState = COMState.QUIT
            End If
        End SyncLock

        ' request close of SQL
        If _SQLState <> SQLState.OPEN Then
            _SQLState = SQLState.CLOSE
        Else
            _SQLState = SQLState.QUIT
        End If

        ' wait for log/COM/SQL threads to finish
        _COMThread.Join()
        _SQLThread.Join()

        ' dump logs and end log thread
        _LogState = LogState.CLOSE
        _LogThread.Join()
    End Sub

    Sub RunLog()
        While True
            Select Case _LogState
                Case LogState.RUN
                    _ErrorWriter.WriteAll()
                    _DebugWriter.WriteAll()
                    Thread.Sleep(My.Settings.LogWriteInterval)
                Case LogState.CLOSE
                    _ErrorWriter.WriteAll()
                    _DebugWriter.WriteAll()
                    _LogState = LogState.QUIT
                Case LogState.QUIT
                    Exit While
                Case Else
                    Thread.Sleep(My.Settings.LogIdleInterval)
            End Select
        End While
    End Sub

    Sub RunCOM()
        Dim currentMillis As Long = _LastCOMWrite

        While True
            SyncLock _COMLock
                Select Case _COMState
                    Case COMState.OPEN
                        If OpenCOMPort() Then
                            _COMState = COMState.RUN
                        Else
                            Console.WriteLine("Failed to open COM port.")
                            Thread.Sleep(5000)
                        End If
                    Case COMState.RUN
                        Select Case GetCANMessage()
                            Case COMResult.FAILED
                                ' COM disconnected
                                _COMState = COMState.OPEN
                            Case COMResult.NO_DATA
                                Console.WriteLine("No data available on CAN bus.")
                                Thread.Sleep(1000)
                            Case COMResult.OK
                                ' check if CAN status needs to be transmitted
                                currentMillis = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond
                                If currentMillis - _LastCOMWrite >= My.Settings.COMWriteInterval Then
                                    If Not WriteCANMessage(_SQLState <> SQLState.OPEN) Then
                                        Console.WriteLine("Failed to write heartbeat to CAN bus.")
                                    End If
                                    _LastCOMWrite = currentMillis
                                End If
                        End Select
                    Case COMState.CLOSE
                        CloseCOMPort()
                        _COMState = COMState.QUIT
                    Case COMState.QUIT
                        Exit While
                End Select
            End SyncLock
        End While
    End Sub

    Sub RunSQL()
        While True
            Select Case _SQLState
                Case SQLState.RUN
                    If Not SaveData() Then
                        Console.WriteLine("Failed to write to database.")
                    End If
                    Thread.Sleep(My.Settings.SQLWriteInterval)
                Case SQLState.CLOSE
                    CloseSqlConnection()
                    _SQLState = SQLState.QUIT
                Case SQLState.QUIT
                    Exit While
                Case Else
                    Thread.Sleep(My.Settings.SQLIdleInterval)
            End Select
        End While
    End Sub

    Function OpenSqlConnection() As Boolean
        _DebugWriter.AddMessage("*** OPENING SQL CONNECTION")

        Try
            _SQLConn = New SqlConnection(My.Settings.DSN)
            _SQLConn.Open()
            Return True
        Catch sqlEx As System.Data.SqlClient.SqlException
            _ErrorWriter.AddMessage("Error opening SQL connection: " & sqlEx.Errors(0).Message)
            _ErrorWriter.WriteAll()
            Return False
        Catch ex As Exception
            _ErrorWriter.AddMessage("Unexpected error - " & ex.Message & ", while opening SQL connection")
            _ErrorWriter.WriteAll()
            Return True
        End Try
    End Function

    Sub CloseSqlConnection()
        _DebugWriter.AddMessage("*** CLOSING SQL CONNECTION")

        Try
            _SQLConn.Close()
        Catch sqlEx As System.Data.SqlClient.SqlException
            _ErrorWriter.AddMessage("Error closing SQL connection: " & sqlEx.Errors(0).Message)
            _ErrorWriter.WriteAll()
        Catch ex As Exception
            _ErrorWriter.AddMessage("Unexpected error - " & ex.Message & ", while closing SQL connection")
            _ErrorWriter.WriteAll()
        End Try
    End Sub

    Function OpenCOMPort() As Boolean
        _DebugWriter.AddMessage("*** OPENING COM PORT")

        'Get current port names
        Dim COMPorts As List(Of String)

        'Basic Setup
        _Port = New SerialPort()
        _Port.BaudRate = My.Settings.BaudRate
        _Port.DataBits = 8
        _Port.Parity = Parity.None
        _Port.StopBits = 1
        _Port.Handshake = False
        _Port.ReadTimeout = My.Settings.COMTimeout
        _Port.WriteTimeout = 500

        ' Get list of current ports
        COMPorts = (SerialPort.GetPortNames).ToList
        COMPorts.Insert(0, My.Settings.COMPort) ' Insert Predefined COMPort to try

        For Each port As String In COMPorts
            Try
                _Port.PortName = port
                _Port.Open()

                If _Port.IsOpen Then
                    _DebugWriter.AddMessage("opened " & _Port.PortName)
                    Return True
                End If
            Catch connEx As System.IO.IOException
                _ErrorWriter.AddMessage("Unable to connect to " & My.Settings.COMPort)
                _ErrorWriter.WriteAll()
            Catch accessEx As System.UnauthorizedAccessException
                _ErrorWriter.AddMessage("Access Denied. Failed to open " & My.Settings.COMPort)
                _ErrorWriter.WriteAll()
            Catch ex As Exception
                _ErrorWriter.AddMessage("Unexpected error - " & ex.Message & ", while connecting to COM port")
                _ErrorWriter.WriteAll()
            End Try
        Next port

        Return False
    End Function

    Sub CloseCOMPort()
        _DebugWriter.AddMessage("*** CLOSING COM PORT")

        Try
            _Port.Close()
        Catch ioEx As System.IO.IOException
            _ErrorWriter.AddMessage("Uanble to close COM port.")
            _ErrorWriter.WriteAll()
        Catch ex As Exception
            _ErrorWriter.AddMessage("Unexpected error: " & ex.Message & ", while closing COM port.")
            _ErrorWriter.WriteAll()
        End Try
    End Sub

    Function LoadCANFields() As Boolean
        _DebugWriter.AddMessage("*** LOADING SQL DATABASE")

        ' read CAN fields from database
        LoadCANFields = False
        Try
            Dim LastCANTag As String = ""
            Dim CANMessage As CANMessageData = Nothing ' CANMessageData contains all columns for one tag
            _CANMessages = New ConcurrentDictionary(Of String, CANMessageData) ' will hold all CANMessage data objects

            Dim cmd As New SqlCommand
            With cmd
                .CommandText = "p_GetCANFields"
                .CommandType = CommandType.StoredProcedure
                .CommandTimeout = 0
                .Connection = _SQLConn
                Dim dr As SqlDataReader = .ExecuteReader
                Do While dr.Read
                    Dim data As New cDataField(dr) ' cDataField represents column in database
                    _DebugWriter.AddMessage("cantag " & data.CANTag & " field " & data.FieldName)

                    If data.CANTag <> LastCANTag Then ' new CAN tag
                        If Not CANMessage Is Nothing Then
                            _CANMessages.TryAdd(CANMessage.CANTag, CANMessage) ' add tag info object
                        End If
                        CANMessage = New CANMessageData ' new tag info object
                        CANMessage.CANTag = data.CANTag
                        LastCANTag = data.CANTag
                    End If
                    CANMessage.CANFields.Add(data) ' add column information
                Loop
                dr.Close()
                If Not CANMessage Is Nothing Then
                    _CANMessages.TryAdd(CANMessage.CANTag, CANMessage)
                End If
            End With

            ' init insert query
            _InsertCommand = "INSERT INTO tblHistory ("

            For Each message As CANMessageData In _CANMessages.Values
                For Each datafield As cDataField In message.CANFields
                    _InsertCommand &= datafield.FieldName & ", "
                Next
            Next

            _InsertCommand = _InsertCommand.Substring(0, _InsertCommand.Length - 2) & ") "

            ' done
            LoadCANFields = True
        Catch sqlEx As System.Data.SqlClient.SqlException
            _ErrorWriter.AddMessage("Error loading SQL database: " & sqlEx.Errors(0).Message)
            _ErrorWriter.WriteAll()
        Catch ex As Exception
            _ErrorWriter.AddMessage("Unexpected error - " & ex.Message & ", while loading CAN Field SQL database")
            _ErrorWriter.WriteAll()
        End Try
    End Function

    Function GetCANMessage() As COMResult
        Dim Message As String = ""
        Dim Tag As String = ""
        Dim CanData As String = ""
        Dim CurrentMessage As CANMessageData = Nothing

        ' read message
        _DebugWriter.AddMessage("*** READING CAN MESSAGE")
        Try
            ' get bytes from COM port
            Message = _Port.ReadTo(";")
            _DebugWriter.AddMessage("bytes remaining " & _Port.BytesToRead)
            _DebugWriter.AddMessage("raw message " & Message)

            ' reorder data
            If Message.Length = 22 Then
                Tag = Message.Substring(2, 3)
                For i As Integer = 20 To 6 Step -2 ' bytes are read from COM port in reverse order
                    CanData &= Message.Substring(i, 2)
                Next
                _DebugWriter.AddMessage("cantag " & Tag & " candata " & CanData)

                SyncLock _CANMessagesLock
                    If _CANMessages.TryGetValue(Tag, CurrentMessage) Then
                        CurrentMessage.NewDataValue = New cCANData(CanData) ' update value of tag info object
                        If My.Settings.EnableDebug Then
                            For Each datafield As cDataField In CurrentMessage.CANFields
                                _DebugWriter.AddMessage("field " & datafield.FieldName & " value " & datafield.DataValueAsString)
                            Next
                        End If
                    End If
                End SyncLock

                Return COMResult.OK
            Else
                _ErrorWriter.AddMessage("Invalid CAN packet received from COM port: " & Message)
                Return COMResult.NO_DATA
            End If

        Catch timeoutEx As System.TimeoutException
            _ErrorWriter.AddMessage("COM port read timed out while attempting to get CAN packet")
            Return COMResult.NO_DATA
        Catch ioEx As System.IO.IOException
            _ErrorWriter.AddMessage("COM port disconnected while attempting to get CAN packet")
            Return COMResult.FAILED
        Catch invalidOpEx As System.InvalidOperationException
            _ErrorWriter.AddMessage("COM port closed while attempting to get CAN packet")
            Return COMResult.FAILED
        Catch ex As Exception
            _ErrorWriter.AddMessage("Unexpected error - " & ex.Message & " while getting can message")
            Return COMResult.FAILED
        End Try
    End Function

    Function SaveData() As Boolean
        Try
            _DebugWriter.AddMessage("*** WRITING TO SQL DATABASE")

            ' Construct query string
            _Values = "VALUES ("

            ' Add values to query string
            SyncLock _CANMessagesLock
                For Each CANMessage As CANMessageData In _CANMessages.Values
                    For Each datafield As cDataField In CANMessage.CANFields
                        _Values &= datafield.DataValueAsString & ","
                        datafield.Reset()
                    Next
                Next
            End SyncLock

            _Values = _Values.Substring(0, _Values.Length - 1) & ")"
            _DebugWriter.AddMessage(_InsertCommand)
            _DebugWriter.AddMessage(_Values)

            ' Execute insert command
            Dim cmd As New SqlCommand
            With cmd
                .CommandText = _InsertCommand & _Values
                .CommandType = CommandType.Text
                .CommandTimeout = 0
                .Connection = _SQLConn
                .ExecuteNonQuery()
            End With

            ' done
            Return True
        Catch sqlEx As System.Data.SqlClient.SqlException
            _ErrorWriter.AddMessage("Error writing to SQL database: " & sqlEx.Errors(0).Message)
            Return False
        Catch ex As Exception
            _ErrorWriter.AddMessage("Unexpected error - " & ex.Message & " while writing to database")
            Return False
        End Try
    End Function

    Function WriteCANMessage(ByVal sqlConn As Boolean) As Boolean
        _DebugWriter.AddMessage("*** WRITING CAN PACKET")
        Dim message As String = ":|S" & My.Settings.TelStatusID & "N"

        ' add SQL connected and COM connected bits
        If sqlConn Then
            message &= "03"
        Else
            message &= "02"
        End If

        ' Fill rest of message with 0's
        message &= "00000000000000;"
        _DebugWriter.AddMessage("message " & message)

        ' Send the message out over CAN.
        Try
            _Port.Write(message)
            Return True
        Catch timeoutEx As System.TimeoutException
            _ErrorWriter.AddMessage("COM port timed out while writing CAN packet")
            Return False
        Catch ioEx As System.ArgumentNullException
            _ErrorWriter.AddMessage("Invalid String: '" & message & "' writen to COM port")
            Return False
        Catch invalidOpEx As System.InvalidOperationException
            _ErrorWriter.AddMessage("COM port closed while writing CAN packet")
            Return False
        Catch ex As Exception
            _ErrorWriter.AddMessage("Unexpected error: " & ex.Message & ", while writing CAN packet")
            Return False
        End Try
    End Function
End Module
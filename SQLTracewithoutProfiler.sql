--— sys.traces shows the existing sql traces on the server


select * from sys.traces

go

 

--–create a new trace, make sure the @tracefile must NOT exist on the disk yet


declare @tracefile nvarchar(500) set @tracefile=N'c:\temp\newtraceFile'

declare @trace_id int

declare @maxsize bigint

select @trace_id

set @maxsize =1

exec sp_trace_create @trace_id output,2,@tracefile ,@maxsize

go

 

--—- add the events of insterest to be traced, and add the result columns of interest

--—  Note: look up in sys.traces to find the @trace_id, here assuming this is the first trace in the server, therefor @trace_id=1


declare @trace_id int

set @trace_id=3

declare @on bit

set @on=1

declare @current_num int

set @current_num =1

while(@current_num <65)

      begin

     -- –add events to be traced, id 14 is the login event, you add other events per your own requirements, the event id can be found @ BOL http://msdn.microsoft.com/en-us/library/ms186265.aspx
	 --10 is for RPC:Completed

      exec sp_trace_setevent @trace_id,10, @current_num,@on

      set @current_num=@current_num+1

      end

go

 

--–turn on the trace: status=1

--— use sys.traces to find the @trace_id, here assuming this is the first trace in the server, so @trace_id=1


declare @trace_id int

set @trace_id=3

exec sp_trace_setstatus  @trace_id,1

 


--–pivot the traced event

select LoginName,DatabaseName,Error,* from ::fn_trace_gettable(N'c:\temp\newtraceFile.trc',default) where error = 2

go

 

--— stop trace. Please manually delete the trace file on the disk

--— use sys.traces to find the @trace_id, here assuming this is the first trace in the server, so @trace_id=1


declare @trace_id int

set @trace_id=3

exec sp_trace_setstatus @trace_id,0

exec sp_trace_setstatus @trace_id,2

go
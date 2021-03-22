-- Gives error() a message so the parallel API won't ignore the error.
function os.pullEvent( _sFilter )
	local event, p1, p2, p3, p4, p5 = os.pullEventRaw( _sFilter )
	if event == "terminate" then
		error( "Terminated" )
	end
	return event, p1, p2, p3, p4, p5
end

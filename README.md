Streamable
==========
A simple,decent custom stream implementation,not to rival the inbuilt dart streams but to provide a special stream with a different approach,it basically was built to handle the streaming api for flow.dart(my flow based programming framework),but can be used for any project requiring push-down streams with basic pause-resume that flows both upward and downward to consumers.

###Candies:

#####Candy 1: Streamable 
	Streamable is the standard streaming handler,you simple create one and send off your items,also a stream waits till it gets
	a function through its listen function,once it gets that,then it begins to propagate,it can be paused,resume, also allows
	attaching a function to it,to get notify everytime it drains all item in the stream using the ondrain function.
	
	Streamable<int> buffer = new Streamable<int>(200);
	buffer.add(1);
	buffer.add(3);
	buffer.add(2);
	
	//non-cap stream
	Streamable stream = Streamable.create();
	stream.add(2);
	
	stream.listen((n){ print('getting $n'); });
	stream.onDrain((){ print('drained last items'); });
	
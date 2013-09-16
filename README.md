Pipes
======
A simple,decent custom stream implementation,not to rival the inbuilt dart streams but to provide a special stream with a different approach,it basically was built to handle the streaming api for flow.dart(my flow based programming framework),but can be used for any project requiring push-down streams with basic pause-resume that flows both upward and downward to consumers.

###Candies:

#####Candy 1: Streamable and CappedStream
	Streamable is the standard streaming handler,you simple create one and send off your items,also a stream waits till it gets
	a function through its listen function,once it gets that,then it begins to propagate,it can be paused,resume, also allows
	attaching a function to it,to get notify everytime it drains all item in the stream using the ondrain function.
	CappedStream Has a maximum set amount of items allowed in the stream,if it passes the total set size,it flushes all items away.
	
	CappedStreamable<int> buffer = new CappedStreamable<int>(200);
	buffer.add(1);
	buffer.add(3);
	buffer.add(2);
	
	//non-cap stream
	Streamable stream = Streamable.create();
	stream.add(2);
	
	stream.listen((n){ print('getting $n'); });
	stream.onDrain((){ print('drained last items'); });
	
#####Candy 2: BroadcastListener (Equivalent to the StreamConsumer)
	The broadcastlistener is equivalent to the streamConsumer but with a major difference which is that it can buffer incomming stream
	even if it has been paused,which allows a higher level stream to continue propagating stream items to it without worries of 
	having to flush or drain because the broadcastlistener can simple decided to pause the notification to perform a task and then
	continue with operation without missing any items. Also allows individual listeners to unsubscribe from stream.
	
    BroadcastListener<int> sub = new BroadcastListener<int>(casts);
    sub.on((int m){
      print('sub station: $m');
    });
	
    BroadcastListener<int> sub2 = new BroadcastListener<int>(casts);
    sub2.on((int m){
      print('sub2 station: $m');
    });

#####Candy 3: BroadCasters
	This is the propagator of all items passed to it to multiple functions,created to match the usual callback list where functions
	are called with a giving value,basically allows one to attach this to a stream and then pass functions that get called once it
	gets an item
	
    Broadcasters<int> casts = new Broadcasters<int>('#1');
    casts.on((int n){
      print("station 1: $n");
    }); 

#####Candy 4: Stream + BroadCaster + Listeners
	The combination of the above 3 produces a workable stream that can propagate to a large set of listeners with little effort.
	
    CappedStreamable<int> buffer = new CappedStreamable<int>(200);
    buffer.add(1);
    buffer.add(3);
    buffer.add(2);
	
    Broadcasters<int> casts = new Broadcasters<int>('#1');
    casts.on((int n){
      print("station 1: $n");
    });
	
    BroadcastListener<int> sub = new BroadcastListener<int>(casts);
    sub.on((int m){
      print('sub station: $m');
    });
	
    buffer.listen(casts.propagate);
	
    BroadcastListener<int> sub2 = new BroadcastListener<int>(casts);
    sub2.on((int m){
      print('sub2 station: $m');
    });
    buffer.add(4);
	
	
#####Candy 5: Pipes
	To reduce the total setup required as to combining the stream, the broadcasters and listeners, the Pipe encapsulates all that
	steps by simple letting a single Object connect to the stream,create a broadcaster and produce listeners when needed effortlessly.
	
    var pipe = Pipes.create('#1');
    pipe.add(1);
    pipe.add(2);
	
    var sb = pipe.listen((a){ print('[pipe: #$a]'); });
    pipe.listen((a){ print('[pipe2: #$a]'); });
	
    pipe.add(3);
    pipe.add(6);
	
    sb.pause();
	
    pipe.add(10);
    pipe.add(5);
	
    var i = 20;
    while(true){
      if(i == 24){
        buffer.close();
        pipe.close();
        break;
      }
      buffer.add(i);
      pipe.add(i);
      i++;
    }
	
    sb.resume();
	

#####Candy 6: BufferedStream 
	The BufferedStream is rather oddly named,since in essence it does not serve towards a buffering stream but rather its a 
	specialised stream that allows adding consequetive items that come in a group,without distorting the order of items in the
	stream list by using a dual stream,where when the group needs to be assembled are sent into the second stream and when done,
	adds all the items into the main stream without distorting order.
	
    var buf = BufferedStream.create();
    buf.add(1); //add a item normally
	
    buf.listen((n){ print('buffer: $n'); }); //listen up
	
    buf.add(2);
	
    buf.buffer(); //decide to send in a group of items
    buf.add(3);
    buf.add(4);
    buf.add(5);
    buf.endBuffer(); //end of group which then sends them in order to main stream
	
    buf.add(6);
    buf.add(7);
    buf.buffer();
    buf.add(8);
    buf.endBuffer();
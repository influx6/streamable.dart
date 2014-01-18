Streamable
==========
A simple,decent custom stream implementation,not to rival the inbuilt dart streams but to provide a special stream with a different approach,it basically was built to handle the streaming api for flow.dart(my flow based programming framework),but can be used for any project requiring push-down streams with basic pause-resume that flows both upward and downward to consumers.

###Candies:

#####Candy 1: Streamable 
	Streamable is the standard streaming handler,you simple create one and send off your items,also a stream waits till it gets
	a function through its listen function,once it gets that,then it begins to propagate,it can be paused,resume, also allows
	attaching a function to it,to get notify everytime it drains all item in the stream using the ondrain function.
	
    Streamable buffer = new Streamable();
  
    buffer.transformer.on((n){
        return "$n little sheep";
    });
  

    buffer.whenInitd((n){
        print('emiting $n');
    });

    buffer.emit(1);
    buffer.emit(3);
    buffer.emit(2);

    buffer.emit(5);
    buffer.emitMass([6,7]);

    buffer.on((n){
    print("buffering: ${n}");
    });

    var subscriber = buffer.subscriber((m){ print('sub: $m'); });


#####Candy 2: Subscriber
    Subscriber is as simple as its sounds,its a hook into the stream that is passed to it which allows the pausing and resuming of its own unique stream without effecting the root stream its connected to,and allows the closing and ending of the subscription to the root stream
    
    var sub = Subscriber.create(buffer);
    sub.on((g){ print('subscribers item: $g'); });

    buffer.pause();

    buffer.emit(4);


    buffer.resume();

    //buffer.enablePushDelayed();

    buffer.emit(8);

    buffer.emit(9);


    buffer.emit(10);
    buffer.end();

    buffer.emit(11);
    buffer.emit(12);

#####Candy 2: MixedStreams
    MixedStreams provides a functional combination of a sets of streams,depending on a condition either by length or a custom condition function,it will gather all ejected events from the sets of streams and eject this sets depending on the condition into a new stream,a very useful technique for mixing a sets of streams into one as either individual packets or as a list of packets
    
    Streamable buffer = Streamable.create();
    Streamable stream = Streamable.create();  

    var mixedOrder = (MixedStreams.combineOrder([buffer,stream])(null,null,(values,mixed,streams,injector){
         mixed.emitMass(values);
    }));
     
    var mixed = (MixedStreams.combineUnOrder([buffer,stream])((tg,cg){
       if(tg.length >= 2) return true;
       return false;
    }));
       
    buffer.emit(1);
    stream.emit(4);
    buffer.emit(3);
    stream.emit(2);
     
    mixed.pause();
    mixed.on((t){
      print("mixed stream: $t");
    });

    mixedOrder.on((t){
      print("mixedOrder $t");  
    });

    mixed.resume();
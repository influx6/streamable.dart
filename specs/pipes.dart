library pipe.specs;
import 'dart:async';
import 'package:pipes/pipes.dart';

main(){
  
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
  
  var buf = BufferedStream.create();
  buf.add(1);

  buf.listen((n){ print('buffer: $n'); });

  buf.add(2);
  buf.buffer();
  buf.add(3);
  buf.add(4);
  buf.add(5);
  buf.endBuffer();
  buf.add(6);
  buf.add(7);
  buf.buffer();
  buf.add(8);
  buf.endBuffer();

}

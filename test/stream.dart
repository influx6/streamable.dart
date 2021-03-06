library specs;

import 'dart:async';
import 'package:streamable/streamable.dart';

main(){
  
 Streamable buffer = new Streamable();
  
 buffer.transformer.on((n){
   return "$n little sheep";
 });
  
 buffer.setMax(4);

 buffer.enableFlushing();

// buffer.whenInitd((n){
//   print('emiting $n');
// });
 
  buffer.emit(1);
  buffer.emit(3);
  buffer.emit(2);
  
  buffer.emit(5);
  buffer.emitMass([6,7]);


  buffer.on((n){
    print("buffering: ${n}");
  });
  
  
  var sub = Subscriber.create(buffer);
  sub.on((g){ print('subscribers item: $g'); });
  sub.whenEnded((n) => print('sub ended by super'));

  buffer.pause();

  buffer.emit(4);

  buffer.whenClosed((n){
    print('closed!');
  });
  
  buffer.whenEnded((n){
    print('ended!');
  });
  
  buffer.resume();
  
  //buffer.enablePushDelayed();
  
  buffer.emit(8);
  
  buffer.emit(9);


  buffer.emit(10);
  buffer.end();
  
  buffer.emit(11);
  buffer.emit(12);

  buffer.close();

  buffer.emit(8);
  
  buffer.emit(9);
}

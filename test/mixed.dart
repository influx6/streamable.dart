library specs;

import 'package:streamable/streamable.dart';

main(){
  
  Streamable buffer = Streamable.create();
  Streamable stream = Streamable.create();  
  
  buffer.whenClosed((n){
    print('closed!');
  });

  buffer.disableEndOnDrain();
  
  var mixedOrder = (MixedStreams.combineOrder([buffer,stream])(null,null,(values,mixed,streams,injector){
      mixed.emitMass(values);
  }));
  
  var mixed = (MixedStreams.combineUnOrder([buffer,stream])((tg,cg){
    if(tg.length >= 2) return true;
    return false;
  }));

  buffer.ended.on((n){
    print('buffer just ended with $n');
  });
  
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

  buffer.emit(4);
  
  buffer.enableEndOnDrain();

  buffer.emit(5);

  mixed.resume();


  /*buffer.close();*/

  
}

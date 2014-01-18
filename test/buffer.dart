library pipe.specs;
import 'dart:async';
import 'package:streamable/streamable.dart';

main(){
  
  Distributor buffer = Distributor.create('example');

  buffer.once((n){
      print("recieved ${n}");
  });

  buffer.on((n){
      print("recieved2 ${n}");
  }); 

  buffer.whenDone((n){
    print("done!");
  });
  
  buffer.emit(5);
  buffer.emit(6);
  buffer.emit(4);


}

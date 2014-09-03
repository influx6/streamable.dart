library specs;

import 'dart:async';
import 'package:streamable/streamable.dart';
import 'package:hub/hub.dart';

main(){
  
  var dispatch = Dispatch.create();
  var thunder = dispatch.watch('thunder');
  var reggy = dispatch.watch(new RegExp('reggy'));
  var r1 = dispatch.watch('slot');
  var r2 = dispatch.watch(new RegExp('bank'));

  jazzUp((_){

    _.group('testing dispatchwatcher',($){

      $.test('can i use a string message')
      .rack('is message == thunder',(f){
        Expects.asserts(f.message,'thunder');
      })
      .rack('thunder watcher get chicken message',(f){
        thunder.listen((m){
          Expects.isMap(m);
          Expects.asserts(m['data'],'flice');
        });
        dispatch.dispatch({'message':'thunder','data':'flice'});
      })
      .emit(thunder);

      $.test('can i use a regexip message')
      .rack('is message == regexp(reggy)',(f){
        Expects.isRegExp(f.message);
      })
      .rack('reggy watch should get rox message',(f){
        reggy.listen((m){
          Expects.isMap(m);
          Expects.asserts(m['data'],'rox');
        });
        dispatch.dispatch({'message':'reggy','data':'rox'});
      })
      .emit(reggy);

    });

    _.group('test waitFor,waitForAlways and forAnyOnce and forAny',($){


      $.test('can i watch two dispatchers with forAnyOnce?')
      .rack('use dispatch.forAnyOnce',(f){
        f.listen((m){
          Expects.isMap(m);
        });
        dispatch.dispatch({'message':'slot','data':'rocking sox'});
        dispatch.dispatch({'message':'bank','data':'thunderous flags'});
        dispatch.dispatch({'message':'slot','data':'rocking sox2'});
        dispatch.dispatch({'message':'bank','data':'thunderous flags2'});
        dispatch.dispatch({'data':'we are not tagged'});
      }).emit(Dispatch.forAnyOnce([r1,r2]));

      $.test('can i watch two dispatchers with forAny,waitfor and waitforAlways?')
      .rack('use dispatch.forAny',(f){
        Dispatch.forAny(f).listen((m){
          Expects.isMap(m);
        });
        dispatch.dispatch({'message':'slot','data':'rocking sox'});
        dispatch.dispatch({'message':'bank','data':'thunderous flags'});
        dispatch.dispatch({'data':'we are not tagged'});
      })
      .rack('use dispatch.waitForAlways',(f){
        Dispatch.waitForAlways(f).listen((m){
          Expects.isMap(m);
        });
        dispatch.dispatch({'message':'slot','data':'rocking sox'});
        dispatch.dispatch({'message':'bank','data':'thunderous flags'});
      })
      .rack('use dispatch.waitfor',(f){
        Dispatch.waitFor(f).listen((m){
          Expects.isMap(m);
        });
        dispatch.dispatch({'message':'slot','data':'rocking sox'});
        dispatch.dispatch({'message':'bank','data':'thunderous flags'});
      })
      .emit(([r1,r2]));
    });
  }).then((f){
  
    dispatch.destroy();
    r1.destroy();
    r2.destroy();
    reggy.destroy();
    thunder.destroy();

  });

}

library pipes;

import 'dart:async';
import 'dart:collection';
import 'dart:mirrors';
import 'package:hub/hub.dart';
import 'package:ds/ds.dart' as d;

typedef dynamic Callback();
typedef dynamic TimerCallback(Timer t);

void nextTick(Callback m){
  Timer.run(m);
}

Timer delayTick(void m(),ms){
  return new Timer(new Duration(milliseconds:ms),m);
}

void nextPeriodicTick(TimerCallback m){
  Timer.periodic(Duration.Zero,m);
}

abstract class Streamer<T>{
  void add(T e);
  void push();
  void resume();
  void pause();
  void listen(Function n);
  void end();
  void close();
  void pipe(Streamer s);
}

abstract class Broadcast<T>{
  void on(Function n);
  void off(Function n);
  void propagate(T n);
  void add(T n) => this.propagate(n);
}

abstract class Listener<T>{
  void pulse(T a);
  void pause();
  void resume();
  void on();
  void off();
}

class Streamable<T> extends Streamer<T>{
  final d.dsList<T> _streams = d.dsList.create();
  final Completer _done = new Completer();
  bool _shouldShutDown = false;
  Function _handler;
  Function _backhandler;
  
  static create() => new Streamable();

  Streamable();

  void add(T a){
    if(this.closed) return;
    this._streams.append(a);
    this.push();
  }
  
  void close(){
    this.end();
    this.done.then((n){
      this._streams.free();
      this._handler = this._backhandler = null;
    });
  }
  
  void pause(){
    if(this.paused || !this.isConnected || this.closed) return;
    var fn = this._handler;
    this._backhandler = fn;
    this._handler = null;
  }
  
  void resume(){
    if(!this.paused || !this.isConnected || this.closed) return;
    var fn = this._backhandler;
    this._handler = fn;
    this._backhandler = null;
    this.push();
  }

  void end(){
    if(this.closed) return;
    (this.paused ? this.resume() : this.push());
    this._shouldShutDown = true;
  }

  void listen(Function n){
    (!this.paused ? this._handler = n : this._backhandler = n);
    (this.paused ? this.resume() : this.push());
  }

  void disconnect(){
    this._handler = this._backhandler = null;
  }

  void push(){
    if(this.paused || !this.isConnected) return;
    while(!this._streams.isEmpty)
      this._handler(this._streams.removeHead().data);
    if(this._shouldShutDown){
      this._done.complete();
      this._done.future.then((){ this.close(); });
    }
  }
  
  bool isOverSize(int max){
    return (this.size > max);
  }

  void flush() => this._streams.free();
  
  Future get done => this._done.future;
  int get size => this._streams.size;
  bool get isEmpty => this._streams.isEmpty;
  bool get closed => (this._streams == null);
  bool get isConnected => (this._handler != null || this._backhandler != null);
  bool get paused { 
    return ((this._handler == null && this._backhandler != null));
  }
}

class CappedStreamable<T> extends Streamable<T>{
  int max;
  
  static create([m]) => new CappedStreamable<T>(m);

  CappedStreamable([int max]) : super(){
    this.max = (max == null ? 1000 : max);
  }

  void add(T a){
    if(this.isOverSize(this.max)) this._stream.flush();
    super.add(a);
  }
  
}

class Broadcasters<T> extends Broadcast<T>{
  final listeners = new d.dsList<Function>();
  String id;
  var _internalIterator;
  
  static create(id) => new Broadcasters(id);

  Broadcasters(this.id){
    this._internalIterator = this.listeners.iterator;
  }
  
  void on(Function n){
    if(this._internalIterator.has(n)) return;
    this.listeners.append(n);
  }

  void off(Function m){
    var it = this.listeners.iterator;
    it.remove(n);
    it.detonate();
  }
  
  void free(){
    this.listeners.free();
  }

  void propagate(T n){
    while(this._internalIterator.moveNext()) 
      this._internalIterator.current(n);
  }

  bool get hasListeners{
    return (this.listeners.size > 0);
  }
}


class BroadcastListener<T> extends Listener<T>{
  Broadcast<T> cast;
  CappedStreamable<T> buffer;
  Function handler;
  
  static create(c) => new BroadcastListener(c);

  BroadcastListener(this.cast){
    this.buffer = new CappedStreamable<T>();
    this.cast.on(this.pulse);
    this.buffer.done.then((n){
      this.off();
    });
  }
  
  void on(Function n){
    if(this.isDead) return;
    this.handler = n;
    this.buffer.listen(this.handler);
  }

  void pulse(T a){
    if(this.isDead) return;
    if(this.buffer.closed) return this.off();
    this.buffer.add(a);
  }
  
  void pause(){
    if(this.isDead || this.buffer.paused) return;
      this.buffer.pause();
  }

  void resume(){
    if(this.isDead || !this.buffer.paused) return;
    this.buffer.resume();
  }

  void off(){
    this.cast.off(this.pulse);
    this.buffer.close();
    this.buffer = null;
    this.handler = null;
    this.cast = null;
  }
  
  bool get isDead{
    return (this.cast == null && this.buffer == null);
  }
  
}

class BufferedStream<T> extends Streamer<T>{
  final Streamable stream = new Streamable<T>();
  Streamable _buffer;
  bool _draining = false;
  
  static create() => new BufferedStream();

  BufferedStream();

  void resume(){
    this.stream.resume();
  }

  void pause(){
    this.stream.pause();
  }

  void add(T e){
    if(this.draining) return this._buffer.add(e);
    this.stream.add(e);
  }
  
  void buffer(){
    this._draining = true;
    this.stream.pause();
    this._initBuffer();
  }

  void endBuffer(){
    this.drain();
    this._draining = false;
    this._destroyBuffer();
    this.stream.resume();
  }

  void drain(){
    if(this.drained) return;
    this.stream.pause();
    this._buffer.listen(this.stream.add);
    this._buffer.resume();
  }

  void listen(Function n){
    this.stream.listen(n);
  }
  
  void disconnect(){
    this.stream.disconnect();
  }

  void end(){
    this.stream.end();
  }
  
  void _destroyBuffer(){
    this._buffer.close();
    this._buffer = null;
  }

  void _initBuffer(){
    this._buffer = new Streamable<T>();
    this._buffer.pause();
  }

  void close(){
    this.stream.close();
  }

  void pipe(Streamer s){
    this.stream.pipe(s);
  }

  bool get draining => !!this._draining;
  bool get drained => !this._draining;
}

class Pipes<T>{
  final Streamable<T> stream = new Streamable<T>();
  Broadcasters subscribers;
  String id;

  static create(id,{auto:false}) => new Pipes(id,auto:auto);
  
  Pipes(this.id,{auto:false}){
    this.subscribers = new Broadcasters<T>(this.id);
    this.stream.listen(this.subscribers.propagate);
    if(!auto) this.stream.pause();
  }

  factory Pipes.SingleStream(String id){
    return new Pipes(id,auto:false);
  }
  
  factory Pipes.BroadcastStream(String id){
    return new Pipes(id,auto:true);
  }

  BroadcastListener listen(Function n){
    var subscriber = new BroadcastListener<T>(this.subscribers);
    subscriber.on(n);
    this.stream.resume();
    return subscriber;
  }
  
  void add(T a){
    this.stream.add(a);
  }

  void end(){
    this.stream.end();
  }
  
  void close(){
    this.stream.close();
    this.subscribers.free();
  }
  
  BroadcastListener pipe(Pipes p){
    return this.listen(p.add);
  }

  Future get done => this.streams.done;

}

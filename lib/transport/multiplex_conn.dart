import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:collection';
import 'package:async/async.dart';
import 'package:crypto_chateau_dart/transport/conn.dart';
import 'package:crypto_chateau_dart/transport/message.dart';

class MultiplexConn implements Conn {
  final MultiplexConnPool pool;
  final int _requestID;
  final StreamController<Uint8List> _readController =
      StreamController<Uint8List>();
  final StreamController<void> _closeController = StreamController<void>();
  bool _isClosed = false;

  late Stream<List<int>> broadcastStream;
  late MessageController messageController;
  late Encryption encryption;

  @override
  late Encoding encoding;

  MultiplexConn._(
    this.pool,
    this._requestID,
  );

  @override
  Future<Uint8List> get read async {
    final completer = Completer<Uint8List>();
    StreamSubscription<Uint8List>? subscription;

    subscription ??= _readController.stream.listen((data) {
      completer.complete(data);
      subscription!.cancel();
    });

    return completer.future;
  }

  Stream<void> get onClose => _closeController.stream;

  void addRead(Uint8List data) => _readController.add(data);

  void _addRead(Uint8List data) {
    if (!_isClosed) {
      _readController.add(data);
    }
  }

  Future<void> close() {
    if (!_isClosed) {
      _isClosed = true;
      _readController.close();
      _closeController.add(null);
      _closeController.close();
      pool._removeConn(_requestID);
    }
    return Future.value();
  }

  @override
  void write(Object? obj) {
    if (obj is! List<int>) {
      throw "expected List<int> type in obj";
    }

    List<int> data = obj;
    pool._toWriteQueue.add(_ToWriteMsg(_requestID, Uint8List.fromList(data)));
  }

  @override
  String toString() => 'MultiplexConn($_requestID)';

  @override
  void add(List<int> data) {
    // TODO: implement add
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // TODO: implement addError
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    // TODO: implement addStream
    throw UnimplementedError();
  }

  @override
  // TODO: implement address
  InternetAddress get address => throw UnimplementedError();

  @override
  Future<bool> any(bool Function(Uint8List element) test) {
    // TODO: implement any
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> asBroadcastStream(
      {void Function(StreamSubscription<Uint8List> subscription)? onListen,
      void Function(StreamSubscription<Uint8List> subscription)? onCancel}) {
    // TODO: implement asBroadcastStream
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E>? Function(Uint8List event) convert) {
    // TODO: implement asyncExpand
    throw UnimplementedError();
  }

  @override
  Stream<E> asyncMap<E>(FutureOr<E> Function(Uint8List event) convert) {
    // TODO: implement asyncMap
    throw UnimplementedError();
  }

  @override
  Stream<R> cast<R>() {
    // TODO: implement cast
    throw UnimplementedError();
  }

  @override
  Future<bool> contains(Object? needle) {
    // TODO: implement contains
    throw UnimplementedError();
  }

  @override
  void destroy() {
    // TODO: implement destroy
  }

  @override
  Stream<Uint8List> distinct(
      [bool Function(Uint8List previous, Uint8List next)? equals]) {
    // TODO: implement distinct
    throw UnimplementedError();
  }

  @override
  // TODO: implement done
  Future get done => throw UnimplementedError();

  @override
  Future<E> drain<E>([E? futureValue]) {
    // TODO: implement drain
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> elementAt(int index) {
    // TODO: implement elementAt
    throw UnimplementedError();
  }

  @override
  Future<void> enableEncryption(List<int> sharedKey) {
    // TODO: implement enableEncryption
    throw UnimplementedError();
  }

  @override
  Future<bool> every(bool Function(Uint8List element) test) {
    // TODO: implement every
    throw UnimplementedError();
  }

  @override
  Stream<S> expand<S>(Iterable<S> Function(Uint8List element) convert) {
    // TODO: implement expand
    throw UnimplementedError();
  }

  @override
  // TODO: implement first
  Future<Uint8List> get first => throw UnimplementedError();

  @override
  Future<Uint8List> firstWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    // TODO: implement firstWhere
    throw UnimplementedError();
  }

  @override
  Future flush() {
    // TODO: implement flush
    throw UnimplementedError();
  }

  @override
  Future<S> fold<S>(
      S initialValue, S Function(S previous, Uint8List element) combine) {
    // TODO: implement fold
    throw UnimplementedError();
  }

  @override
  Future forEach(void Function(Uint8List element) action) {
    // TODO: implement forEach
    throw UnimplementedError();
  }

  @override
  Uint8List getRawOption(RawSocketOption option) {
    // TODO: implement getRawOption
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> handleError(Function onError,
      {bool Function(dynamic error)? test}) {
    // TODO: implement handleError
    throw UnimplementedError();
  }

  @override
  // TODO: implement isBroadcast
  bool get isBroadcast => throw UnimplementedError();

  @override
  // TODO: implement isEmpty
  Future<bool> get isEmpty => throw UnimplementedError();

  @override
  Future<String> join([String separator = ""]) {
    // TODO: implement join
    throw UnimplementedError();
  }

  @override
  // TODO: implement last
  Future<Uint8List> get last => throw UnimplementedError();

  @override
  Future<Uint8List> lastWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    // TODO: implement lastWhere
    throw UnimplementedError();
  }

  @override
  // TODO: implement length
  Future<int> get length => throw UnimplementedError();

  @override
  StreamSubscription<Uint8List> listen(void Function(Uint8List event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // TODO: implement listen
    throw UnimplementedError();
  }

  @override
  Stream<S> map<S>(S Function(Uint8List event) convert) {
    // TODO: implement map
    throw UnimplementedError();
  }

  @override
  Future pipe(StreamConsumer<Uint8List> streamConsumer) {
    // TODO: implement pipe
    throw UnimplementedError();
  }

  @override
  // TODO: implement port
  int get port => throw UnimplementedError();

  @override
  Future<Uint8List> reduce(
      Uint8List Function(Uint8List previous, Uint8List element) combine) {
    // TODO: implement reduce
    throw UnimplementedError();
  }

  @override
  // TODO: implement remoteAddress
  InternetAddress get remoteAddress => throw UnimplementedError();

  @override
  // TODO: implement remotePort
  int get remotePort => throw UnimplementedError();

  @override
  bool setOption(SocketOption option, bool enabled) {
    // TODO: implement setOption
    throw UnimplementedError();
  }

  @override
  void setRawOption(RawSocketOption option) {
    // TODO: implement setRawOption
  }

  @override
  // TODO: implement single
  Future<Uint8List> get single => throw UnimplementedError();

  @override
  Future<Uint8List> singleWhere(bool Function(Uint8List element) test,
      {Uint8List Function()? orElse}) {
    // TODO: implement singleWhere
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> skip(int count) {
    // TODO: implement skip
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> skipWhile(bool Function(Uint8List element) test) {
    // TODO: implement skipWhile
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> take(int count) {
    // TODO: implement take
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> takeWhile(bool Function(Uint8List element) test) {
    // TODO: implement takeWhile
    throw UnimplementedError();
  }

  @override
  // TODO: implement tcpConn
  Socket get tcpConn => throw UnimplementedError();

  @override
  Stream<Uint8List> timeout(Duration timeLimit,
      {void Function(EventSink<Uint8List> sink)? onTimeout}) {
    // TODO: implement timeout
    throw UnimplementedError();
  }

  @override
  Future<List<Uint8List>> toList() {
    // TODO: implement toList
    throw UnimplementedError();
  }

  @override
  Future<Set<Uint8List>> toSet() {
    // TODO: implement toSet
    throw UnimplementedError();
  }

  @override
  Stream<S> transform<S>(StreamTransformer<Uint8List, S> streamTransformer) {
    // TODO: implement transform
    throw UnimplementedError();
  }

  @override
  Stream<Uint8List> where(bool Function(Uint8List event) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    // TODO: implement writeAll
  }

  @override
  void writeCharCode(int charCode) {
    // TODO: implement writeCharCode
  }

  @override
  void writeln([Object? object = ""]) {
    // TODO: implement writeln
  }
}

class MultiplexConnPool {
  final Conn conn;
  final StreamController<MultiplexConn> _listenClients =
      StreamController<MultiplexConn>();
  final Map<int, MultiplexConn> _multiplexConnByRequestID = {};
  final ListQueue<_ToWriteMsg> _toWriteQueue = ListQueue<_ToWriteMsg>();
  final Completer<void> _terminateCh = Completer();
  final bool _isClient;

  int _currentRequestID = 0;

  MultiplexConnPool(this.conn, this._isClient);

  int get currentRequestID => _currentRequestID;

  MultiplexConn newMultiplexConn() {
    final requestID = ++_currentRequestID;
    final newMultiplexConn = MultiplexConn._(
      this,
      requestID,
    );
    _multiplexConnByRequestID[requestID] = newMultiplexConn;
    if (!_isClient) {
      _listenClients.add(newMultiplexConn);
    }
    return newMultiplexConn;
  }

  void close() => _terminateCh.complete();

  Stream<MultiplexConn> listenClients() => _listenClients.stream;

  void run() {
    _listenToTCP();
    _writeToTCP();
  }

  void _removeConn(int requestID) {
    _multiplexConnByRequestID.remove(requestID);
  }

  void _listenToTCP() async {
    final completer = Completer<void>();
    final buffer = Uint8List(4096);
    Uint8List data = Uint8List.fromList(await conn.read);
    buffer.setRange(0, data.length, data);
    var requestID = (buffer[0] & 0xff) | ((buffer[1] & 0xff) << 8);
    if (_multiplexConnByRequestID.containsKey(requestID)) {
      var conn = _multiplexConnByRequestID[requestID];
      conn!._addRead(buffer.sublist(2, data.length));
    } else {
      print('Unknown request ID: $requestID');
    }
  }

  void closeAllConns() {
    var conns = _multiplexConnByRequestID.values.toList();
    for (var conn in conns) {
      conn.close();
    }
    _listenClients.close();
  }

  void _writeToTCP() {
    if (_terminateCh.isCompleted) {
      return;
    }

    if (_toWriteQueue.isNotEmpty) {
      final msg = _toWriteQueue.removeFirst();
      final data = msg.data;
      final requestID = msg.requestID;
      final len = data.length;
      final header = Uint8List(2);
      header[0] = (requestID >> 0) & 0xFF;
      header[1] = (requestID >> 8) & 0xFF;
      final toSend = header.followedBy(data);
      conn.write(toSend.toList());
    }

    Future.delayed(Duration(milliseconds: 50)).then((_) => _writeToTCP());
  }

  void _closeTCP() {
    conn.destroy();
  }

  void _closeAllConns() {
    var conns = _multiplexConnByRequestID.values.toList();
    for (var conn in conns) {
      conn.close();
    }
    _listenClients.close();
  }
}

class _ToWriteMsg {
  final int requestID;
  final Uint8List data;

  _ToWriteMsg(this.requestID, this.data);
}

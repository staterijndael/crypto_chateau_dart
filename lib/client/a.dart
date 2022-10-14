import 'package:crypto_chateau_dart/transport/conn_bloc.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:crypto_chateau_dart/client/models.dart';
import 'package:crypto_chateau_dart/client/conv.dart';
import 'package:crypto_chateau_dart/client/client.dart';

class ConnectParams {
  String host;
  int port;
  bool isEncryptionEnabled;

  ConnectParams(
      {required this.host,
      required this.port,
      required this.isEncryptionEnabled});
}

class Client {
	ConnectParams connectParams;

	Client({required this.connectParams});

// handlers

	Future<SendCodeResponse> SendCode(SendCodeRequest request) async {
			SendCodeResponse res = SendCodeResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("SendCode", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<HandleCodeResponse> HandleCode(HandleCodeRequest request) async {
			HandleCodeResponse res = HandleCodeResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("HandleCode", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<RequiredOPKResponse> RequiredOPK(RequiredOPKRequest request) async {
			RequiredOPKResponse res = RequiredOPKResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("RequiredOPK", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<LoadOPKResponse> LoadOPK(LoadOPKRequest request) async {
			LoadOPKResponse res = LoadOPKResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("LoadOPK", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<FindUsersByPartNicknameResponse> FindUsersByPartNickname(FindUsersByPartNicknameRequest request) async {
			FindUsersByPartNicknameResponse res = FindUsersByPartNicknameResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("FindUsersByPartNickname", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<GetInitMsgKeysResponse> GetInitMsgKeys(GetInitMsgKeysRequest request) async {
			GetInitMsgKeysResponse res = GetInitMsgKeysResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("GetInitMsgKeys", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<RegisterResponse> Register(RegisterRequest request) async {
			RegisterResponse res = RegisterResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("Register", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<AuthTokenResponse> AuthToken(AuthTokenRequest request) async {
			AuthTokenResponse res = AuthTokenResponse();
			Uint8List decoratedMsg = decorateRawDataByHandlerName("AuthToken", request.Marshal());
			Uint8List rawResponse = await handleMessage(decoratedMsg);
			Map<String, Uint8List> params = GetParams(rawResponse)[1];
			res.Unmarshal(params);
			return res;
	}

	Future<void Function(SendMessage msg)> AuthCredentials(void Function() onEncryptEnabled, void Function(AuthCredentialsResponse msg) onGotMessage, AuthCredentialsRequest initMessage) {
		return ListenUpdates("AuthCredentials", onEncryptEnabled, AuthCredentialsResponse(), onGotMessage, initMessage);
	}

  Future<Uint8List> handleMessage(Uint8List data) async {
    TcpBloc tcpBloc = TcpBloc();

    onEncryptEnabled() {
      tcpBloc.sendMessage(SendMessage(message: data));
    }

    StreamController streamController = StreamController();

    Stream responseStream = streamController.stream;

    tcpBloc.connect(
        onEncryptEnabled,
        streamController,
        Connect(
            host: connectParams.host,
            port: connectParams.port,
            encryptionEnabled: connectParams.isEncryptionEnabled));

    var firstValueReceived = Completer<Uint8List>();

    responseStream.listen((event) {
      if (!firstValueReceived.isCompleted) {
        firstValueReceived.complete(event);
      }
    });

    Uint8List rawResponse = await firstValueReceived.future;

    tcpBloc.close();

    return rawResponse;
  }

  Future<void Function(SendMessage msg)> ListenUpdates<T>(
      String handlerName,
      void Function() onEncryptEnabled,
      T respType,
      void Function(T msg) onGotMessage,
      Message initMessage) async {
    TcpBloc tcpBloc = TcpBloc();
    StreamController streamController = StreamController();

    onEncryptEnabled() {
      Uint8List decoratedMsg =
          decorateRawDataByHandlerName(handlerName, initMessage.Marshal());
      tcpBloc.sendMessage(SendMessage(message: decoratedMsg));

      onEncryptEnabled();

      streamController.stream.listen((event) async {
        var futureValueReceived = Completer<Uint8List>();
        futureValueReceived.complete(event);

        Uint8List gotMessage = await futureValueReceived.future;

        Map<String, Uint8List> params = GetParams(gotMessage)[1];
        (respType as Message).Unmarshal(params);

        onGotMessage(respType);
      });
    }

    onSendMessage(SendMessage msg) {
      tcpBloc.sendMessage(msg);
    }

    tcpBloc.connect(
        onEncryptEnabled,
        streamController,
        Connect(
            host: connectParams.host,
            port: connectParams.port,
            encryptionEnabled: connectParams.isEncryptionEnabled));

    return onSendMessage;
  }

}

class SendCodeRequest extends Message { 
	String? number; 

	SendCodeRequest({this.number});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartnumber = List.empty(growable: true);
		resultDartnumber.addAll(ConvertStringToBytes(number!));
		buf.addAll(resultDartnumber);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		number = ConvertBytesToString(params["number"]!);
	}

}

class SendCodeResponse extends Message { 

	SendCodeResponse();

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
	}

}

class HandleCodeRequest extends Message { 
	String? number; 
	int? code; 

	HandleCodeRequest({this.number, this.code});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartnumber = List.empty(growable: true);
		resultDartnumber.addAll(ConvertStringToBytes(number!));
		buf.addAll(resultDartnumber);
		buf.addAll(','.codeUnits);
		List<int> resultDartcode = List.empty(growable: true);
		resultDartcode.addAll(ConvertUint8ToBytes(code!));
		buf.addAll(resultDartcode);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		number = ConvertBytesToString(params["number"]!);
		code = ConvertBytesToUint8(params["code"]!);
	}

}

class HandleCodeResponse extends Message { 

	HandleCodeResponse();

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
	}

}

class RequiredOPKRequest extends Message { 
	// arr max elements count: 16
	List<int>? sessionToken; 

	RequiredOPKRequest({this.sessionToken});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartsessionToken = List.empty(growable: true);
		resultDartsessionToken.addAll('['.codeUnits);
		for (int i = 0; i < sessionToken!.length; i++) {
			var val = sessionToken![i];
			resultDartsessionToken.addAll(ConvertByteToBytes(val));
			if (i != sessionToken!.length - 1) {
				resultDartsessionToken.addAll(','.codeUnits);
			}
		}
		resultDartsessionToken.addAll(']'.codeUnits);

		buf.addAll(resultDartsessionToken);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arrsessionToken = GetArray(params["sessionToken"]!)[1];
		for (int i = 0;i < arrsessionToken.length; i++) {
			var valByte = arrsessionToken[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			sessionToken!.add(curVal);
		}
	}

}

class RequiredOPKResponse extends Message { 
	int? count; 

	RequiredOPKResponse({this.count});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartcount = List.empty(growable: true);
		resultDartcount.addAll(ConvertUint16ToBytes(count!));
		buf.addAll(resultDartcount);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		count = ConvertBytesToUint16(params["count"]!);
	}

}

class LoadOPKRequest extends Message { 
	// arr max elements count: 16
	List<int>? sessionToken; 
	List<OPKPair>? oPK; 

	LoadOPKRequest({this.sessionToken, this.oPK});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartsessionToken = List.empty(growable: true);
		resultDartsessionToken.addAll('['.codeUnits);
		for (int i = 0; i < sessionToken!.length; i++) {
			var val = sessionToken![i];
			resultDartsessionToken.addAll(ConvertByteToBytes(val));
			if (i != sessionToken!.length - 1) {
				resultDartsessionToken.addAll(','.codeUnits);
			}
		}
		resultDartsessionToken.addAll(']'.codeUnits);

		buf.addAll(resultDartsessionToken);
		buf.addAll(','.codeUnits);
		List<int> resultDartoPK = List.empty(growable: true);
		resultDartoPK.addAll('['.codeUnits);
		for (int i = 0; i < oPK!.length; i++) {
			var val = oPK![i];
			resultDartoPK.addAll(ConvertObjectToBytes(val));
			if (i != oPK!.length - 1) {
				resultDartoPK.addAll(','.codeUnits);
			}
		}
		resultDartoPK.addAll(']'.codeUnits);

		buf.addAll(resultDartoPK);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arrsessionToken = GetArray(params["sessionToken"]!)[1];
		for (int i = 0;i < arrsessionToken.length; i++) {
			var valByte = arrsessionToken[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			sessionToken!.add(curVal);
		}
			var arr = GetArray(params["oPK"]!)[1];
			for (int i = 0; i < arr.length; i++) {
			Uint8List objBytes = arr[i];
			OPKPair curObj = new OPKPair();
			ConvertBytesToObject(curObj,objBytes);
			oPK!.add(curObj);
	}
	}

}

class OPKPair extends Message { 
	int? oPKId; 
	// arr max elements count: 32
	List<int>? oPK; 

	OPKPair({this.oPKId, this.oPK});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartoPKId = List.empty(growable: true);
		resultDartoPKId.addAll(ConvertUint32ToBytes(oPKId!));
		buf.addAll(resultDartoPKId);
		buf.addAll(','.codeUnits);
		List<int> resultDartoPK = List.empty(growable: true);
		resultDartoPK.addAll('['.codeUnits);
		for (int i = 0; i < oPK!.length; i++) {
			var val = oPK![i];
			resultDartoPK.addAll(ConvertByteToBytes(val));
			if (i != oPK!.length - 1) {
				resultDartoPK.addAll(','.codeUnits);
			}
		}
		resultDartoPK.addAll(']'.codeUnits);

		buf.addAll(resultDartoPK);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		oPKId = ConvertBytesToUint32(params["oPKId"]!);
		var arroPK = GetArray(params["oPK"]!)[1];
		for (int i = 0;i < arroPK.length; i++) {
			var valByte = arroPK[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			oPK!.add(curVal);
		}
	}

}

class LoadOPKResponse extends Message { 

	LoadOPKResponse();

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
	}

}

class FindUsersByPartNicknameRequest extends Message { 
	String? partNickname; 

	FindUsersByPartNicknameRequest({this.partNickname});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartpartNickname = List.empty(growable: true);
		resultDartpartNickname.addAll(ConvertStringToBytes(partNickname!));
		buf.addAll(resultDartpartNickname);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		partNickname = ConvertBytesToString(params["partNickname"]!);
	}

}

class FindUsersByPartNicknameResponse extends Message { 
	List<PresentUser>? users; 

	FindUsersByPartNicknameResponse({this.users});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartusers = List.empty(growable: true);
		resultDartusers.addAll('['.codeUnits);
		for (int i = 0; i < users!.length; i++) {
			var val = users![i];
			resultDartusers.addAll(ConvertObjectToBytes(val));
			if (i != users!.length - 1) {
				resultDartusers.addAll(','.codeUnits);
			}
		}
		resultDartusers.addAll(']'.codeUnits);

		buf.addAll(resultDartusers);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
			var arr = GetArray(params["users"]!)[1];
			for (int i = 0; i < arr.length; i++) {
			Uint8List objBytes = arr[i];
			PresentUser curObj = new PresentUser();
			ConvertBytesToObject(curObj,objBytes);
			users!.add(curObj);
	}
	}

}

class PresentUser extends Message { 
	// arr max elements count: 32
	List<int>? identityKey; 
	String? nickname; 
	String? pictureID; 
	String? status; 

	PresentUser({this.identityKey, this.nickname, this.pictureID, this.status});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartidentityKey = List.empty(growable: true);
		resultDartidentityKey.addAll('['.codeUnits);
		for (int i = 0; i < identityKey!.length; i++) {
			var val = identityKey![i];
			resultDartidentityKey.addAll(ConvertByteToBytes(val));
			if (i != identityKey!.length - 1) {
				resultDartidentityKey.addAll(','.codeUnits);
			}
		}
		resultDartidentityKey.addAll(']'.codeUnits);

		buf.addAll(resultDartidentityKey);
		buf.addAll(','.codeUnits);
		List<int> resultDartnickname = List.empty(growable: true);
		resultDartnickname.addAll(ConvertStringToBytes(nickname!));
		buf.addAll(resultDartnickname);
		buf.addAll(','.codeUnits);
		List<int> resultDartpictureID = List.empty(growable: true);
		resultDartpictureID.addAll(ConvertStringToBytes(pictureID!));
		buf.addAll(resultDartpictureID);
		buf.addAll(','.codeUnits);
		List<int> resultDartstatus = List.empty(growable: true);
		resultDartstatus.addAll(ConvertStringToBytes(status!));
		buf.addAll(resultDartstatus);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arridentityKey = GetArray(params["identityKey"]!)[1];
		for (int i = 0;i < arridentityKey.length; i++) {
			var valByte = arridentityKey[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			identityKey!.add(curVal);
		}
		nickname = ConvertBytesToString(params["nickname"]!);
		pictureID = ConvertBytesToString(params["pictureID"]!);
		status = ConvertBytesToString(params["status"]!);
	}

}

class GetInitMsgKeysRequest extends Message { 
	// arr max elements count: 16
	List<int>? sessionToken; 
	// arr max elements count: 32
	List<int>? identityKey; 

	GetInitMsgKeysRequest({this.sessionToken, this.identityKey});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartsessionToken = List.empty(growable: true);
		resultDartsessionToken.addAll('['.codeUnits);
		for (int i = 0; i < sessionToken!.length; i++) {
			var val = sessionToken![i];
			resultDartsessionToken.addAll(ConvertByteToBytes(val));
			if (i != sessionToken!.length - 1) {
				resultDartsessionToken.addAll(','.codeUnits);
			}
		}
		resultDartsessionToken.addAll(']'.codeUnits);

		buf.addAll(resultDartsessionToken);
		buf.addAll(','.codeUnits);
		List<int> resultDartidentityKey = List.empty(growable: true);
		resultDartidentityKey.addAll('['.codeUnits);
		for (int i = 0; i < identityKey!.length; i++) {
			var val = identityKey![i];
			resultDartidentityKey.addAll(ConvertByteToBytes(val));
			if (i != identityKey!.length - 1) {
				resultDartidentityKey.addAll(','.codeUnits);
			}
		}
		resultDartidentityKey.addAll(']'.codeUnits);

		buf.addAll(resultDartidentityKey);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arrsessionToken = GetArray(params["sessionToken"]!)[1];
		for (int i = 0;i < arrsessionToken.length; i++) {
			var valByte = arrsessionToken[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			sessionToken!.add(curVal);
		}
		var arridentityKey = GetArray(params["identityKey"]!)[1];
		for (int i = 0;i < arridentityKey.length; i++) {
			var valByte = arridentityKey[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			identityKey!.add(curVal);
		}
	}

}

class GetInitMsgKeysResponse extends Message { 
	int? oPKId; 
	// arr max elements count: 32
	List<int>? oPK; 
	// arr max elements count: 32
	List<int>? signedLTPK; 
	// arr max elements count: 64
	List<int>? signature; 

	GetInitMsgKeysResponse({this.oPKId, this.oPK, this.signedLTPK, this.signature});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartoPKId = List.empty(growable: true);
		resultDartoPKId.addAll(ConvertUint32ToBytes(oPKId!));
		buf.addAll(resultDartoPKId);
		buf.addAll(','.codeUnits);
		List<int> resultDartoPK = List.empty(growable: true);
		resultDartoPK.addAll('['.codeUnits);
		for (int i = 0; i < oPK!.length; i++) {
			var val = oPK![i];
			resultDartoPK.addAll(ConvertByteToBytes(val));
			if (i != oPK!.length - 1) {
				resultDartoPK.addAll(','.codeUnits);
			}
		}
		resultDartoPK.addAll(']'.codeUnits);

		buf.addAll(resultDartoPK);
		buf.addAll(','.codeUnits);
		List<int> resultDartsignedLTPK = List.empty(growable: true);
		resultDartsignedLTPK.addAll('['.codeUnits);
		for (int i = 0; i < signedLTPK!.length; i++) {
			var val = signedLTPK![i];
			resultDartsignedLTPK.addAll(ConvertByteToBytes(val));
			if (i != signedLTPK!.length - 1) {
				resultDartsignedLTPK.addAll(','.codeUnits);
			}
		}
		resultDartsignedLTPK.addAll(']'.codeUnits);

		buf.addAll(resultDartsignedLTPK);
		buf.addAll(','.codeUnits);
		List<int> resultDartsignature = List.empty(growable: true);
		resultDartsignature.addAll('['.codeUnits);
		for (int i = 0; i < signature!.length; i++) {
			var val = signature![i];
			resultDartsignature.addAll(ConvertByteToBytes(val));
			if (i != signature!.length - 1) {
				resultDartsignature.addAll(','.codeUnits);
			}
		}
		resultDartsignature.addAll(']'.codeUnits);

		buf.addAll(resultDartsignature);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		oPKId = ConvertBytesToUint32(params["oPKId"]!);
		var arroPK = GetArray(params["oPK"]!)[1];
		for (int i = 0;i < arroPK.length; i++) {
			var valByte = arroPK[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			oPK!.add(curVal);
		}
		var arrsignedLTPK = GetArray(params["signedLTPK"]!)[1];
		for (int i = 0;i < arrsignedLTPK.length; i++) {
			var valByte = arrsignedLTPK[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			signedLTPK!.add(curVal);
		}
		var arrsignature = GetArray(params["signature"]!)[1];
		for (int i = 0;i < arrsignature.length; i++) {
			var valByte = arrsignature[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			signature!.add(curVal);
		}
	}

}

class RegisterRequest extends Message { 
	String? number; 
	int? code; 
	String? nickname; 
	String? passHash; 
	String? deviceID; 
	String? deviceName; 
	// arr max elements count: 32
	List<int>? lTPK; 
	// arr max elements count: 64
	List<int>? lTPKSignature; 
	// arr max elements count: 32
	List<int>? identityKey; 

	RegisterRequest({this.number, this.code, this.nickname, this.passHash, this.deviceID, this.deviceName, this.lTPK, this.lTPKSignature, this.identityKey});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartnumber = List.empty(growable: true);
		resultDartnumber.addAll(ConvertStringToBytes(number!));
		buf.addAll(resultDartnumber);
		buf.addAll(','.codeUnits);
		List<int> resultDartcode = List.empty(growable: true);
		resultDartcode.addAll(ConvertUint8ToBytes(code!));
		buf.addAll(resultDartcode);
		buf.addAll(','.codeUnits);
		List<int> resultDartnickname = List.empty(growable: true);
		resultDartnickname.addAll(ConvertStringToBytes(nickname!));
		buf.addAll(resultDartnickname);
		buf.addAll(','.codeUnits);
		List<int> resultDartpassHash = List.empty(growable: true);
		resultDartpassHash.addAll(ConvertStringToBytes(passHash!));
		buf.addAll(resultDartpassHash);
		buf.addAll(','.codeUnits);
		List<int> resultDartdeviceID = List.empty(growable: true);
		resultDartdeviceID.addAll(ConvertStringToBytes(deviceID!));
		buf.addAll(resultDartdeviceID);
		buf.addAll(','.codeUnits);
		List<int> resultDartdeviceName = List.empty(growable: true);
		resultDartdeviceName.addAll(ConvertStringToBytes(deviceName!));
		buf.addAll(resultDartdeviceName);
		buf.addAll(','.codeUnits);
		List<int> resultDartlTPK = List.empty(growable: true);
		resultDartlTPK.addAll('['.codeUnits);
		for (int i = 0; i < lTPK!.length; i++) {
			var val = lTPK![i];
			resultDartlTPK.addAll(ConvertByteToBytes(val));
			if (i != lTPK!.length - 1) {
				resultDartlTPK.addAll(','.codeUnits);
			}
		}
		resultDartlTPK.addAll(']'.codeUnits);

		buf.addAll(resultDartlTPK);
		buf.addAll(','.codeUnits);
		List<int> resultDartlTPKSignature = List.empty(growable: true);
		resultDartlTPKSignature.addAll('['.codeUnits);
		for (int i = 0; i < lTPKSignature!.length; i++) {
			var val = lTPKSignature![i];
			resultDartlTPKSignature.addAll(ConvertByteToBytes(val));
			if (i != lTPKSignature!.length - 1) {
				resultDartlTPKSignature.addAll(','.codeUnits);
			}
		}
		resultDartlTPKSignature.addAll(']'.codeUnits);

		buf.addAll(resultDartlTPKSignature);
		buf.addAll(','.codeUnits);
		List<int> resultDartidentityKey = List.empty(growable: true);
		resultDartidentityKey.addAll('['.codeUnits);
		for (int i = 0; i < identityKey!.length; i++) {
			var val = identityKey![i];
			resultDartidentityKey.addAll(ConvertByteToBytes(val));
			if (i != identityKey!.length - 1) {
				resultDartidentityKey.addAll(','.codeUnits);
			}
		}
		resultDartidentityKey.addAll(']'.codeUnits);

		buf.addAll(resultDartidentityKey);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		number = ConvertBytesToString(params["number"]!);
		code = ConvertBytesToUint8(params["code"]!);
		nickname = ConvertBytesToString(params["nickname"]!);
		passHash = ConvertBytesToString(params["passHash"]!);
		deviceID = ConvertBytesToString(params["deviceID"]!);
		deviceName = ConvertBytesToString(params["deviceName"]!);
		var arrlTPK = GetArray(params["lTPK"]!)[1];
		for (int i = 0;i < arrlTPK.length; i++) {
			var valByte = arrlTPK[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			lTPK!.add(curVal);
		}
		var arrlTPKSignature = GetArray(params["lTPKSignature"]!)[1];
		for (int i = 0;i < arrlTPKSignature.length; i++) {
			var valByte = arrlTPKSignature[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			lTPKSignature!.add(curVal);
		}
		var arridentityKey = GetArray(params["identityKey"]!)[1];
		for (int i = 0;i < arridentityKey.length; i++) {
			var valByte = arridentityKey[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			identityKey!.add(curVal);
		}
	}

}

class RegisterResponse extends Message { 
	// arr max elements count: 16
	List<int>? sessionToken; 

	RegisterResponse({this.sessionToken});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartsessionToken = List.empty(growable: true);
		resultDartsessionToken.addAll('['.codeUnits);
		for (int i = 0; i < sessionToken!.length; i++) {
			var val = sessionToken![i];
			resultDartsessionToken.addAll(ConvertByteToBytes(val));
			if (i != sessionToken!.length - 1) {
				resultDartsessionToken.addAll(','.codeUnits);
			}
		}
		resultDartsessionToken.addAll(']'.codeUnits);

		buf.addAll(resultDartsessionToken);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arrsessionToken = GetArray(params["sessionToken"]!)[1];
		for (int i = 0;i < arrsessionToken.length; i++) {
			var valByte = arrsessionToken[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			sessionToken!.add(curVal);
		}
	}

}

class AuthTokenRequest extends Message { 
	// arr max elements count: 16
	List<int>? sessionToken; 

	AuthTokenRequest({this.sessionToken});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartsessionToken = List.empty(growable: true);
		resultDartsessionToken.addAll('['.codeUnits);
		for (int i = 0; i < sessionToken!.length; i++) {
			var val = sessionToken![i];
			resultDartsessionToken.addAll(ConvertByteToBytes(val));
			if (i != sessionToken!.length - 1) {
				resultDartsessionToken.addAll(','.codeUnits);
			}
		}
		resultDartsessionToken.addAll(']'.codeUnits);

		buf.addAll(resultDartsessionToken);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arrsessionToken = GetArray(params["sessionToken"]!)[1];
		for (int i = 0;i < arrsessionToken.length; i++) {
			var valByte = arrsessionToken[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			sessionToken!.add(curVal);
		}
	}

}

class AuthTokenResponse extends Message { 
	// arr max elements count: 16
	List<int>? sessionToken; 

	AuthTokenResponse({this.sessionToken});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartsessionToken = List.empty(growable: true);
		resultDartsessionToken.addAll('['.codeUnits);
		for (int i = 0; i < sessionToken!.length; i++) {
			var val = sessionToken![i];
			resultDartsessionToken.addAll(ConvertByteToBytes(val));
			if (i != sessionToken!.length - 1) {
				resultDartsessionToken.addAll(','.codeUnits);
			}
		}
		resultDartsessionToken.addAll(']'.codeUnits);

		buf.addAll(resultDartsessionToken);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arrsessionToken = GetArray(params["sessionToken"]!)[1];
		for (int i = 0;i < arrsessionToken.length; i++) {
			var valByte = arrsessionToken[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			sessionToken!.add(curVal);
		}
	}

}

class AuthCredentialsRequest extends Message { 
	String? number; 
	String? passHash; 

	AuthCredentialsRequest({this.number, this.passHash});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartnumber = List.empty(growable: true);
		resultDartnumber.addAll(ConvertStringToBytes(number!));
		buf.addAll(resultDartnumber);
		buf.addAll(','.codeUnits);
		List<int> resultDartpassHash = List.empty(growable: true);
		resultDartpassHash.addAll(ConvertStringToBytes(passHash!));
		buf.addAll(resultDartpassHash);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		number = ConvertBytesToString(params["number"]!);
		passHash = ConvertBytesToString(params["passHash"]!);
	}

}

class AuthCredentialsResponse extends Message { 
	// arr max elements count: 16
	List<int>? sessionToken; 

	AuthCredentialsResponse({this.sessionToken});

	Uint8List Marshal() {
		List<int> buf = List.empty(growable: true);
		buf.addAll('{'.codeUnits);
		List<int> resultDartsessionToken = List.empty(growable: true);
		resultDartsessionToken.addAll('['.codeUnits);
		for (int i = 0; i < sessionToken!.length; i++) {
			var val = sessionToken![i];
			resultDartsessionToken.addAll(ConvertByteToBytes(val));
			if (i != sessionToken!.length - 1) {
				resultDartsessionToken.addAll(','.codeUnits);
			}
		}
		resultDartsessionToken.addAll(']'.codeUnits);

		buf.addAll(resultDartsessionToken);
		buf.addAll('}'.codeUnits);
		return Uint8List.fromList(buf);
 }

	Unmarshal(Map<String, Uint8List> params) {
		var arrsessionToken = GetArray(params["sessionToken"]!)[1];
		for (int i = 0;i < arrsessionToken.length; i++) {
			var valByte = arrsessionToken[i];			int curVal;
			curVal = ConvertBytesToByte(valByte);
			sessionToken!.add(curVal);
		}
	}

}


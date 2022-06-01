import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto_chateau_dart/client/models.dart';

Uint8List WaitResponse(Map<String, Uint8List> waitReponseMap, String methodName,int maxTimerDifference){
  var startTime = DateTime.now().millisecondsSinceEpoch;
  while (true){
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - startTime > maxTimerDifference){
      throw "response did not received";
    }

    if (waitReponseMap.containsKey(methodName)){
      return waitReponseMap[methodName]!;
    }
  }
}

dynamic GetResponse(String methodName, Uint8List data){
  Map<String, Uint8List> params = getParams(data);

  switch(methodName){
    case "GetUser":
      checkCountParams(1, params.length);
      return GetUserResponse(userName: String.fromCharCodes(params["UserName"]!));
  }
}

checkCountParams(int assertCount, int actualCount){
  if (assertCount != actualCount){
    throw "incorrect params nums";
  }
}

Map<String, Uint8List> getParams(Uint8List p) {
	Map<String, Uint8List> params = {};

	Uint8List paramBuf = Uint8List(p.length);
	Uint8List valueBuf = Uint8List(p.length);

  int paramBufLast = 0;
  int valueBufLast = 0;
  int paramBufIndex = 0;
  int valueBufIndex = 0;

	bool paramFilled = false;

  int delimSymb = utf8.encode(',')[0];
  int colonSymb = utf8.encode(':')[0];
  int spaceSymb = utf8.encode(' ')[0];

	for (var i = 0; i < p.length; i++) {
		if (p[i] == delimSymb || i == p.length-1) {
			if ((i != p.length-1) && (p[i+1] == delimSymb)) {
				continue;
			}

			if (i == p.length-1) {
				valueBuf[valueBufIndex] = p[i];
        valueBufIndex++;
			}

			if (paramBuf.isNotEmpty && valueBuf.isNotEmpty) {
        String param = String.fromCharCodes(paramBuf.sublist(paramBufLast+1,paramBuf.length));
        Uint8List value = valueBuf.sublist(valueBufLast+1,valueBuf.length); 
				params[param] = value;

        paramBufLast = i;
				paramFilled = false;
			}
		} else if (p[i] == colonSymb) {
      valueBufLast = i;
			paramFilled = true;
		} else if (p[i] == spaceSymb) {
			continue;
		} else {
			if (!paramFilled) {
				paramBuf[paramBufIndex] = p[i];
        paramBufIndex++;
			} else {
				valueBuf[valueBufIndex] = p[i];
        valueBufIndex++;
			}
		}
	}

	if (paramBuf.isNotEmpty || valueBuf.isNotEmpty) {
		throw "incorrect message format";
	}

	return params;
}
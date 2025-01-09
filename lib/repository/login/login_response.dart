import 'dart:convert';

class xdLoginResponse{
  xdLoginResponse({
    required this.token,
  });

  String token;


  factory xdLoginResponse.fromRawJson(String str) =>
      xdLoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory xdLoginResponse.fromJson(Map<String, dynamic> json) => xdLoginResponse(
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "token": token,
  };
}

part of '../kakao_map_sdk.dart';

enum ChannelType {
  sdk("${_baseChannelId}_sdk"),
  overlay("${_baseChannelId}_overlay"),
  view("${_baseChannelId}_view");

  final String id;

  MethodChannel get channel => MethodChannel(id);
  MethodChannel channelWithId(int id) => MethodChannel("${this.id}#$id");

  MethodChannel channelWithParam(
          [codec = const StandardMethodCodec(),
          BinaryMessenger? binaryMessenger]) =>
      MethodChannel(id, codec, binaryMessenger);

  MethodChannel channelWithParamAndId(int id,
          [codec = const StandardMethodCodec(),
          BinaryMessenger? binaryMessenger]) =>
      MethodChannel("${this.id}#$id", codec, binaryMessenger);

  const ChannelType(this.id);

  static const String _baseChannelId = "flutter_kakao_maps";
}

import 'package:json_annotation/json_annotation.dart';

part 'electricity.g.dart';

@JsonSerializable()
class ElectricityInfo {
  DateTime fetchDay;
  String remain;
  String owe;
  String lastCharge;
  String lastChargeAmount;
  DateTime lastChargeTime;
  String lastChargeBalance;
  String monthUsage;

  ElectricityInfo({
    required this.fetchDay,
    required this.remain,
    required this.owe,
    required this.lastCharge,
    required this.lastChargeAmount,
    required this.lastChargeTime,
    required this.lastChargeBalance,
    required this.monthUsage,
  });

  factory ElectricityInfo.empty(DateTime time) =>
      ElectricityInfo(
        fetchDay: time,
        remain: "electricity_status.pending",
        owe: "electricity_status.pending",
        lastCharge: "electricity_status.pending",
        lastChargeAmount: "electricity_status.pending",
        lastChargeTime: time,
        lastChargeBalance: "electricity_status.pending",
        monthUsage: "electricity_status.pending",
      );

  factory ElectricityInfo.fromJson(Map<String, dynamic> json) =>
      _$ElectricityInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ElectricityInfoToJson(this);
}

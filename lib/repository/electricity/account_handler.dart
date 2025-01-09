// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

class AccountHandler {
  String getElectricityAccount(String dorm) {
    if (dorm.isEmpty) throw NoAccountInfoException();
    if (RegExp(r'^\d+$').hasMatch(dorm)) return dorm;

    final nums = RegExp(r'[0-9]+').allMatches(dorm).toList();
    if (nums.isEmpty) throw InvalidDormFormatException();

    // 校区编号：北校区=1，南校区=2
    final areaCode = dorm.contains('北校区') ? '1' : '2';
    
    // 楼号
    final building = nums[0][0]!;
    final buildingCode = building.padLeft(3, '0');

    // 根据不同校区和楼号处理区号和房间号
    String zoneCode = '00';  // 区号
    String roomCode = '0000';  // 房间号
    String verifyCode = '';  // 识别码

    if (areaCode == '2') {  // 南校区
      _handleSouthCampus(dorm, nums, building, (z, r) {
        zoneCode = z;
        roomCode = r;
      });
    } else {  // 北校区
      _handleNorthCampus(dorm, nums, building, (z, r, v) {
        zoneCode = z;
        roomCode = r;
        verifyCode = v;
      });
    }

    return areaCode + buildingCode + zoneCode + roomCode + verifyCode;
  }

  void _handleSouthCampus(
    String dorm,
    List<RegExpMatch> nums,
    String building,
    Function(String zone, String room) callback,
  ) {
    final buildingNum = int.parse(building);
    String zone = '00';
    String room = '0000';

    if ([1, 2, 3, 4].contains(buildingNum)) {
      zone = nums[2][0]! + nums[1][0]!;
      room = nums[3][0]!.padLeft(4, '0');
    } else if ([5, 8, 9, 10, 11, 12, 14].contains(buildingNum)) {
      zone = nums[2][0]!.padLeft(2, '0');
      room = nums[3][0]!.padLeft(4, nums[2][0]!);
    } else if ([6, 7].contains(buildingNum)) {
      zone = '00';
      room = nums[2][0]!.padLeft(4, '0');
    } else if ([13, 15].contains(buildingNum)) {
      zone = '01';
      room = nums[2][0]!.padLeft(4, '1');
    } else if ([19, 20, 21, 22].contains(buildingNum)) {
      zone = '01';
      room = nums[2][0]!.padLeft(4, nums[1][0]!);
    } else if (buildingNum == 18) {
      zone = dorm.contains('南楼') ? '10' : '20';
      room = nums[2][0]!.padLeft(4, nums[1][0]!);
    }

    callback(zone, room);
  }

  void _handleNorthCampus(
    String dorm,
    List<RegExpMatch> nums,
    String building,
    Function(String zone, String room, String verify) callback,
  ) {
    final buildingNum = int.parse(building);
    String zone = '00';
    String room = '0000';
    String verify = '';

    // 处理识别码
    if ([4, 24, 47, 48, 49, 51, 52, 53, 55].contains(buildingNum)) {
      verify = dorm.contains('南院') ? '1' : '2';
    } else if (buildingNum == 11) {
      verify = dorm.contains('南院') ? '2' : '1';
    }

    if ([21, 24, 28, 47, 48, 49, 51, 52, 53, 55].contains(buildingNum)) {
      if (verify != '1') {
        zone = nums[1][0]!.padLeft(2, '0');
        room = nums[2][0]!.length == 1
            ? nums[3][0]!.padLeft(4, '0')
            : nums[2][0]!.padLeft(4, '0');
      } else {
        zone = nums[1][0]!.padLeft(2, '0');
        room = nums[3][0]!.padLeft(4, '0');
      }
    } else if ([4, 94, 95, 96, 97, 98].contains(buildingNum)) {
      zone = nums[1][0]!.padLeft(2, '0');
      room = nums[2][0]!.padLeft(4, '0');
    } else if ([16, 17].contains(buildingNum) || (zone == '00' && room == '0000')) {
      zone = nums[1][0]!.padLeft(2, '0');
      room = nums[2][0]!.length == 1
          ? nums[3][0]!.padLeft(4, '0')
          : nums[2][0]!.padLeft(4, '0');
    }

    // 处理非冲突房间的识别码
    final roomNum = int.parse(room);
    if ([4, 24, 49, 51, 55].contains(buildingNum)) {
      if (!([101, 102, 203, 204, 305, 306, 407, 408, 509, 510].contains(roomNum))) {
        verify = '';
      }
    } else if ([47, 48, 52, 53].contains(buildingNum)) {
      if (!([101, 102, 103, 104].contains(roomNum))) {
        verify = '';
      }
    }

    callback(zone, room, verify);
  }
}

class NoAccountInfoException implements Exception {
  @override
  String toString() => '未设置宿舍信息';
}

class InvalidDormFormatException implements Exception {
  @override
  String toString() => '宿舍格式错误';
}

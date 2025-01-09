// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_yidianshi/xd_api/base_provider.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:get/get.dart';

class Lazy<T> {
  final T Function() _initializer;

  Lazy(this._initializer);

  T? _value;

  T get value => _value ??= _initializer();
}

class SliderCaptchaClientProvider extends BaseProvider {
  final String cookie;

  Uint8List? puzzleData;
  Uint8List? pieceData;

  SliderCaptchaClientProvider({required this.cookie});

  @override
  void onInit() {
    super.onInit();
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Cookie'] = cookie;
      return request;
    });
  }

  Future<void> solve(void Function(double)? onProgress) async {
    puzzleData = await getPuzzle();
    pieceData = await getPiece();

    if (puzzleData == null || pieceData == null) {
      throw Exception("Failed to get puzzle or piece data");
    }

    final puzzle = img.decodeImage(puzzleData!);
    final piece = img.decodeImage(pieceData!);

    if (puzzle == null || piece == null) {
      throw Exception("Failed to decode puzzle or piece image");
    }

    final offset = findPieceOffset(puzzle, piece);
    if (offset == null) {
      throw Exception("Failed to find piece offset");
    }

    await verify(offset.toDouble(), onProgress);
  }

  Future<Uint8List> getPuzzle() async {
    final response = await safeRequest(
      () => get("/authserver/common/openSliderCaptcha.htl"),
    );
    return response.body;
  }

  Future<Uint8List> getPiece() async {
    final response = await safeRequest(
      () => get("/authserver/common/slider/piece.htl"),
    );
    return response.body;
  }

  Future<void> verify(double offset, void Function(double)? onProgress) async {
    const steps = 10;
    final stepSize = offset / steps;

    for (var i = 0; i <= steps; i++) {
      final currentOffset = stepSize * i;
      onProgress?.call(currentOffset);

      if (i < steps) {
        await safeRequest(
          () => post(
            "/authserver/common/slider/move.htl",
            {'offsetX': currentOffset.toString()},
          ),
        );
      }
    }

    final response = await safeRequest(
      () => post(
        "/authserver/common/slider/verify.htl",
        {'offsetX': offset.toString()},
      ),
    );

    final result = response.body;
    if (result != "1") {
      throw Exception("Verification failed");
    }
  }

  int? findPieceOffset(img.Image puzzle, img.Image piece) {
    const threshold = 30;
    final puzzleBytes = puzzle.getBytes();
    final pieceBytes = piece.getBytes();

    for (var x = 0; x < puzzle.width - piece.width; x++) {
      var matchScore = 0;
      var totalPixels = 0;

      for (var py = 0; py < piece.height; py++) {
        for (var px = 0; px < piece.width; px++) {
          final piecePixel = pieceBytes[py * piece.width * 4 + px * 4];
          if (piecePixel > 0) {
            totalPixels++;
            final puzzlePixel =
                puzzleBytes[(py * puzzle.width + x + px) * 4];
            if ((piecePixel - puzzlePixel).abs() < threshold) {
              matchScore++;
            }
          }
        }
      }

      if (totalPixels > 0 &&
          matchScore / totalPixels > 0.8) {
        return x;
      }
    }
    return null;
  }
}

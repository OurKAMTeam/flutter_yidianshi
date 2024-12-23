import 'package:flutter/material.dart';
import 'package:flutter_yidianshi/xd_api/login/base_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:io';

class Lazy<T> {
  final T Function() _initializer;

  Lazy(this._initializer);

  T? _value;

  T get value => _value ??= _initializer();
}

class SliderCaptchaClientProvider extends LoginProvider{
  String cookie = "";

  Uint8List? puzzleData;
  Uint8List? pieceData;
  Lazy<Image>? puzzleImage;
  Lazy<Image>? pieceImage;

  final double puzzleWidth = 280;
  final double puzzleHeight = 155;
  final double pieceWidth = 44;
  final double pieceHeight = 155;



  // 主要逻辑部分
  Future<void> updatePuzzle()  async{
  }

  Future<void> solve() async {
  }

  Future<bool> verify(double answer) async {
    return true;
  }




  double? trySolve(Uint8List puzzleData, Uint8List pieceData,
      {int border = 24}) {
    img.Image? puzzle = img.decodeImage(puzzleData);
    if (puzzle == null) {
      return null;
    }
    img.Image? piece = img.decodeImage(pieceData);
    if (piece == null) {
      return null;
    }

    var bbox = _findAlphaBoundingBox(piece);
    var xL = bbox[0] + border,
        yT = bbox[1] + border,
        xR = bbox[2] - border,
        yB = bbox[3] - border;

    var widthW = xR - xL, heightW = yB - yT, lenW = widthW * heightW;
    var widthG = puzzle.width - piece.width + widthW - 1;

    var meanT = _calculateMean(piece, xL, yT, widthW, heightW);
    var templateN = _normalizeImage(piece, xL, yT, widthW, heightW, meanT);
    var colsW = [
      for (var x = xL + 1; x < widthG + 1; ++x)
        _calculateSum(puzzle, x, yT, 1, heightW)
    ];
    var colsWL = colsW.iterator, colsWR = colsW.iterator;
    double sumW = 0;
    for (var i = 0; i < widthW; ++i) {
      colsWR.moveNext();
      sumW += colsWR.current;
    }
    double nccMax = 0;
    int xMax = 0;
    for (var x = xL + 1; x < widthG - widthW; x += 2) {
      colsWL.moveNext();
      colsWR.moveNext();
      sumW = sumW - colsWL.current + colsWR.current;
      colsWL.moveNext();
      colsWR.moveNext();
      sumW = sumW - colsWL.current + colsWR.current;
      var ncc =
      _calculateNCC(puzzle, x, yT, widthW, heightW, templateN, sumW / lenW);
      if (ncc > nccMax) {
        nccMax = ncc;
        xMax = x;
      }
    }

    return (xMax - xL - 1) / puzzle.width;
  }

  static List<int> _findAlphaBoundingBox(img.Image image) {
    var xL = image.width, yT = image.height, xR = 0, yB = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        if (image.getPixel(x, y).a != 255) continue;
        if (x < xL) xL = x;
        if (y < yT) yT = y;
        if (x > xR) xR = x;
        if (y > yB) yB = y;
      }
    }
    return [xL, yT, xR, yB];
  }

  static double _calculateSum(
      img.Image image, int x, int y, int width, int height) {
    double sum = 0;
    for (var yy = y; yy < y + height; yy++) {
      for (var xx = x; xx < x + width; xx++) {
        sum += image.getPixel(xx, yy).luminance;
      }
    }
    return sum;
  }

  static double _calculateMean(
      img.Image image, int x, int y, int width, int height) {
    return _calculateSum(image, x, y, width, height) / width / height;
  }

  static List<double> _normalizeImage(
      img.Image image, int x, int y, int width, int height, double mean) {
    return [
      for (var yy = 0; yy < height; yy++)
        for (var xx = 0; xx < width; xx++)
          image.getPixel(xx + x, yy + y).luminance - mean
    ];
  }

  static double _calculateNCC(img.Image window, int x, int y, int width,
      int height, List<double> template, double meanW) {
    double sumWt = 0, sumWw = 0.000001;
    var iT = template.iterator;
    for (var yy = y; yy < y + height; yy++) {
      for (var xx = x; xx < x + width; xx++) {
        iT.moveNext();
        var w = window.getPixel(xx, yy).luminance - meanW;
        sumWt += w * iT.current;
        sumWw += w * w;
      }
    }
    return sumWt / sumWw;
  }
}
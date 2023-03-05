// ignore_for_file: constant_identifier_names
import 'package:app/utils/array.dart';

const PRICE_NUMBER = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
const PRICE_CHARACTERS = [".", "원", "won", ",", "\$", "krw", " "];
const BOUNDARY_COUNT = 2;

bool isPriceText(String text) {
  final textArray = text.split("");

  final numberOfPriceText = textArray.fold(
    0,
    (count, text) => PRICE_NUMBER.contains(text) ? count + 1 : count,
  );

  final numberOfNotPriceText = textArray
      .filter(
        (text, i) => PRICE_NUMBER.contains(text) == false,
      )
      .fold(
        0,
        (count, text) => PRICE_CHARACTERS.contains(text) ? count : count + 1,
      );

  return numberOfPriceText >= BOUNDARY_COUNT &&
      numberOfNotPriceText <= BOUNDARY_COUNT;
}

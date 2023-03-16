// ignore_for_file: constant_identifier_names
import 'package:app/utils/array.dart';

bool isPriceText(String text) {
  const PRICE_NUMBER = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
  const PRICE_CHARACTERS = [".", "원", "won", ",", "\$", "krw", " "];
  const NON_PRICE_CHARACTERS = ["g", "kg"];
  const PRICE_BOUNDARY_COUNT = 2;
  const NOT_PRICE_BOUNDARY_COUNT = 2;

  final textArray = text.split("");

  if (textArray.any(
    (element) => NON_PRICE_CHARACTERS.any(
      (non) => element.contains(non),
    ),
  )) {
    return false;
  }

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

  return numberOfPriceText >= PRICE_BOUNDARY_COUNT &&
      numberOfNotPriceText <= NOT_PRICE_BOUNDARY_COUNT;
}

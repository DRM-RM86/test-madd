import 'dart:math';

abstract class CodeGenerator {
  String generate();
}

class FourDigitCodeGenerator implements CodeGenerator {
  const FourDigitCodeGenerator();

  @override
  String generate() {
    final value = Random.secure().nextInt(10000);
    return value.toString().padLeft(4, '0');
  }
}

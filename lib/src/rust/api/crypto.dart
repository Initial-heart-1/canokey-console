// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.7.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `gen_x590_meta`

Uint8List tdesEde3Enc({required List<int> key, required List<int> data}) =>
    RustLib.instance.api.crateApiCryptoTdesEde3Enc(key: key, data: data);

X509CertData parseX509CertFromPem({required String pem}) =>
    RustLib.instance.api.crateApiCryptoParseX509CertFromPem(pem: pem);

X509CertData parseX509CertFromDer({required List<int> der}) =>
    RustLib.instance.api.crateApiCryptoParseX509CertFromDer(der: der);

Uint8List pbkdf2HmacSha1(
        {required String password,
        required List<int> salt,
        required int iterations,
        required int keyLen}) =>
    RustLib.instance.api.crateApiCryptoPbkdf2HmacSha1(
        password: password, salt: salt, iterations: iterations, keyLen: keyLen);

Uint8List hmacSha1({required List<int> key, required List<int> data}) =>
    RustLib.instance.api.crateApiCryptoHmacSha1(key: key, data: data);

class X509CertData {
  final Uint8List bytes;
  final String subject;
  final String issuer;
  final String notBefore;
  final String notAfter;
  final String serialNumber;
  final String signatureAlgorithm;
  final Uint8List signatureValue;
  final String publicKeyAlgorithm;
  final BigInt publicKeySize;

  const X509CertData({
    required this.bytes,
    required this.subject,
    required this.issuer,
    required this.notBefore,
    required this.notAfter,
    required this.serialNumber,
    required this.signatureAlgorithm,
    required this.signatureValue,
    required this.publicKeyAlgorithm,
    required this.publicKeySize,
  });

  @override
  int get hashCode =>
      bytes.hashCode ^
      subject.hashCode ^
      issuer.hashCode ^
      notBefore.hashCode ^
      notAfter.hashCode ^
      serialNumber.hashCode ^
      signatureAlgorithm.hashCode ^
      signatureValue.hashCode ^
      publicKeyAlgorithm.hashCode ^
      publicKeySize.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is X509CertData &&
          runtimeType == other.runtimeType &&
          bytes == other.bytes &&
          subject == other.subject &&
          issuer == other.issuer &&
          notBefore == other.notBefore &&
          notAfter == other.notAfter &&
          serialNumber == other.serialNumber &&
          signatureAlgorithm == other.signatureAlgorithm &&
          signatureValue == other.signatureValue &&
          publicKeyAlgorithm == other.publicKeyAlgorithm &&
          publicKeySize == other.publicKeySize;
}

import 'dart:math';

class Rsa {
  static isPrime(int num) {
    if (num < 2) {
      return false;
    }
    for (var i = 2; i < num; i++) {
      if (num % i == 0) {
        return false;
      }
    }
    return true;
  }

  static generatePrime() {
    var primes = [];
    var random = Random();

    for (var i = 2; i < 1000; i++) {
      if (isPrime(i)) {
        primes.add(i);
      }
    }

    return primes[random.nextInt(primes.length)];
  }

  static gcd(int a, int b) {
    while (b != 0) {
      var temp = a;
      a = b;
      b = temp % b;
    }
    return a;
  }

  static modInverse(int a, int m) {
    var m0 = m;
    var x0 = 0;
    var x1 = 1;

    while (a > 1) {
      var q = a ~/ m;
      var tempM = m;
      m = a % m;
      a = tempM;
      var tempX0 = x0;
      x0 = x1 - q * x0;
      x1 = tempX0;
    }

    if (x1 < 0) {
      return x1 + m0;
    }
    return x1;
  }

  static powMod(int base, int exponent, int modulus) {
    int result = 1;
    base = base % modulus;
    while (exponent > 0) {
      if (exponent % 2 == 1) {
        result = (result * base) % modulus;
      }
      exponent = exponent >> 1;
      base = (base * base) % modulus;
    }
    return result;
  }

  static generateKeypair() {
    var p = generatePrime();
    var q = generatePrime();
    var random = Random();
    List publicKey = [];
    List privateKey = [];
    List allKey = [];

    var n = p * q;
    var phi = (p - 1) * (q - 1);

    var e = random.nextInt(phi) + 1;

    while (gcd(e, phi) != 1) {
      e = random.nextInt(phi) + 1;
    }

    var d = modInverse(e, phi);
    publicKey.add(n);
    publicKey.add(e);
    privateKey.add(n);
    privateKey.add(d);
    allKey.add(publicKey);
    allKey.add(privateKey);

    return allKey;
  }

  static encrypt(List publicKey, String plaintext) {
    var n = publicKey[0];
    var e = publicKey[1];

    var encryptedMsg = [];

    for (var i = 0; i < plaintext.length; i++) {
      var charCode = plaintext.codeUnitAt(i);
      var encryptedChar = powMod(charCode, e, n);
      encryptedMsg.add(encryptedChar);
    }

    return encryptedMsg;
  }

  static decrypt(List privateKey, List ciphertext) {
    var n = privateKey[0];
    var d = privateKey[1];

    var decryptedMsg = "";

    for (var char in ciphertext) {
      var decryptedChar = powMod(char, d, n);
      decryptedMsg += String.fromCharCode(decryptedChar);
    }

    return decryptedMsg;
  }
}

// void main() {
//   var allKey = Rsa.generateKeypair();
//   var publicKey = allKey[0];
//   var privateKey = allKey[1];
//   print(publicKey);
//   print(privateKey);

//   var message = "Hello World!";
//   print(message);

//   var encryptedMessage = Rsa.encrypt(publicKey, message);
//   print("Encrypted message: $encryptedMessage");

//   var decryptedMessage = Rsa.decrypt(privateKey, encryptedMessage);
//   print("Decrypted message: $decryptedMessage");
// }

method LuhnCheck(n: int) returns (ok: bool)
  requires n >= 0
  ensures ok == (n % 10 != 0)
{
  ok := n % 10 != 0;
}

method IsExpired(year: int, month: int) returns (expired: bool)
  requires 1 <= month <= 12
  ensures expired == (year < 2024 || (year == 2024 && month < 1))
{
  expired := year < 2024 || (year == 2024 && month < 1);
}

method ValidateCard(number: int, year: int, month: int) returns (valid: bool)
  requires number >= 0
  requires 1 <= month <= 12
{
  var luhn := LuhnCheck(number);
  var exp  := IsExpired(year, month);
  valid := luhn && !exp;
}

method LogTransaction(amount: int) returns (logged: bool)
  requires amount > 0
{
  logged := true;
}

method ChargeAmount(amount: int) returns (charged: bool)
  requires amount > 0
{
  charged := amount <= 10000;
}

method VerifyPayment(cardNumber: int, year: int, month: int, amount: int)
  returns (ok: bool)
  requires cardNumber >= 0
  requires 1 <= month <= 12
  requires amount > 0
{
  var valid   := ValidateCard(cardNumber, year, month);
  var charged := ChargeAmount(amount);
  var logged  := LogTransaction(amount);
  ok := valid && charged && logged;
}

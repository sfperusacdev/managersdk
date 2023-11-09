import 'dart:convert';

List<Licence> licenceFromJson(String str) => List<Licence>.from(json.decode(str).map((x) => Licence.fromMap(x)));

String licenceToJson(List<Licence> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class Licence {
  String? licenceCode;
  String? companyCode;
  String? company;

  Licence({
    this.licenceCode,
    this.companyCode,
    this.company,
  });

  Licence copyWith({
    String? licenceCode,
    String? companyCode,
    String? company,
    bool? allowed,
  }) =>
      Licence(
        licenceCode: licenceCode ?? this.licenceCode,
        companyCode: companyCode ?? this.companyCode,
        company: company ?? this.company,
      );

  factory Licence.fromMap(Map<String, dynamic> json) => Licence(
        licenceCode: json["licence_code"],
        companyCode: json["company_code"],
        company: json["company"],
      );

  Map<String, dynamic> toMap() => {
        "licence_code": licenceCode,
        "company_code": companyCode,
        "company": company,
      };
}

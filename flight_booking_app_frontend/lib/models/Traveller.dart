class Traveller {
  String id;
  String firstName;
  String lastName;
  String dateOfBirth;
  String gender;
  String? documentType;
  String? documentNumber;
  String? documentExpiry;
  String? birthPlace;
  String? issuanceLocation;
  String? issuanceDate;
  String? issuanceCountry;
  String? validityCountry;
  String? nationality;
  bool? holder;
  String emailAddress;
  String phoneCountryCode;
  String phoneNumber;
  String travellerType;

  Traveller({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.documentType,
    this.documentNumber,
    this.documentExpiry,
    this.birthPlace,
    this.issuanceLocation,
    this.issuanceDate,
    this.issuanceCountry,
    this.validityCountry,
    this.nationality,
    this.holder,
    required this.emailAddress,
    required this.phoneCountryCode,
    required this.phoneNumber,
    required this.travellerType,
  });

  Map<String, dynamic> toJson({bool isDomestic = false}) {
    return {
      'id': id,
      'name': {
        'firstName': firstName,
        'lastName': lastName,
      },
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'travellerType': travellerType,
      'documents': isDomestic || documentType == null
          ? null
          : [
        {
          'documentType': documentType,
          'number': documentNumber,
          'expiryDate': documentExpiry,
          'birthPlace': birthPlace,
          'issuanceLocation': issuanceLocation,
          'issuanceDate': issuanceDate,
          'issuanceCountry': issuanceCountry,
          'validityCountry': validityCountry,
          'nationality': nationality,
          'holder': holder,
        }
      ],
      'contact': {
        'emailAddress': emailAddress,
        'phones': [
          {
            'deviceType': 'MOBILE',
            'countryCallingCode': phoneCountryCode,
            'number': phoneNumber,
          }
        ]
      },
    };
  }
}

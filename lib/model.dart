class Model{
  List<dynamic> name, address, phoneNumber, fax, email, designation, companyName, website;

  Model({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.fax,
    required this.email,
    required this.designation,
    required this.companyName,
    required this.website,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['phone_number'] = phoneNumber[0];
    data['fax'] = fax[0];
    data['email'] = email;
    data['designation'] = designation;
    data['company_name'] = companyName;
    data['website'] = website;
    return data;
  }
}
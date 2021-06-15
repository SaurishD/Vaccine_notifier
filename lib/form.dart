import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './home.dart';

enum UserAge { EighteenPlus, FourtyfivePlus }
enum UserDose { Dose1, Dose2 }
enum VaccineType { All, CoviShield, Covaxine, SputnicV }

class MyCustomFormRoute extends MaterialPageRoute<Null> {
  MyCustomFormRoute()
      : super(builder: (BuildContext context) {
          return MyCustomForm();
        });
}

class MyCustomForm extends StatefulWidget {
  static String id = "form";
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  final formKey = GlobalKey<FormState>();
  List<String> states = [];
  Map<String, String> stateValues = Map();
  List<String> cities = [];
  Map<String, String> cityValues = Map();

  final String defaultCity = "Select City";
  final String defaultState = "Select State";
  var selectedState = "Select State";
  var selectedCity = "Select City";

  UserAge _age = UserAge.EighteenPlus;
  VaccineType _vaccineType = VaccineType.All;
  UserDose _dose = UserDose.Dose1;
  //String _name = "";
  //String _mobileNumber = "";
  String _pincode = "";
  String _districtCode = "";
  //TextEditingController _nameController = new TextEditingController();
  //TextEditingController _mobileNumberController = new TextEditingController();
  TextEditingController _pincodeController = new TextEditingController();
  bool _enableNotification = true;
  bool _fetchByPincode = false;

  void _getValues() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
      //_name = pref.getString('name') ?? "";
      //_nameController.text = _name;

      //_mobileNumber = pref.getString('mobile') ?? "";
      //_mobileNumberController.text = _mobileNumber;

      _pincode = pref.getString('pincode') ?? "";
      _pincodeController.text = _pincode;

      _age = UserAge.values[pref.getInt('age') ?? 0];

      _vaccineType = VaccineType.values[pref.getInt('vaccine') ?? 0];

      _dose = UserDose.values[pref.getInt('dose') ?? 0];

      _enableNotification = pref.getBool("notification") ?? true;
      _fetchByPincode = pref.getBool("fetchPincode") ?? false;
    });
  }

  //Setters
  /*void _setName(String value) async {
    final pref = await SharedPreferences.getInstance();
    print("Name set to " + value);
    pref.setString('name', value);
  }

  void _setMobileNumber(String value) async {
    final pref = await SharedPreferences.getInstance();
    print("Mobile number set to " + value);
    pref.setString('mobile', value);
  }
  */
  void _setPincode(String value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('pincode', value);
  }

  void _setDistrictCode(String value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('districtCode', value);
  }

  void _setAge(UserAge value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt('age', value.index);
  }

  void _setVaccine(VaccineType value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt('vaccine', value.index);
  }

  void _setDose(UserDose value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setInt("dose", value.index);
  }

  void _setNotification(bool value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("notification", value);
  }

  void _setFetchPincode(bool value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool("fetchPincode", value);
  }

  void fetchStates() async {
    print("Executed");
    try {
      var response = await http.get(
          Uri.parse('https://cdn-api.co-vin.in/api/v2/admin/location/states'));
      var temp = jsonDecode(response.body)['states'];
      states.clear();
      states.add(defaultState);
      stateValues[defaultState] = defaultState;
      for (var t in temp) {
        states.add(t['state_name']);
        stateValues[t['state_name']] = t['state_id'].toString();
      }
      setState(() {});
      //print(states);
      //print(stateValues);
    } catch (e) {
      print("Error occur");
    }
  }

  void fetchCities(String id) async {
    print("City Executed");
    selectedCity = defaultCity;
    try {
      var response = await http.get(Uri.parse(
          "https://cdn-api.co-vin.in/api/v2/admin/location/districts/" + id));
      var temp = jsonDecode(response.body)['districts'];
      cities.clear();
      cities.add(defaultCity);
      cityValues[defaultCity] = defaultCity;
      for (var t in temp) {
        cities.add(t['district_name']);
        cityValues[t['district_name']] = t['district_id'].toString();
      }
      //print(cityValues);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  _MyCustomFormState() {
    fetchStates();
    _getValues();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vaccine Notifier',
      theme: themes,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Vaccine Notifier"),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: LayoutBuilder(builder: (context, constraints) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: <Widget>[
                        /*TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Name *",
                          ),
                          onSaved: (String value) {
                            setState(() {
                              _name = value;
                            });
                          },
                          validator: (String value) {
                            if (value.isEmpty) {
                              return "Name is required";
                            }
                          },
                        ),
                        TextFormField(
                          controller: _mobileNumberController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Mobile Number *",
                          ),
                          onSaved: (String value) {
                            setState(() {
                              _mobileNumber = value;
                            });
                          },
                          validator: (String value) {
                            if (value.length != 10) {
                              return "Enter a valid number";
                            }
                          },
                        ),
                        */
                        DropdownButton<String>(
                          value: selectedState,
                          onChanged: (String newValue) {
                            if (newValue == null) {
                              print("Null selected");
                            } else {
                              fetchCities(newValue);
                              print(newValue + " Selected");
                              selectedState = newValue;
                              setState(() {});
                            }
                          },
                          items: states
                              .map((String state) => DropdownMenuItem<String>(
                                  child: Text(state),
                                  value: stateValues[state]))
                              .toList(),
                          hint: Text("Select state"),
                          isExpanded: true,
                        ),
                        DropdownButton<String>(
                          value: selectedCity,
                          items: cities
                              .map<DropdownMenuItem<String>>((String city) {
                            return DropdownMenuItem<String>(
                                value: cityValues[city], child: Text(city));
                          }).toList(),
                          onChanged: (String newValue) {
                            if (newValue == null) {
                              print("Null");
                            } else {
                              selectedCity = newValue;
                              print(newValue + " Selected");
                              _districtCode = newValue;
                              setState(() {});
                            }
                          },
                          hint: Text("Select City"),
                          isExpanded: true,
                        ),
                        TextFormField(
                          controller: _pincodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Pincode",
                          ),
                          onSaved: (String value) {
                            setState(() {
                              _pincode = value;
                            });
                          },
                          validator: (String value) {
                            if (value.isNotEmpty && value.length != 6) {
                              return "Enter a valid pincode";
                            }
                          },
                        ),
                        
                        Row(children: <Widget>[
                          Flexible(
                            child: ListTile(
                              title: Text("18-44"),
                              leading: Radio<UserAge>(
                                value: UserAge.EighteenPlus,
                                groupValue: _age,
                                onChanged: (UserAge value) {
                                  if (value != null) {
                                    setState(() {
                                      _age = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            child: ListTile(
                              title: Text("45+"),
                              leading: Radio<UserAge>(
                                value: UserAge.FourtyfivePlus,
                                groupValue: _age,
                                onChanged: (UserAge value) {
                                  if (value != null) {
                                    setState(() {
                                      _age = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          )
                        ]),
                        Divider(),
                        Flexible(
                          child: ListTile(
                            title: Text("All"),
                            leading: Radio<VaccineType>(
                              value: VaccineType.All,
                              groupValue: _vaccineType,
                              onChanged: (VaccineType value) {
                                if (value != null) {
                                  setState(() {
                                    _vaccineType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: Text("Covishield"),
                            leading: Radio<VaccineType>(
                              value: VaccineType.CoviShield,
                              groupValue: _vaccineType,
                              onChanged: (VaccineType value) {
                                if (value != null) {
                                  setState(() {
                                    _vaccineType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: Text("Covaxin"),
                            leading: Radio<VaccineType>(
                              value: VaccineType.Covaxine,
                              groupValue: _vaccineType,
                              onChanged: (VaccineType value) {
                                if (value != null) {
                                  setState(() {
                                    _vaccineType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: ListTile(
                            title: Text("SphutnicV"),
                            leading: Radio<VaccineType>(
                              value: VaccineType.SputnicV,
                              groupValue: _vaccineType,
                              onChanged: (VaccineType value) {
                                if (value != null) {
                                  setState(() {
                                    _vaccineType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        Divider(),
                        Row(children: <Widget>[
                          Flexible(
                            child: ListTile(
                              title: Text("Dose1"),
                              leading: Radio<UserDose>(
                                value: UserDose.Dose1,
                                groupValue: _dose,
                                onChanged: (UserDose value) {
                                  if (value != null) {
                                    setState(() {
                                      _dose = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            child: ListTile(
                              title: Text("Dose 2"),
                              leading: Radio<UserDose>(
                                value: UserDose.Dose2,
                                groupValue: _dose,
                                onChanged: (UserDose value) {
                                  if (value != null) {
                                    setState(() {
                                      _dose = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          )
                        ]),
                        Divider(),
                        SwitchListTile(
                            value: _enableNotification,
                            title: Text("Notification"),
                            subtitle: Text("Enable or disable notifiaction"),
                            onChanged: (bool value) {
                              setState(() {
                                _enableNotification = value;
                              });
                            }),
                        Divider(),
                        SwitchListTile(
                            value: _fetchByPincode,
                            title: Text("Fetch slots by pincode"),
                            subtitle: Text("Instead of district code"),
                            onChanged: (bool value) {
                              setState(() {
                                _fetchByPincode = value;
                              });
                            }),
                        RaisedButton(
                            child: Text("Save Details"),
                            color: Colors.blue,
                            textColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            padding: EdgeInsets.fromLTRB(35, 15, 30, 15),
                            onPressed: () {
                              if (!formKey.currentState.validate()) {
                                return;
                              }
                              formKey.currentState.save();
                              //_setName(_name);
                              //_setMobileNumber(_mobileNumber);
                              _setPincode(_pincode);
                              _setFetchPincode(_fetchByPincode);
                              _setDistrictCode(_districtCode);
                              _setAge(_age);
                              _setVaccine(_vaccineType);
                              _setDose(_dose);
                              _setNotification(_enableNotification);
                              Navigator.push(context, HomePage());
                            })
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

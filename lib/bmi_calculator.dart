import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key}) : super(key: key);

  @override
  _BMICalculatorState createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  late TextEditingController nameController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  String? previousGender;
  double? previousBMI;
  String? _gender;
  int _bmi = 0;
  String? category;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    _loadPreviousData();
  }

  @override
  void dispose() {
    nameController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      previousGender = prefs.getString('gender');
      previousBMI = prefs.getDouble('bmi');
      nameController.text = prefs.getString('name') ?? '';
      heightController.text = prefs.getDouble('height')?.toStringAsFixed(2) ?? '';
      weightController.text = prefs.getDouble('weight')?.toStringAsFixed(2) ?? '';
      _gender = previousGender;
      _bmi = previousBMI?.toInt() ?? 0;
      category = prefs.getString('category') ?? ''; // Get the previous BMI category
    });
  }

  Future<void> _saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double _weight = double.parse(weightController.text);
      double _height = double.parse(heightController.text);
      await prefs.setString('gender', _gender ?? '');
      await prefs.setDouble('bmi', _bmi.toDouble());
      await prefs.setString('name', nameController.text);
      await prefs.setDouble('height', _height);
      await prefs.setDouble('weight', _weight);
      await prefs.setString('category', category!); // Save the BMI category
      print('BMI data saved to SharedPreferences');
    } catch (e) {
      print('Error saving BMI data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "BMI Calculator",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Full Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: heightController,
                decoration: InputDecoration(
                  labelText: 'Height in cm; 170',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: weightController,
                decoration: InputDecoration(
                  labelText: 'Weight in KG',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  "BMI Value: $_bmi"
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Male'),
                    leading: Radio(
                      value: 'Male',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value as String?;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('Female'),
                    leading: Radio(
                      value: 'Female',
                      groupValue: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value as String?;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                double _weight = double.parse(weightController.text);
                double _height = double.parse(heightController.text);

                double bmiTemp = _weight / ((_height / 100) * (_height / 100));

                setState(() {
                  _bmi = bmiTemp.round();
                  // Calculate BMI category based on gender
                  if (_gender == 'Male'){
                    if (bmiTemp < 18.5) {
                      category = 'Underweight. Careful during strong wind!';
                    }
                    else if (bmiTemp > 18.5 && bmiTemp < 24.9) {
                      category = 'That is ideal! Please maintain';
                    }
                    else if (bmiTemp > 25 && bmiTemp < 30) {
                      category = 'Overweight! Work out please';
                    }
                    else
                      category = 'Whoa obese! Dangerous mate!';
                  }
                  else if (_gender == 'Female'){
                    if (bmiTemp < 16) {
                      category = 'Underweight. Careful during strong wind!';
                    }
                    else if (bmiTemp > 16 && bmiTemp < 22) {
                      category = 'That is ideal! Please maintain';
                    }
                    else if (bmiTemp > 22 && bmiTemp < 27) {
                      category = 'Overweight! Work out please';
                    }
                    else
                      category = 'Whoa obese! Dangerous mate!';
                  }
                });

                await _saveData();
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child: Text("Calculate BMI and Save"),
            ),
            SizedBox(height: 10),
            Text(
              "$category",
            ),
          ],
        ),
      ),
    );
  }

}

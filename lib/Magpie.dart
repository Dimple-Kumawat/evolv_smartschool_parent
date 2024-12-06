import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool agreeTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Respondent's Registration",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            SizedBox(height: 0),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'WELCOME  JANARDAN KUMAR',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/result.png',
                    height: 80,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mobile Based Verification Project',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Registration',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            _buildTextField('Respondent\'s Name'),
            SizedBox(height: 20),
            _buildTextField('Respondent\'s Mobile'),
            SizedBox(height: 20),
            _buildTextField('Respondent\'s Email'),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: agreeTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      agreeTerms = value!;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'I agree to all the terms and conditions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: agreeTerms ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

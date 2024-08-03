import 'package:firebase_connection/cloud_firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPScreen extends StatefulWidget {
  @override
  _OTPScreenState createState() => _OTPScreenState();
}


class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;

  Future<void> _sendOTP() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        print("Phone number automatically verified and user signed in: ${_auth.currentUser}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Phone number automatically verified and user signed in"),
        ));
      },
      verificationFailed: (FirebaseAuthException e) {
        print("Failed to verify phone number: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Failed to verify phone number"),
        ));
      },
      
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        print("OTP sent to phone number");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('OTP sent to phone number'),
        ));
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }


  Future<void> _verifyOTP() async {
    if (_verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      await _auth.signInWithCredential(credential);
      print("Phone number verified and user signed in: ${_auth.currentUser}");

      // Navigator.push(context, MaterialPageRoute(builder: (context) => CloudFirestore(),));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('OTP verified successfully'),
      ));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('OTP Incorrect'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase OTP Authentication'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number e.g.[+][92][0123456789]'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOTP,
              child: const Text('Send OTP'),
            ),
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}

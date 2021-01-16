
import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  String message;
  ProgressDialog({this.message});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        margin: EdgeInsets.all(5),
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              SizedBox(width: 6.0),
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),),
              SizedBox(width: 26.0),
              Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
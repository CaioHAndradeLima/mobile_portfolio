import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? const CupertinoActivityIndicator() : const CircularProgressIndicator(
      color: AppColors.primaryColor,
      strokeWidth: 3,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:arnituramobile/app_bar_drawer_list_to_back.dart';

class PolicyWidget extends StatefulWidget {
  const PolicyWidget({Key? key}) : super(key: key);

  @override
  _PolicyState createState() => _PolicyState();
}

class _PolicyState extends State<PolicyWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDrawerListToBack('Политика конфидициальности'),
      body: SfPdfViewer.asset(
        'assets/documents/polzovatelskoe_04.03.2022.pdf',
      ),
    );
  }
}

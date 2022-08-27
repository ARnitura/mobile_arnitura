import 'package:flutter/material.dart';
import 'app_bar_drawer_list_to_back.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class OffertWidget extends StatefulWidget {
  const OffertWidget({Key? key}) : super(key: key);

  @override
  _OffertState createState() => _OffertState();
}

class _OffertState extends State<OffertWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDrawerListToBack('Правила офферты'),
      body: SfPdfViewer.asset(
          'assets/documents/polzovatelskoe_04.03.2022.pdf'
      ),
    );
  }
}

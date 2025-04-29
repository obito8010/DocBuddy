import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_file/open_file.dart';

class ReportDownloadScreen extends StatefulWidget {
  const ReportDownloadScreen({super.key});

  @override
  State<ReportDownloadScreen> createState() => _ReportDownloadScreenState();
}

class _ReportDownloadScreenState extends State<ReportDownloadScreen> {
  bool isGenerating = false;

  Future<void> generateReport() async {
  setState(() => isGenerating = true);

  final pdf = pw.Document();
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve stored patient data
  String patientName = prefs.getString('patientName') ?? "Mr. X";
  int patientAge = prefs.getInt('patientAge') ?? 22;
  String symptoms = prefs.getString('symptoms') ?? "Not provided";
  String detectedDisease = prefs.getString('detectedDisease') ?? "Not detected";
  String precautions = prefs.getString('precautions') ?? "No specific precautions";
  String medications = prefs.getString('medications') ?? "No medications prescribed";
  String diet = prefs.getString('diet') ?? "No specific diet recommendations";

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Medical Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Patient Name: $patientName", style: pw.TextStyle(fontSize: 18)),
              pw.Text("Age: $patientAge", style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text("Symptoms: $symptoms", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 5),
              pw.Text("Predicted Disease: $detectedDisease", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text("Precautions: $precautions", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 5),
              pw.Text("Medications: $medications", style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 5),
              pw.Text("Diet Recommendations: $diet", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        );
      },
    ),
  );

  try {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/Medical_Report.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    setState(() => isGenerating = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("PDF saved at: $filePath"),
      duration: Duration(seconds: 3),
    ));

    OpenFile.open(filePath);
  } catch (e) {
    setState(() => isGenerating = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error generating PDF: $e"),
      duration: Duration(seconds: 3),
    ));
    print("Error generating PDF: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Download Report")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: isGenerating ? null : generateReport,
              child: isGenerating
                  ? const CircularProgressIndicator()
                  : const Text("Generate & Open PDF"),
            ),
          ],
        ),
      ),
    );
  }
}

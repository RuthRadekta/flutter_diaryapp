import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diaryapp2/pages/home_page.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants.dart';
import 'action_buttons.dart';

final CollectionReference note = FirebaseFirestore.instance.collection('note'); // Koleksi 'note'

class BackView extends StatefulWidget {
  final int monthIndex;
  final Function showEditPopup;
  final Map<String, String> notes;
  final Function saveNoteToFirestore; // Terima fungsi ini sebagai parameter

  const BackView({
    Key? key,
    required this.monthIndex,
    required this.showEditPopup,
    required this.notes,
    required this.saveNoteToFirestore, // Terima fungsi ini
  }) : super(key: key);

  @override
  _BackViewState createState() => _BackViewState();
}

final TextEditingController _judulController = TextEditingController();
class _BackViewState extends State<BackView> {
  int? selectedDay;
  
  void _showDiaryDialog(int day, int month) {

  // Format tanggal sesuai
  String cDay = day < 10 ? '0$day' : '$day';
  String cMonth = month < 10 ? '0$month' : '$month';
  String dateStr = '$cDay-$cMonth'; // Format tanggal yang sesuai

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Masukkan Judul Diary'),
        content: TextField(
          controller: _judulController,
          decoration: const InputDecoration(hintText: 'Masukkan judul...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Menutup dialog tanpa simpan
            },
            child: const Text('Batal'),
          ),
          TextButton(
              onPressed: () {
                if (_judulController.text.isNotEmpty) {
                  widget.showEditPopup(dateStr, _judulController.text); // Menyimpan judul menggunakan callback

                  // Simpan catatan ke Firestore dengan UUID sebagai ID
                  var uuid = Uuid();
                  String noteId = uuid.v4(); // ID unik untuk catatan
                  widget.saveNoteToFirestore(dateStr, _judulController.text); // Simpan catatan ke Firestore

                  setState(() {}); // Refresh tampilan setelah menyimpan
                  Navigator.pop(context); // Tutup dialog
                  debugPrint('Tersimpan');
                } else {
                  debugPrint('Judul tidak boleh kosong!');
                }
              },
            child: const Text('Simpan'),
          )
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8.0),
          ],
        ),
        child: Column(
          children: [
            Text(
              '${widget.monthIndex}',
              textScaleFactor: 2.5,
            ),
            const SizedBox(height: 5.0),
            Text(
              months[widget.monthIndex]!.keys.toList()[0],
              textScaleFactor: 2.0,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20.0),
            // Grid untuk tanggal bulan
            Expanded(
              child: GridView.builder(
                itemCount: months[widget.monthIndex]!.values.toList()[0],
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1 / 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (_, i) {
                  int day = i + 1;
                  String cDay = day < 10 ? '0$day' : '$day';
                  String cMonth =
                      widget.monthIndex < 10 ? '0${widget.monthIndex}' : '${widget.monthIndex}';
                  DateTime date = DateTime.parse('2022-$cMonth-$cDay');

                  bool isSelected = selectedDay == day;
                  bool hasNote = widget.notes.containsKey('$cDay-$cMonth');

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                        //String dateStr = '$cDay-$cMonth'; // Format tanggal
                        //widget.saveNoteToFirestore(dateStr, _judulController.text); // Simpan catatan ke Firestore
                        //widget.showEditPopup(dateStr); // Panggil popup untuk tanggal tertentu
                        _showDiaryDialog(day, widget.monthIndex); // Panggil dialog dengan day dan month
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.blue : Colors.transparent,
                        border: hasNote
                            ? Border.all(color: Colors.green, width: 2)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Text(
                        '$day',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: date.weekday == DateTime.sunday
                              ? Colors.red
                              : date.weekday == DateTime.saturday
                                  ? Colors.blue
                                  : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Text(
              'Select a date to write',
              textScaleFactor: 0.8,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

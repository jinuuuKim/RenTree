import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  bool isFaceToFace = false;
  bool isNonFaceToFace = false;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _startTimeController.text = formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = formatTimeOfDay(picked);
      });
    }
  }

  Future<void> submitRequest() async {
    final title = _titleController.text.trim();
    final startTime = _startTimeController.text.trim();
    final endTime = _endTimeController.text.trim();
    final description = _descriptionController.text.trim();
    final isPerson = isFaceToFace;
    final createdAt = DateTime.now().toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('studentId'); // ✅ 저장된 값만 가져오기

    print("불러온 studentId: $studentId");
    print("불러온 datetime: $createdAt");

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 정보를 찾을 수 없습니다. 다시 로그인해주세요.')),
      );
      return;
    }

    if (title.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 입력해주세요')),
      );
      return;
    }

    final url = Uri.parse('http://10.0.2.2:8080/ItemRequest');

    print('[전송 데이터] isPerson: $isPerson');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'startTime': startTime,
        'endTime': endTime,
        'person': isFaceToFace,
        'studentId': studentId,
        'createdAt': createdAt,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('글이 등록되었습니다!')),
      );
      Navigator.pop(context);
    } else {
      print('서버 오류: ${response.statusCode} - ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('글 등록 실패')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffF4F1F1),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 70),
                            Text('물건 대여 요청하기',
                                style: TextStyle(
                                    fontSize: 33, fontWeight: FontWeight.bold)),
                            SizedBox(height: 50),
                            TextField(
                              controller: _titleController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xffEBEBEB),
                                hintText: '제목 입력',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      width: 1, color: Color(0xFF888686)),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text("대여 시간은"),
                                SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: _selectStartTime,
                                    child: IgnorePointer(
                                      child: TextField(
                                        controller: _startTimeController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Color(0xffEBEBEB),
                                          hintText: '시작 시간',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Color(0xFF888686)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text("부터"),
                                SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: _selectEndTime,
                                    child: IgnorePointer(
                                      child: TextField(
                                        controller: _endTimeController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Color(0xffEBEBEB),
                                          hintText: '종료 시간',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                width: 1,
                                                color: Color(0xFF888686)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text("까지"),
                              ],
                            ),
                            SizedBox(height: 20),
                            Container(
                              height: 275,
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: null,
                                expands: true,
                                keyboardType: TextInputType.text,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xffEBEBEB),
                                  hintText: '상품에 대한 설명을 자세하게 적어주세요.',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1, color: Color(0xFF888686)),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text('대면',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff606060))),
                                    Checkbox(
                                      value: isFaceToFace,
                                      activeColor: Color(0xff97C663),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            isFaceToFace = true;
                                            isNonFaceToFace = false;
                                          } else {
                                            isFaceToFace = false;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(width: 5),
                                Row(
                                  children: [
                                    Text('비대면',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff606060))),
                                    Checkbox(
                                      value: isNonFaceToFace,
                                      activeColor: Color(0xff97C663),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          if (value == true) {
                                            isNonFaceToFace = true;
                                            isFaceToFace = false;
                                          } else {
                                            isNonFaceToFace = false;
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff97C663),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'RenTree에 글 올리기',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                left: 0,
                child: IconButton(
                  icon: Icon(Icons.close, size: 40, color: Color(0xff918B8B)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

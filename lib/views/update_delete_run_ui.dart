// ignore_for_file: sort_child_properties_last
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_run_tracker_app/models/run.dart';
import 'package:flutter_run_tracker_app/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateDeleteRunUI extends StatefulWidget {
  //สร้างตัวแปรมารับค่าที่ส่งมา
  Run? runDataDetail;

  // เอาค่าที่ส่งมาใส่ให้กับตัวแปร
  UpdateDeleteRunUI({super.key, this.runDataDetail});

  @override
  State<UpdateDeleteRunUI> createState() => _UpdateDeleteRunUIState();
}

class _UpdateDeleteRunUIState extends State<UpdateDeleteRunUI> {
  // ----------- ส่วนของโค้ดที่เกี่ยวกับการเปิดกล้อง เปิดแกลอรี่ --------------
  Uint8List? imageBytes; //เอาไว้เก็บรูปเพื่อแสดงที่หน้าจอ
  XFile?
      imageFile; //เอาไว้เก็บรูปเพื่อที่จะ upload ไปเก็บที่ bucket->storage->supabase

  //เมธอดเปิดกล้อง
  Future<void> selectImageFromCamera() async {
    //เปิด camera
    imageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);

    //ตรวจสอบว่าได้ถ่ายไหม
    if (imageFile != null) {
      final byte = await imageFile!.readAsBytes();
      setState(() {
        imageBytes = byte;
      });
    }
  }

  //เมธอดเปิดแกลอรี่
  Future<void> selectImageFromGallery() async {
    //เปิด gallery
    imageFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);

    //ตรวจสอบว่าได้เลือกไหม
    if (imageFile != null) {
      final byte = await imageFile!.readAsBytes();
      setState(() {
        imageBytes = byte;
      });
    }
  }
  // ---------------------------------------------------------------

  //----------- ส่วนของโค้ดที่เกี่ยวกับการ upload และ save ข้อมูล -----------
  // ตัวแปลสำหรับเก็บตำแหน่งไฟล์ที่อัปโหลดไปที่ supabase
  String imageURL = "";

  //สร้างตัวควบคุม TextField
  TextEditingController runWhereCtrl = TextEditingController();
  TextEditingController runPersonCtrl = TextEditingController();
  TextEditingController runDistanceCtrl = TextEditingController();

  Future<void> uploadAndSaveData() async {
    //กำหนดค่ารูปว่าได้มีรูปเดิมก่อนแล้วหรือไม่
    imageURL = widget.runDataDetail!.runImageUrl!;

    //upload file แต่ต้องตรวจสอบก่อนว่ามีไฟล์ที่จะอัปโหลดไหม
    if (imageFile != null) {
      imageURL = await SupabaseService().uploadImageFile(imageFile!);
    }

    // save ข้อมูลลง table
    // validate ว่าผู้ใช้ป้อนครบยัง
    if (runWhereCtrl.text.isEmpty ||
        runPersonCtrl.text.isEmpty ||
        runDistanceCtrl.text.isEmpty) {
      //อันไหนว่างแสดงเตือนใช้ SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณากรอกข้อมูลให้ครบถ้วน',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );

      return; //*** อย่าลืม return
    }

    //ผ่าน validate มาก็ไดก็มาแพ็คข้อมูลเพื่อส่งไปบันทึกลง table
    Run runData = Run(
      runWhere: runWhereCtrl.text,
      runPerson: runPersonCtrl.text,
      runDistance: int.parse(runDistanceCtrl.text),
      runImageUrl: imageURL,
    );

    //ส่งข้อมูลที่แพ็คไปบันทึกลง table
    await SupabaseService().updateRun(runData, widget.runDataDetail!.id!);

    //หลังจากบันทึกเสร็จแสดงข้อความแจ้ง
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'อัปโหลดและบันทึกแก้ไขข้อมูลเรียบร้อยแล้ว',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    //แล้วย้อนกลับไปหน้า ShowAllRun()
    Navigator.pop(context);
  }
  // ----------------------------------------------------------------

  @override
  void initState() {
    runWhereCtrl.text = widget.runDataDetail!.runWhere!;
    runPersonCtrl.text = widget.runDataDetail!.runPerson!;
    runDistanceCtrl.text = widget.runDataDetail!.runDistance.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วนของ appBar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 1, 80),
        title: Text(
          'Run Tracker (แก้ไข/ลบ)',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),
      // ส่วนของ body
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.only(
            top: 50,
            bottom: 50,
            left: 45,
            right: 45,
          ),
          child: Center(
            child: Column(
              children: [
                //ใช้ Ternary Operator ในการตรวจสอบรูป
                imageFile != null
                    ? InkWell(
                        onTap: () {
                          selectImageFromCamera();
                        },
                        child: Image.memory(
                          imageBytes!,
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: MediaQuery.of(context).size.width * 0.50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : widget.runDataDetail!.runImageUrl == ''
                        ? InkWell(
                            onTap: () {
                              selectImageFromCamera();
                            },
                            child: Icon(
                              Icons.add_a_photo,
                              size: MediaQuery.of(context).size.width * 0.50,
                              color: Colors.grey,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              selectImageFromCamera();
                            },
                            child: Image.network(
                              widget.runDataDetail!.runImageUrl!,
                              width: MediaQuery.of(context).size.width * 0.50,
                              height: MediaQuery.of(context).size.width * 0.50,
                              fit: BoxFit.cover,
                            ),
                          ),
                SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'วิ่งที่ไหน',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: runWhereCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'เช่น สวนหลวง, .....',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'วิ่งกับใคร',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: runPersonCtrl,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'เช่น เพื่อน, .....',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ระยะทาง (กิโลเมตร)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: runDistanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'เช่น 5, 10, .....',
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    //เรียกใช้คำสั่ง uploadAndSaveData
                    uploadAndSaveData();
                  },
                  child: Text(
                    'บันทึกแก้ไขข้อมูล',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 3, 141, 49),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      55.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    // เรียกใช้งานคำสั่งลบไฟล์จาก bucket และลบข้อมูลจาก table
                    // ลบเสร็จแล้วอย่าลืมย้อนกลับไปหน้าก่อนหน้า
                    // เริ่มจาก ลบไฟล์ออกจาก bucket แต่ต้องตรวจสอบก่อนว่าข้อมูลนั้นมีรูปไหม
                    if (widget.runDataDetail!.runImageUrl != "") {
                      // สร้างตัวแปรเก็บเฉพาะชื่อไฟล์+นามสกุล จาก runImageUrl
                      String imageName =
                          widget.runDataDetail!.runImageUrl!.split('/').last;
                      // ส่งชื่อไฟล์ไปลบ
                      await SupabaseService().deleteImageFile(imageName);
                    }

                    // ลบไฟล์เรียบร้อยต่อไปลบข้อมูลออกจาก table
                    await SupabaseService()
                        .deleteRun(widget.runDataDetail!.id!);

                    // แสดงข้อความแจ้งว่าลบเสร็จแล้วด้วย SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ลบข้อมูลเสร็จสิ้น'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // ย้อนกลับไปหน้าก่อนหน้า
                    Navigator.pop(context);
                  },
                  child: Text(
                    'ลบข้อมูล',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 202, 72, 11),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      55.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

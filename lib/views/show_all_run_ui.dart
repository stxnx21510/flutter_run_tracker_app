// ignore_for_file: prefer_interpolation_to_compose_strings, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_run_tracker_app/models/run.dart';
import 'package:flutter_run_tracker_app/services/supabase_service.dart';
import 'package:flutter_run_tracker_app/views/add_run_ui.dart';
import 'package:flutter_run_tracker_app/views/update_delete_run_ui.dart';

class ShowAllRunUI extends StatefulWidget {
  const ShowAllRunUI({super.key});

  @override
  State<ShowAllRunUI> createState() => _ShowAllRunUIState();
}

class _ShowAllRunUIState extends State<ShowAllRunUI> {
  //ตัวแปรเก็บข้อมูลทั้งหมด from supabase
  List<Run>? runData;

  //ดึงข้อมูลจาก supabase มาเก็บในตัวแปร runData ผ่านทางsupabaseService
  Future<void> fetchRunData() async {
    final data = await SupabaseService().getAllRuns();

    setState(() {
      runData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    //เรียกใช้คำสั่งดึงข้อมูลตอนหน้าจอถูกเปิด
    fetchRunData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ส่วนของ appBar
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 1, 80),
        title: Text(
          'Run Tracker',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      // ส่วนของ floatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // เปิดไป AddRunUI() แบบย้อนกลับได้
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRunUI(),
            ),
          );

          //เรียกให้ดึงข้อมูลใหม่
          fetchRunData();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: const Color.fromARGB(255, 5, 1, 80),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // ส่วนของ body
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.355,
              height: MediaQuery.of(context).size.width * 0.355,
              fit: BoxFit.cover,
            ),
            Text(
              'วิ่งกันเถอะ',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height * 0.0325,
                fontWeight: FontWeight.bold,
              ),
            ),
            // ส่วนของ ListView แสดงข้อมูลทั้งหมดที่ดึงมาจาก supabase
            // ?? = if null operator, ถ้า runData เป็น null ให้แสดง 0
            Expanded(
              child: ListView.separated(
                  itemCount: runData?.length ?? 0,
                  separatorBuilder: (context, index) =>
                      Divider(indent: 20, endIndent: 20),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      ),
                      child: ListTile(
                        onTap: () async {
                          //เปิดไปหน้า UpdateDeleteRunUI() แบบย้อนกลับได้
                          //โดยที่ต้องส่งข้อมูลด้วย และพอย้อนกลับมาต้องดึงข้อมูลมาใหม่
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateDeleteRunUI(
                                  runDataDetail: runData![index]),
                            ),
                          );
                        },
                        tileColor: index % 2 == 0
                            ? const Color.fromARGB(255, 106, 203, 109)
                            : const Color.fromARGB(255, 175, 245, 178),
                        title: Text(
                          //"วิ่งที่ไหน: " + runData![index].runWhere!,
                          "วิ่งที่ไหน: ${runData![index].runWhere!}",
                        ),
                        subtitle: Text(
                          //"วิ่งไป: " + runData![index].runPerson!,
                          "วิ่งไป: ${runData![index].runDistance!} กม.",
                        ),
                        trailing: Icon(
                          Icons.info,
                          color: Colors.red,
                        ),
                        leading: runData![index].runImageUrl! == ''
                            ? Image.asset(
                                'assets/images/logo.png',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                runData![index].runImageUrl!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

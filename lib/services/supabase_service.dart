//codeต่างๆสั่งการทํางานกับ supabase
// eg upload, download, delete, update, select

import 'package:flutter_run_tracker_app/models/run.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // instance,object work with supabase
  final supabase = Supabase.instance.client;

  //method etc with supabase
  //method upload image to supabase storage
  Future<String> uploadImageFile(XFile xfile) async {
    //file name เพื่อไม่ให้ซ้ํากีนเวลาอยู่ในbucket
    final newFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';

    //upload file
    await supabase.storage.from('run_bk').uploadBinary(
          newFileName,
          await xfile.readAsBytes(),
          fileOptions: FileOptions(contentType: xfile.mimeType),
        );
    //คืนค่าfile in bucket for table
    return supabase.storage.from('run_bk').getPublicUrl(newFileName);
  }

  //method add data to table in database supabase
  Future<void> insertRun(Run run) async {
    await supabase.from('run_tb').insert(run.toJson());
  }

  //method ดึงข้อมูลจาก table ใน database supabase
  Future<List<Run>> getAllRuns() async {
    //ดึงข้อมูลจาก superbase
    final response = await supabase.from('run_tb').select('*');
    //เอาข้อมูลที่ดึงมา json เป็น object ใช้ใน project
    return response.map((e) => Run.fromJson(e)).toList();
  }

  //method ลบไฟล์ใน bucket in storage supabase
  Future<void> deleteImageFile(String fileName) async {
    await supabase.storage.from('run_bk').remove([fileName]);
  }

  //method แก้ไขข้อมูลใน table in database supabase
  Future<void> updateRun(Run run, String id) async {
    await supabase.from('run_tb').update(run.toJson()).eq('id', id);
  }

  //method ลบข้อมูลใน table in database supabase
  Future<void> deleteRun(String id) async {
    await supabase.from('run_tb').delete().eq('id', id);
  }
}

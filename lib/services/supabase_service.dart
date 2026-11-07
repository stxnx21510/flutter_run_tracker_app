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
}

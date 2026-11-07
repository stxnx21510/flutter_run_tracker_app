class Run {
  //ตัวแปรตั้งชื่อล้อกับในตาราง
  String? id;
  String? runWhere;
  String? runPerson;
  int? runDistance;
  String? runImageUrl;
  String? created_at;

  //constructor
  Run({
    this.id,
    this.runWhere,
    this.runPerson,
    this.runDistance,
    this.runImageUrl,
    this.created_at,
  });

  //data mobile to json
  Map<String, dynamic> toJson() {
    return {
      
      'runWhere': runWhere,
      'runPerson': runPerson,
      'runDistance': runDistance,
      'runImageUrl': runImageUrl,
      
    };
  }

  //json to data mobile
  factory Run.fromJson(Map<String, dynamic> json) {
    return Run(
      id: json['id'] as String,
      runWhere: json['runWhere'] as String,
      runPerson: json['runPerson'] as String,
      runDistance: json['runDistance'] as int,
      runImageUrl: json['runImageUrl'] as String,
      created_at: json['created_at'] as String,
    );
  }
}

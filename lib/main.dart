import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Firebase',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PorHub'),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  // StreamBuilder คือการสร้าง Widget ที่สามารถเกิดการเปลี่ยนแปลงของตัว stream ได้เช่นถ้าเกิดค่ามีการเปลี่ยนแปลงในนี้ก็จะ Builder ใหม่อีกรอบ หรือเฉพาะค่าที่มีการเปลี่ยนแปลง
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Profile').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.studentID,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                record.fname + " " + record.lname,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Age : " + record.age,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                record.favourite,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// เอาตรง ๆ ผมก็ยังไม่ค่อยมั่นใจเรื่องโค้ดการดึงค่า Firebase อะไรมากแต่จะพยายามอธิบายตามที่ผมเข้าใจ

// อันนี้คือการประกาศสร้าง Class ที่จะคอยเช็ดและเก็บค่าไว้ ก่อนส่งออกไปเพื่อเรียกค่า
class Record {
  // ประกาศตัวแปรที่จะเก็บค่าจาก Firebase ไว้
  final String fname;
  final String lname;
  final String studentID;
  final String favourite;
  final String age;

  // อันนี้ไม่แน่ใจว่าคืออะไร แต่น่าจะหมายถึงค่าใน Firebase
  final DocumentReference reference;

  // ฟังชั่นนี้ไม่ค่อยแน่ใจแต่เหมือนเป็นการเช็ดค่าว่าเป็น null หรือไม่ถ้าไม่เป็น null หมดก็จะเอาตัวแปรที่เราประกาศไว้ด้านบนมารับค่าจาก Firebase
  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['Fname'] != null),
        assert(map['Lname'] != null),
        assert(map['StudentID'] != null),
        assert(map['Favourite'] != null),
        assert(map['Age'] != null),
        fname = map['Fname'],
        lname = map['Lname'],
        studentID = map['StudentID'],
        favourite = map['Favourite'],
        age = map['Age'];

  // อันนี้จะทำการ Snapshot ค่าตลอดเวลามีอะไรอัพเดทจะให้มันเข้าไปที่ fromMap เพื่อทำการเช็ดค่าก่อนส่งออกไป
  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}

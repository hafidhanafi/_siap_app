import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:siap_app_new/widgets/doctor_item.dart';

import 'package:siap_app_new/widgets/specialist_item_new.dart';
import 'package:http/http.dart' as http;
import 'package:siap_app_new/firebase_options.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status_user = "-";
  String nama_user = "";
  String id_user="";
  List<dynamic> pengajuan = [];
  final List<Map> myProducts = List.generate(3, (index) => {"id": index, "name": "Product $index"})
      .toList();

  @override
  void initState() {
    super.initState();
    getPrefs();
    getPengajuan();
    setupInteractedMessage();

  }

  Future<void> getPrefs() async{
    final prefs = await SharedPreferences.getInstance();
    final res = prefs.getString("user");
    final resData = prefs.getString("user_data");
    final Map<String, dynamic> user = jsonDecode(res!);

    final Map<String, dynamic> userData = jsonDecode(resData!);
    // if(resData == null){
    //   _showMessageAlert(context, "Notifikasi", userData);
      // Navigator.pushNamed(context, '/home');
    // }
    setState(() {
      status_user = user['status_user'];
      id_user = user['id_user'];
      if(userData != null){
        nama_user = userData['nama_lengkap'];
      }
    });
  }
  void _showMessageAlert(BuildContext context, title, message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      _showMessageAlert(context, "Notifikasi", message.data['type']);
    }
  }

  List<Widget> getPengajuanList() {
    List<Widget> childs = [];
    if(pengajuan.length > 0){
      for (var i = 0; i < pengajuan.length; i++) {
        // childs.add(new ListItem('abcd ' + $i));
        childs.add(new DoctorItem(id_pengajuan: pengajuan[i]['id_pengajuan'], nama_pengajuan: pengajuan[i]['nama_pengajuan'], jenis_pengajuan: pengajuan[i]['nama_fitur'], status_pengajuan: pengajuan[i]['nama_kode_status'], jabatan_pengajuan: pengajuan[i]['jabatan_pengajuan'], tanggal_pengajuan: pengajuan[i]['tanggal_pengajuan']));
      }
    }else{
      childs.add(new DoctorItem(id_pengajuan: "Tidak Ada Pengajuan", nama_pengajuan: "-", jenis_pengajuan: "-", status_pengajuan: "-", jabatan_pengajuan: "-", tanggal_pengajuan: "-"));
    }

    return childs;
  }
  Future<void> getPengajuan() async {
    final prefs = await SharedPreferences.getInstance();
    final String endpoint = 'https://haver.my.id/api-services/public/api/v1/admin/getPengajuan';

    // print(result);
    // final Map<String, String> headers = {
    //   'Content-Type': 'application/json', // Specify content type as JSON
    // };

    final resPref = prefs.getString("user");
    final token = prefs.getString("token");

    final Map<String, dynamic> result = jsonDecode(resPref!);

    final Map<String,String> headers = {
      'Authorization' : 'Bearer ${token}',
      'Content-Type' : 'application/json'
    };
    try {

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers,
        body: jsonEncode({
          "id_user": result['id_user'],
          "limit" : 5
        }),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // _showMessageAlert(context, "Notifikasi !!!", responseData['responseMessage']);
        if(responseData['responseCode'] == "00"){
          setState(() {
            pengajuan = responseData['responseData'];
          });
        }
      } else {
        // Handle errors here, e.g., show an error message
        _showMessageAlert(context, "Notifikasi !!!", responseData['responseMessage']);
      }
    } catch (e) {
      // Handle exceptions, e.g., network issues
      _showMessageAlert(context, "Notifikasi !!!", "${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/background.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello,",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "${nama_user}",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      ],

                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          "https://haver.my.id/api-services/public/getPhoto/${(id_user != "")?id_user:"999999"}", // Replace with your image URL
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset(
                        "assets/surgeon.png",
                        width: 92,
                        height: 100,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "S.I.A.P",
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          const SizedBox(
                            width: 120,
                            child: Text(
                              "Sistem Informasi Administrasi Personel",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Layanan Presisi",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Pilih layanan yang anda butuhkan",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                        children: <Widget> [

                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    // color: Color.fromRGBO(218, 165, 32, 0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey.withOpacity(0.5),
                                    //     spreadRadius: 5,
                                    //     blurRadius: 7,
                                    //     offset: Offset(0, 3), // changes position of shadow
                                    //   ),
                                    // ],
                                    border: Border.all(color: Color.fromRGBO(218,165,32, 1), width: 2)
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SpecialistItem(imagePath: "assets/naik_pangkat_new.png", imageName: "", status_user: status_user, status_fitur: "1", color: Colors.black, icon: Icons.move_up_sharp, label: "NAIK PANGKAT")
                                  ],
                                ),
                                height: 100,
                                width: 75,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    // color: Color.fromRGBO(255, 0, 0, 0.8),
                                    borderRadius: BorderRadius.circular(16),
                                    // boxShadow: [
                                    //     BoxShadow(
                                    //     color: Colors.grey.withOpacity(0.5),
                                    //     spreadRadius: 5,
                                    //     blurRadius: 7,
                                    //     offset: Offset(0, 3), // changes position of shadow
                                    //   ),
                                    // ],
                                    border: Border.all(color: Colors.red, width: 2)
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SpecialistItem(imagePath: "assets/kenaikan_gaji_berkala_new.png", imageName: "", status_user: status_user, status_fitur: "2", color: Colors.black, icon: Icons.money, label: "KENAIKAN GAJI BERKALA")
                                  ],
                                ),
                                height: 100,
                                width: 75,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    // color: Colors.black,
                                    borderRadius: BorderRadius.circular(16),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.grey.withOpacity(0.5),
                                    //     spreadRadius: 5,
                                    //     blurRadius: 7,
                                    //     offset: Offset(0, 3), // changes position of shadow
                                    //   ),
                                    // ],
                                    border: Border.all(color: Colors.black, width: 2)
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SpecialistItem(imagePath: "assets/pensiun.png", imageName: "", status_user: status_user, status_fitur: "3", color: Colors.black, icon: Icons.family_restroom, label: "PENGAKHIRAN DINAS ")
                                  ],
                                ),
                                height: 100,
                                width: 75,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10
                                ),
                              )
                            ],
                          ),
                        ],
                    ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // SizedBox(
                //   height: 60,
                //   child: ListView(
                //
                //     scrollDirection: Axis.horizontal,
                //     children: [
                //       SpecialistItem(
                //         imagePath: "assets/clean.png",
                //         imageName: "Naik Pangkat",
                //         status_user: status_user,
                //         status_fitur : "1",
                //         icon: Icons.upgrade,
                //         label: "Naik Pangkat",
                //         color: Colors.blue,
                //       ),
                //       // SizedBox(
                //       //   width: 8,
                //       // ),
                //       SpecialistItem(
                //         imagePath: "assets/knife.png",
                //         imageName: "Kgb",
                //         status_user: status_user,
                //         status_fitur : "2",
                //         icon: Icons.money,
                //         label: "KGB",
                //         color: Colors.blue,
                //       ),
                //       // SizedBox(
                //       //   width: 8,
                //       // ),
                //       SpecialistItem(
                //         imagePath: "assets/lungs.png",
                //         imageName: "Pensiun",
                //         status_user: status_user,
                //         status_fitur : "3",
                //         icon: Icons.family_restroom,
                //         label: "Pensiun",
                //         color: Colors.blue,
                //       ),
                //
                //     ],
                //   ),
                // )
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "List Pengajuan Terbaru",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: getPengajuanList(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
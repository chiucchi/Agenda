import 'package:agenda/calendar_client.dart';
import 'package:agenda/calendario.dart';
import 'package:agenda/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as cal;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var _clientID = new ClientId(
      "477431856187-06o4k0itnqb47ndvn45oe03tj04mvaj9.apps.googleusercontent.com",
      "");
  const _scopes = const [cal.CalendarApi.CalendarScope];
  await clientViaUserConsent(_clientID, _scopes, prompt)
      .then((AuthClient client) async {
    CalendarClient.calendar = cal.CalendarApi(client);
  });
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    localizationsDelegates: [GlobalMaterialLocalizations.delegate,GlobalWidgetsLocalizations.delegate],
      supportedLocales: [const Locale('pt', 'BR')],
  ));
}

void prompt(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController cepController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController searchemailController = TextEditingController();
  TextEditingController complementoController = TextEditingController();
  TextEditingController numeroController = TextEditingController();
  TextEditingController dataController = TextEditingController();
  CalendarClient calendarClient = CalendarClient();
  DateTime selectedDate = DateTime.now();
  var id, aniversario;
  String _resultado = "";
  List<EventInfo> aniversarios = new List();

  _inicializaFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  _pegaEndereco() async {
    print("CEP: " + cepController.text);
    String url = "https://viacep.com.br/ws/${cepController.text}/json/";
    http.Response response;
    response = await http.get(url);
    Map<String, dynamic> retorno = json.decode(response.body);
    String logradouro = retorno["logradouro"];
    String bairro = retorno["bairro"];
    String localidade = retorno["localidade"];

    setState(() {
      //configurar o _resultado
      _resultado = "$logradouro, $bairro, $localidade ";
      print('RESULTADO: ' + _resultado);
    });
  }

  _selecionarData(BuildContext context) async {
    dataController.text = "";
    aniversario = "-1";
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dataController.text = DateFormat.yMMMMd('pt_BR').format(selectedDate);
        aniversario = dataController.text;
      });
    }
  }

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var snapshots = db
        .collection("Contatos")
        .where('excluido', isEqualTo: false)
        .snapshots();

    _showresult(BuildContext context, String resultado) {
      return showDialog(
          context: context,
          barrierDismissible: true,
          builder: (param) {
            return AlertDialog(
              actions: [
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text('Ok', style: TextStyle(color: HexColor("#263D49"))),
                ),
              ],
              title: Text('Resultado da pesquisa:'),
              content: Text(resultado),
            );
          });
    }

    _showcontact(BuildContext context, var item) {
      return showDialog(
          context: context,
          barrierDismissible: true,
          builder: (param) {
            return AlertDialog(
              actions: [
                FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Fechar',
                      style: TextStyle(color: HexColor("#263D49"))),
                ),
              ],
              title: Text('Contato'),
              content: Text('Nome: ' +
                  item['nome'] +
                  '\nNúmero: ' +
                  item['numero'].toString() +
                  '\nEmail: ' +
                  item['email'] +
                  '\nEndereço:  ' +
                  item['endereco'] +
                  ', ' +
                  item['numeroend'] +
                  '\nComplemento: ' +
                  item['complemento']),
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("AGENDA", style: TextStyle(color: HexColor("#FAF6B9"))),
        backgroundColor: HexColor("#263D49"),
        bottom: TabBar(
          unselectedLabelColor: HexColor("#EBE6D8"),
          labelColor: Colors.white,
          tabs: [
            Tab(text: "Cadastrar"),
            Tab(text: "Listar"),
            Tab(text: "Atualizar"),
            Tab(text: "Aniversários"),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Text("Insira os dados do novo contato",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                // SizedBox(height: 10.0),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "NOME",
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "E-MAIL",
                        ),
                      ),
                      TextField(
                        controller: phonenumberController,
                        keyboardType: TextInputType.number,
                        maxLength: 9,
                        decoration: InputDecoration(
                          labelText: "NUMERO",
                          counterText: '',
                        ),
                      ),
                      TextField(
                        controller: dataController,
                        onTap: () => _selecionarData(context),
                        decoration: InputDecoration(
                          labelText: "ANIVERSÁRIO",
                        ),
                      ),
                      TextField(
                        controller: cepController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration: InputDecoration(
                          labelText: "CEP",
                          counterText: '',
                        ),
                      ),
                      TextField(
                        controller: numeroController,
                        decoration: InputDecoration(
                          labelText: "NUMERO",
                        ),
                      ),
                      TextField(
                        controller: complementoController,
                        decoration: InputDecoration(
                          labelText: "COMPLEMENTO",
                        )
                      ),
                      SizedBox(height: 30.0),
                      Container(
                        height: 50.0,
                        width: 300.0,
                        child: RaisedButton(
                            color: HexColor("#263D49"),
                            onPressed: () async {
                              _inicializaFirebase();
                              _pegaEndereco();
                              String eventId = "";
                              aniversario = dataController.text;
                              var nome = nameController.text;
                              int startTimeInEpoch = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                              ).millisecondsSinceEpoch;

                              int endTimeInEpoch = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                              ).millisecondsSinceEpoch;

                              await calendarClient
                                  .insert(
                                      title: ("Aniversário " + nome),
                                      // description: "aniversario",
                                      startTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              startTimeInEpoch),
                                      endTime:
                                          DateTime.fromMillisecondsSinceEpoch(
                                              endTimeInEpoch))
                                  .then((eventData) async {
                                eventId = eventData;
                                print(eventId);
                              });
                              var idAniversario = eventId;
                              await db.collection("Contatos").add({
                                'nome': nameController.text,
                                'email': emailController.text,
                                'numero': int.parse(phonenumberController.text),
                                'cep': int.parse(cepController.text),
                                'endereco': _resultado, // retorno da api
                                'numeroend': numeroController.text,
                                'complemento': complementoController.text,
                                'idAniversario': idAniversario,
                                'excluido': false,
                              });
                              nameController.text = "";
                              emailController.text = "";
                              phonenumberController.text = "";
                              cepController.text = "";
                              numeroController.text = "";
                              complementoController.text = "";
                            },
                            child: Text("SALVAR",
                                style: TextStyle(color: HexColor("#EBE6D8")))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder(
              // listar
              stream: snapshots,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      var item = snapshot.data.documents[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, left: 8.0, right: 8.0),
                        child: Card(
                          elevation: 8.0,
                          color: HexColor("#365261"),
                          child: ListTile(
                            title: Text(item['nome'],
                                style: TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(item['email'],
                                style: TextStyle(
                                    fontSize: 18.0, color: Colors.white)),
                            onTap: () {
                              _showcontact(context, item);
                            },
                          ),
                        ),
                      );
                    });
              }),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: ListView(
              children: [
                Text("Busque o contato que deseja atualizar",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                SizedBox(height: 10.0),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 250.0,
                            child: TextField(
                                controller: searchemailController,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                )),
                          ),
                          MaterialButton(
                            height: 25.0,
                            onPressed: () {
                              _inicializaFirebase();
                              if (searchemailController.text != "") {
                                db
                                    .collection("Contatos")
                                    .where("email",
                                        isEqualTo: searchemailController.text)
                                    .limit(1)
                                    .get()
                                    .then((value) {
                                  value.docs.forEach((result) {
                                    print(result.data());
                                    if (result.data()['excluido'] == false) {
                                      _showresult(
                                          context,
                                          result.data()['nome'] +
                                              ' foi encontrado');
                                      id = result.id;
                                      print(result.id);
                                    }
                                  });
                                });
                              } else {
                                _showresult(context,
                                    'Contato não encontrado, tente novamente');
                              }
                            },
                            color: HexColor("#263D49"),
                            textColor: Colors.white,
                            child: Icon(
                              Icons.search,
                              size: 24,
                            ),
                            padding: EdgeInsets.all(16),
                            shape: CircleBorder(),
                          )
                        ],
                      ),
                      SizedBox(height: 25.0),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: "NOME",
                              ),
                            ),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: "E-MAIL",
                              ),
                            ),
                            TextField(
                              controller: cepController,
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              decoration: InputDecoration(
                                labelText: "CEP",
                                counterText: '',
                              ),
                            ),
                            TextField(
                              controller: numeroController,
                              decoration: InputDecoration(
                                labelText: "NUMERO",
                              ),
                            ),
                            TextField(
                              controller: complementoController,
                              decoration: InputDecoration(
                                labelText: "COMPLEMENTO",
                              ),
                            ),
                            SizedBox(height: 35.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton(
                                  child: Icon(Icons.edit, size: 50.0),
                                  onPressed: () async {
                                    if (nameController.text != "") {
                                      await db
                                          .collection("Contatos")
                                          .doc(id)
                                          .update({
                                            'nome': nameController.text,
                                          })
                                          .then(
                                              (value) => print("Name Updated"))
                                          .catchError((error) => print(
                                              "Failed to update user name: $error"));
                                    }
                                    if (emailController.text != "") {
                                      await db
                                          .collection("Contatos")
                                          .doc(id)
                                          .update({
                                            'email': emailController.text,
                                          })
                                          .then(
                                              (value) => print("Email Updated"))
                                          .catchError((error) => print(
                                              "Failed to update user email: $error"));
                                    }
                                    if (phonenumberController.text != "") {
                                      await db
                                          .collection("Contatos")
                                          .doc(id)
                                          .update({
                                            'numero': int.parse(
                                                phonenumberController.text),
                                          })
                                          .then((value) =>
                                              print("Phone Number Updated"))
                                          .catchError((error) => print(
                                              "Failed to update user phonenumber: $error"));
                                    }
                                    if (cepController.text != "") {
                                      // print("CEP: " + cepController.text);
                                      _inicializaFirebase();
                                      _pegaEndereco();
                                      await db
                                          .collection("Contatos")
                                          .doc(id)
                                          .update({
                                            'cep':
                                                int.parse(cepController.text),
                                            'endereco': _resultado,
                                          })
                                          .then((value) => print("Cep Updated"))
                                          .catchError((error) => print(
                                              "Failed to update user cep: $error"));
                                    }
                                    if (numeroController.text != "") {
                                      await db
                                          .collection("Contatos")
                                          .doc(id)
                                          .update({
                                            'numeroend': numeroController.text,
                                          })
                                          .then((value) =>
                                              print("Numero end Updated"))
                                          .catchError((error) => print(
                                              "Failed to update user numero end: $error"));
                                    }
                                    if (complementoController.text != "") {
                                      await db
                                          .collection("Contatos")
                                          .doc(id)
                                          .update({
                                            'complemento':
                                                complementoController.text,
                                          })
                                          .then((value) =>
                                              print("Complemento Updated"))
                                          .catchError((error) => print(
                                              "Failed to update user complemento: $error"));
                                    }

                                    await db
                                        .collection("Contatos")
                                        .doc(id)
                                        .update({
                                          'excluido': false,
                                        })
                                        .then((value) =>
                                            print("Excluido Updated"))
                                        .catchError((error) => print(
                                            "Failed to update user: $error"));
                                  },
                                ),
                                FlatButton(
                                  child: Icon(Icons.delete, size: 50.0),
                                  onPressed: () async {
                                    await db
                                        .collection("Contatos")
                                        .doc(id)
                                        .update({'excluido': 'true'})
                                        .then((value) => print("User Deleted"))
                                        .catchError((error) => print(
                                            "Failed to delete user: $error"));
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Calendario(),
        ],
        controller: _tabController,
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
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
  var id;

  _inicializaFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }

  @override
  void initState() {
    _tabController = new TabController(length: 3, vsync: this);
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

    /* FirebaseFirestore.instance
        .collection('Contatos')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) => print('Dados:\n${f.data}\n\n'));
    }); */

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
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: [
          Padding(
            padding: EdgeInsets.all(35.0),
            child: ListView(
              children: [
                Text("Insira os dados do novo contato",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                SizedBox(height: 10.0),
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
                        controller: cepController,
                        keyboardType: TextInputType.number,
                        maxLength: 8,
                        decoration: InputDecoration(
                          labelText: "CEP",
                          counterText: '',
                        ),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: "ENDEREÇO",
                        ),
                      ),
                      SizedBox(height: 50.0),
                      Container(
                        height: 50.0,
                        width: 300.0,
                        child: RaisedButton(
                            color: HexColor("#263D49"),
                            onPressed: () async {
                              _inicializaFirebase();
                              await db.collection("Contatos").add({
                                'nome': nameController.text,
                                'email': emailController.text,
                                'numero': int.parse(phonenumberController.text),
                                'cep': int.parse(cepController.text),
                                'endereco': addressController.text,
                                'excluido': false,
                              });
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
                          ),
                        ),
                      );
                    });
              }),
          Padding(
            padding: EdgeInsets.all(35.0),
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
                              controller: addressController,
                              decoration: InputDecoration(
                                labelText: "ENDEREÇO",
                              ),
                            ),
                            SizedBox(height: 35.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                FlatButton(
                                  child: Icon(Icons.edit, size: 50.0),
                                  onPressed: () async {
                                    await db.collection("Contatos")
                                        .doc(id)
                                        .update({
                                          'nome': nameController.text,
                                          'email': emailController.text,
                                          'numero': int.parse(phonenumberController.text),
                                          'cep': int.parse(cepController.text),
                                          'endereco': addressController.text,
                                          'excluido': false,
                                        })
                                        .then((value) => print("User Updated"))
                                        .catchError((error) => print(
                                            "Failed to update user: $error"));
                                  },
                                ),
                                FlatButton(
                                  child: Icon(Icons.delete, size: 50.0),
                                  onPressed: () async {
                                    await db.collection("Contatos")
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
          )
        ],
        controller: _tabController,
      ),
    );
  }
}

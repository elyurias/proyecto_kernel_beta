import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/src/material/dialog.dart' as Dialog;
import 'package:http/http.dart' as http;
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List clientes;
  List dataJSON;
  final double listSpec = 4.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String stateText;
  String _mySelection;
  String _mySelection2;
  int idCliente;
  String _selectedLocation;

  /////// Datos ocupados para json card y spinner
  Future<String> getData() async {
    var resObCli = await http.get(
      Uri.encodeFull(
          "http://sack.kerneltechnologiesgroup.com/kernelitservices/cliente/obtenerClientes"),
      headers: {"Accept": "application/json"},
    );

    var resFilter = await http.get(
      Uri.encodeFull(
          "http://sack.kerneltechnologiesgroup.com/kernelitservices/cliente/obtenerClientes"),
      headers: {"Accept": "application/json"},
    );
    this.setState(() {
      this.clientes = json.decode(resObCli.body)["List"];
    });
  }

  Future<void> getProjects(int id) async {
    this.getData();
    try {
      var response = await http.get(
        Uri.encodeFull(
            "http://sack.kerneltechnologiesgroup.com/kernelitservices/proyecto/obtenerDatosReporteProyectos/" +
                id.toString() +
                "/a/a/a/a"),
        headers: {"Accept": "application/json"},
      );

      this.setState(() {
        this.dataJSON = json.decode(response.body)["List"];
      });
    } catch (e) {
      print("Me lleva, ya trono! ERRROR: " + e);
    }
  }

  @override
  void initState() {
    //this.ambildate();
    this.getData();
    this.getProjects(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Bienvenido usuario "recibir nombre"'),
        automaticallyImplyLeading: false,
        elevation: 0.0,
      ),
      //////////////
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Vista de Boton para ingresr fecha inicio y feca fin de un proyecto
          Container(
            height: 50,
            child: ListView(
              children: <Widget>[
                (stateText != null) ? Text(stateText) : Container(),
                SizedBox(height: listSpec),
                RaisedButton(
                  child: Text(' Fecha Inicio y Fin de Proyecto'),
                  onPressed: () {
                    print("Hola");
                    //showPickerDateRange(context);
                  },
                ),
              ],
            ),
          ),

          // spinner para listar CLientes
          Container(
            /////spinner
            child: new DropdownButton(
              hint: Text('Selecciona un cliente'), // Not necessary for Option 1
              iconSize: 0.0,
              items: clientes.map((item) {
                return new DropdownMenuItem(
                  child: new Text(
                    item['nombre'],
                  ),
                  value: item['id_cliente'].toString(),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  _mySelection = newVal;
                  idCliente = int.tryParse(_mySelection);
                  getProjects(idCliente); //para extraer los proyectos
                });
              },
              value: _mySelection,
            ),
          ),

          Container(
            height: 50,
            /////spinner
            child: new DropdownButton(
              hint:
                  Text('Selecciona un proyecto'), // Not necessary for Option 1
              iconSize: 0.0,
              items: dataJSON.map((item) {
                return new DropdownMenuItem(
                  child: new Text(item['nombre'].toString()),
                  value: item['idProyecto'].toString(),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  _mySelection2 = newVal;
                  print(_mySelection2);
                  _mySelection2 = null;
                });
              },
              value: _mySelection2,
            ),
          ),

          // creacion y llamado de card para almacenar los datos recibidos por el WS

          Expanded(
            child: new Card(
              color: new Color(0xFF333366),
              elevation: 1.0,
              child: new ListView.builder(
                itemCount: dataJSON == null ? 0 : dataJSON.length,
                itemBuilder: (context, i) {
                  return new Container(
                      color: new Color(0xFF333366),
                      padding: new EdgeInsets.all(10.0),
                      child: new Card(
                          child: new Container(
                              padding: new EdgeInsets.all(20.0),
                              child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text(
                                    "Nombre de cliente : " +
                                        dataJSON[i]['cliente']['nombre']
                                            .toString(),
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.blue),
                                  ),
                                  new Text("Proyecto: " +
                                      dataJSON[i]['nombre'].toString()),
                                  new Text("Fecha de inicio: " +
                                      dataJSON[i]['fecha_inicio'].toString()),
                                  new Text("Fecha de fin: " +
                                      dataJSON[i]['fecha_fin'].toString()),
                                  new Text("Horas estimadas: " +
                                      "0000" /*+dataJSON[i]['fecha_termino'].toString()*/),
                                  new Text("horas reales: " +
                                      dataJSON[i]['tiempo_total'].toString()),
                                ],
                              ))));
                },
              ),
              //),
            ),
            //fin de mi card
          ),
          new Card(
            elevation: 1.0,
            child: new Padding(
              // Esta seccion sera para los botones de acciones
              padding: new EdgeInsets.all(
                  7.0), // Un padding general entre cada elemento
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Agregamos los botones de tipo Flat, un icono, un texto y un evento
                  new FlatButton.icon(
                    icon: const Icon(Icons.border_clear,
                        size: 28.0, color: Colors.green),
                    label: const Text('Crear EXCEL'),
                    onPressed: () {
                      print('Creando EXCEL');
                    },
                  ),

                  new FlatButton.icon(
                    icon: const Icon(Icons.picture_as_pdf,
                        size: 28.0, color: Colors.redAccent),
                    label: const Text('Crear PDF'),
                    onPressed: () {
                      print('CREANDO PDF');
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

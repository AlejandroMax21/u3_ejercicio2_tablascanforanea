import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'cita.dart';
import 'persona.dart';

class DB {
  static Database? _database;

  // Singleton para la base de datos
  static Future<Database> _conectarDB() async {
    if (_database != null) return _database!;

    _database = await openDatabase(
      join(await getDatabasesPath(), "ejercicio2.db"),
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE PERSONA(IDPERSONA INTEGER PRIMARY KEY AUTOINCREMENT, NOMBRE TEXT, TELEFONO TEXT);"
        );
        await db.execute(
            "CREATE TABLE CITA(IDCITA INTEGER PRIMARY KEY AUTOINCREMENT, LUGAR TEXT, FECHA TEXT, HORA TEXT, ANOTACIONES TEXT, IDPERSONA INTEGER, FOREIGN KEY (IDPERSONA) REFERENCES PERSONA(IDPERSONA) ON DELETE CASCADE ON UPDATE CASCADE)"
        );
      },
    );
    return _database!;
  }

  // ***********************************************
  //                  Persona
  // ***********************************************
  static Future<int> insertarPersona(Persona p) async {
    Database base = await _conectarDB();
    return base.insert("PERSONA", p.toJSON());
  }

  static Future<int> eliminarPersona(int idpersona) async {
    Database base = await _conectarDB();
    return base.delete("PERSONA", where: "IDPERSONA=?", whereArgs: [idpersona]);
  }

  static Future<List<Persona>> mostrarTodosPersona() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> temp = await base.query("PERSONA");

    print("Query resultado: ${temp.length} personas encontradas");

    return List.generate(temp.length, (contador) {
      return Persona(
        idpersona: temp[contador]['IDPERSONA'],
        nombre: temp[contador]['NOMBRE'],
        telefono: temp[contador]['TELEFONO'],
      );
    });
  }

  static Future<int> actualizarPersona(Persona p) async {
    Database base = await _conectarDB();
    return base.update(
      "PERSONA",
      p.toJSON(),
      where: "IDPERSONA=?",
      whereArgs: [p.idpersona],
    );
  }

  // ***********************************************
  //                  CITA
  // ***********************************************
  static Future<int> insertarCita(Cita c) async {
    Database base = await _conectarDB();
    return base.insert("CITA", c.toJSON());
  }

  static Future<int> eliminarCita(int idcita) async {
    Database base = await _conectarDB();
    return base.delete("CITA", where: "IDCITA=?", whereArgs: [idcita]);
  }

  static Future<List<Cita>> mostrarTodosCita() async {
    Database base = await _conectarDB();
    List<Map<String, dynamic>> temp = await base.query("CITA");

    return List.generate(temp.length, (contador) {
      return Cita(
        idcita: temp[contador]['IDCITA'],
        anotaciones: temp[contador]['ANOTACIONES'],
        lugar: temp[contador]['LUGAR'],
        fecha: temp[contador]['FECHA'],
        hora: temp[contador]['HORA'],
        idpersona: temp[contador]['IDPERSONA'],
      );
    });
  }

  static Future<int> actualizarCita(Cita c) async {
    Database base = await _conectarDB();
    return base.update(
      "CITA",  // Corregido: era "Cita" (minúsculas)
      c.toJSON(),
      where: "IDCITA=?",
      whereArgs: [c.idcita],
    );
  }


  static Future<void> cerrarDB() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }


  static Future<void> eliminarDB() async {
    await cerrarDB();
    String path = join(await getDatabasesPath(), "ejercicio2.db");
    await deleteDatabase(path);
  }
}
import 'package:sqflite/sqflite.dart';
class Cita{

  int idcita, idpersona;
  String lugar, fecha, hora, anotaciones;

  Cita ({
    required this.idcita,
    required this.lugar,
    required this.fecha,
    required this.hora,
    required this.anotaciones,
    required this.idpersona
});
  Map<String, dynamic> toJSON(){
    return{
      "lugar":lugar,
      "fecha":fecha,
      "hora":hora,
      "anotaciones":anotaciones,
      "idpersona": idpersona
    };
  }
}
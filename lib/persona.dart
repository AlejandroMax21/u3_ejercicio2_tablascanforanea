class Persona {
  int? idpersona;
  String nombre;
  String telefono;

  Persona({
    this.idpersona,
    required this.nombre,
    required this.telefono,
  });

  Map<String, dynamic> toJSON() {
    return {
      "nombre": nombre,
      "telefono": telefono,
    };
  }

  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      idpersona: map['idpersona'],
      nombre: map['nombre'],
      telefono: map['telefono'],
    );
  }
}

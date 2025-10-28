import 'package:flutter/material.dart';
import 'basedatosforaneas.dart';
import 'cita.dart';
import 'persona.dart';
import 'package:intl/intl.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> with SingleTickerProviderStateMixin {
  List<Cita> citas = [];
  List<Persona> personas = [];
  late AnimationController _animationController;

  final lugarCtrl = TextEditingController();
  final fechaCtrl = TextEditingController();
  final horaCtrl = TextEditingController();
  final anotacionesCtrl = TextEditingController();
  int? personaSeleccionada;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    cargarDatos();
  }

  @override
  void dispose() {
    _animationController.dispose();
    lugarCtrl.dispose();
    fechaCtrl.dispose();
    horaCtrl.dispose();
    anotacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> cargarDatos() async {
    final p = await DB.mostrarTodosPersona();
    final c = await DB.mostrarTodosCita();
    setState(() {
      personas = p;
      citas = c;
    });
    _animationController.forward(from: 0);
  }

  void mostrarFormulario([Cita? cita]) async {
    final p = await DB.mostrarTodosPersona();

    if (cita != null) {
      lugarCtrl.text = cita.lugar;
      fechaCtrl.text = cita.fecha;
      horaCtrl.text = cita.hora;
      anotacionesCtrl.text = cita.anotaciones;
      personaSeleccionada = cita.idpersona;
    } else {
      lugarCtrl.clear();
      fechaCtrl.clear();
      horaCtrl.clear();
      anotacionesCtrl.clear();
      personaSeleccionada = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => _FormularioCita(
        cita: cita,
        lugarCtrl: lugarCtrl,
        fechaCtrl: fechaCtrl,
        horaCtrl: horaCtrl,
        anotacionesCtrl: anotacionesCtrl,
        personaSeleccionada: personaSeleccionada,
        personasIniciales: p,
        onGuardar: () async {
          await cargarDatos();
        },
      ),
    );
  }

  Future<void> eliminar(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Confirmar eliminación'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de eliminar esta cita?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await DB.eliminarCita(id);
      await cargarDatos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Cita eliminada correctamente'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Citas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => mostrarFormulario(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
        elevation: 4,
      ),
      body: citas.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note_outlined,
                size: 80,
                color: Colors.deepPurple.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay citas programadas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón + para agregar',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: citas.length,
        itemBuilder: (context, i) {
          final c = citas[i];
          final persona = personas.firstWhere(
                (p) => p.idpersona == c.idpersona,
            orElse: () => Persona(idpersona: 0, nombre: 'Desconocido', telefono: ''),
          );
          return FadeTransition(
            opacity: _animationController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.3, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.easeOut,
              )),
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.event,
                              color: Colors.deepPurple,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.lugar,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      persona.nombre,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  c.fecha,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 6),
                              Text(
                                c.hora,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (c.anotaciones.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  c.anotaciones,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => mostrarFormulario(c),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange.shade700,
                              side: BorderSide(color: Colors.orange.shade700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => eliminar(c.idcita),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Eliminar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade700),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FormularioCita extends StatefulWidget {
  final Cita? cita;
  final TextEditingController lugarCtrl;
  final TextEditingController fechaCtrl;
  final TextEditingController horaCtrl;
  final TextEditingController anotacionesCtrl;
  final int? personaSeleccionada;
  final List<Persona> personasIniciales;
  final VoidCallback onGuardar;

  const _FormularioCita({
    this.cita,
    required this.lugarCtrl,
    required this.fechaCtrl,
    required this.horaCtrl,
    required this.anotacionesCtrl,
    required this.personaSeleccionada,
    required this.personasIniciales,
    required this.onGuardar,
  });

  @override
  State<_FormularioCita> createState() => _FormularioCitaState();
}

class _FormularioCitaState extends State<_FormularioCita> {
  late int? _personaSeleccionada;
  List<Persona> _personas = [];

  @override
  void initState() {
    super.initState();
    _personaSeleccionada = widget.personaSeleccionada;
    _personas = List.from(widget.personasIniciales);
  }

  Future<void> _recargarPersonas() async {
    final p = await DB.mostrarTodosPersona();
    setState(() {
      _personas = p;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Lista actualizada'),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.cita == null ? Icons.event_note : Icons.edit_calendar,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.cita == null ? "Nueva Cita" : "Editar Cita",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: widget.lugarCtrl,
              decoration: InputDecoration(
                labelText: 'Lugar',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.fechaCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.deepPurple,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  widget.fechaCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.horaCtrl,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Hora',
                prefixIcon: const Icon(Icons.access_time),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.deepPurple,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  widget.horaCtrl.text = picked.format(context);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.anotacionesCtrl,
              decoration: InputDecoration(
                labelText: 'Anotaciones',
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey.shade50,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _personaSeleccionada,
                        hint: Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.grey.shade600),
                            const SizedBox(width: 8),
                            const Text('Selecciona persona'),
                          ],
                        ),
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        items: _personas.map((p) {
                          return DropdownMenuItem<int>(
                            value: p.idpersona,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.deepPurple.shade100,
                                  child: Text(
                                    p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
                                    style: TextStyle(
                                      color: Colors.deepPurple.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(p.nombre)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          setState(() {
                            _personaSeleccionada = v;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  tooltip: 'Actualizar lista',
                  onPressed: _recargarPersonas,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.shade50,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.lugarCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.white),
                                SizedBox(width: 8),
                                Text('El lugar no puede estar vacío'),
                              ],
                            ),
                            backgroundColor: Colors.orange.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }

                      if (widget.fechaCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.warning_amber, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Selecciona una fecha'),
                              ],
                            ),
                            backgroundColor: Colors.orange.shade700,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                        return;
                      }

                      if (widget.cita == null) {
                        await DB.insertarCita(Cita(
                          idcita: 0,
                          lugar: widget.lugarCtrl.text,
                          fecha: widget.fechaCtrl.text,
                          hora: widget.horaCtrl.text,
                          anotaciones: widget.anotacionesCtrl.text,
                          idpersona: _personaSeleccionada ?? 0,
                        ));
                      } else {
                        await DB.actualizarCita(Cita(
                          idcita: widget.cita!.idcita,
                          lugar: widget.lugarCtrl.text,
                          fecha: widget.fechaCtrl.text,
                          hora: widget.horaCtrl.text,
                          anotaciones: widget.anotacionesCtrl.text,
                          idpersona: _personaSeleccionada ?? 0,
                        ));
                      }
                      Navigator.pop(context);
                      widget.onGuardar();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                widget.cita == null
                                    ? 'Cita guardada correctamente'
                                    : 'Cita actualizada correctamente',
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text('Guardar', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
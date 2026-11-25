import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';

class AgendaEvent {
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;

  const AgendaEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
  });
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  static final List<AgendaEvent> events = [];

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  Future<void> addEvent() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo compromisso'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Título do compromisso',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o título.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Adicione detalhes (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Data',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (date != null) {
                            setDialogState(() {
                              selectedDate = date;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(formatDate(selectedDate)),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'Horário',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );

                          if (time != null) {
                            setDialogState(() {
                              selectedTime = time;
                            });
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text(formatTime(selectedTime)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    setState(() {
                      events.add(
                        AgendaEvent(
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          date: selectedDate,
                          time: selectedTime,
                        ),
                      );

                      events.sort((a, b) {
                        final dateComparison = a.date.compareTo(b.date);

                        if (dateComparison != 0) {
                          return dateComparison;
                        }

                        final aMinutes = a.time.hour * 60 + a.time.minute;
                        final bMinutes = b.time.hour * 60 + b.time.minute;

                        return aMinutes.compareTo(bMinutes);
                      });
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  void removeEvent(int index) {
    setState(() {
      events.removeAt(index);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Compromisso removido.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addEvent,
        backgroundColor: AppTheme.forestGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo compromisso'),
      ),

      body: events.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 72,
                      color: AppTheme.sageGreen,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sua agenda está vazia',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione compromissos para organizar '
                      'as atividades do Estokê.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.lightGreen,
                      child: Icon(
                        Icons.event_note,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    title: Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${formatDate(event.date)} • '
                            '${formatTime(event.time)}',
                          ),
                          if (event.description.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(event.description),
                          ],
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: 'Excluir compromisso',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => removeEvent(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

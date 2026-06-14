import 'package:flutter/material.dart';

import '../services/beep_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../theme/zarpafit_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settingsService,
  });

  final SettingsService settingsService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _restSeconds;
  late bool _soundEnabled;
  late int _beepFrom;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    _restSeconds = widget.settingsService.defaultRestSeconds;
    _soundEnabled = widget.settingsService.countdownSoundEnabled;
    _beepFrom = widget.settingsService.countdownBeepFrom;
    _reminderEnabled = widget.settingsService.reminderEnabled;
    _reminderTime = widget.settingsService.reminderTime;
  }

  Future<void> _saveAndPop() async {
    widget.settingsService.defaultRestSeconds = _restSeconds;
    widget.settingsService.countdownSoundEnabled = _soundEnabled;
    widget.settingsService.countdownBeepFrom = _beepFrom;
    widget.settingsService.reminderEnabled = _reminderEnabled;
    widget.settingsService.reminderTime = _reminderTime;
    final notifications = NotificationService.instance;
    if (_reminderEnabled) {
      await notifications.requestPermissions();
      await notifications.scheduleDailyReminder(_reminderTime);
    } else {
      await notifications.cancelDailyReminder();
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  String _formatTimeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Widget _sectionHeader(String label) {
    return Row(
      children: [
        Container(width: 18, height: 2, color: ZarpaColors.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: ZarpaFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ZarpaColors.muted,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  String _formatSeconds(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        actions: [
          TextButton(
            onPressed: _saveAndPop,
            child: const Text('Guardar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección: Apariencia
          _sectionHeader('APARIENCIA'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tema'),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistema'),
                          icon: Icon(Icons.brightness_auto, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Claro'),
                          icon: Icon(Icons.light_mode, size: 18),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Oscuro'),
                          icon: Icon(Icons.dark_mode, size: 18),
                        ),
                      ],
                      selected: {widget.settingsService.themeMode},
                      onSelectionChanged: (selection) => setState(() {
                        // Se aplica en vivo; no requiere "Guardar".
                        widget.settingsService.themeMode = selection.first;
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección: Recordatorio de entrenamiento
          _sectionHeader('RECORDATORIO'),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Recordatorio diario'),
                  subtitle: const Text('Un aviso para no perder la racha'),
                  value: _reminderEnabled,
                  onChanged: (v) => setState(() => _reminderEnabled = v),
                ),
                if (_reminderEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Hora del aviso'),
                    subtitle: Text(_formatTimeOfDay(_reminderTime)),
                    trailing: const Icon(Icons.schedule),
                    onTap: _pickReminderTime,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sección: Temporizador de descanso
          _sectionHeader('TEMPORIZADOR DE DESCANSO'),
          const SizedBox(height: 16),

          // Duración predeterminada
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Descanso predeterminado'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed: _restSeconds > 5
                            ? () => setState(() => _restSeconds -= 5)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        onPressed: _restSeconds > 15
                            ? () => setState(() => _restSeconds -= 15)
                            : null,
                        icon: const Text('-15', style: TextStyle(fontSize: 12)),
                      ),
                      const Spacer(),
                      Text(
                        _formatSeconds(_restSeconds),
                        style:
                            Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const Spacer(),
                      IconButton.outlined(
                        onPressed: _restSeconds < 585
                            ? () => setState(() => _restSeconds += 15)
                            : null,
                        icon: const Text('+15', style: TextStyle(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      IconButton.outlined(
                        onPressed: _restSeconds < 595
                            ? () => setState(() => _restSeconds += 5)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Presets rápidos
                  Wrap(
                    spacing: 8,
                    children: [30, 45, 60, 90, 120, 180].map((s) {
                      final isSelected = _restSeconds == s;
                      return ChoiceChip(
                        label: Text(_formatSeconds(s)),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _restSeconds = s),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sección: Sonido
          _sectionHeader('SONIDO'),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sonido de cuenta atrás'),
                  subtitle: const Text('Pip pip pip piiiiip al finalizar'),
                  value: _soundEnabled,
                  onChanged: (v) => setState(() => _soundEnabled = v),
                ),
                if (_soundEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Empezar beeps en'),
                    subtitle:
                        Text('Últimos $_beepFrom segundos'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.outlined(
                          onPressed: _beepFrom > 1
                              ? () => setState(() => _beepFrom--)
                              : null,
                          icon: const Icon(Icons.remove, size: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '$_beepFrom',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        IconButton.outlined(
                          onPressed: _beepFrom < 10
                              ? () => setState(() => _beepFrom++)
                              : null,
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Probar sonido'),
                    subtitle: const Text('Escucha el beep corto y largo'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () => BeepService().playShortBeep(),
                          child: const Text('Pip'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => BeepService().playLongBeep(),
                          child: const Text('Piiiiip'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

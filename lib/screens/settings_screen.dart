import 'package:flutter/material.dart';

import '../services/beep_service.dart';
import '../services/settings_service.dart';

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

  @override
  void initState() {
    super.initState();
    _restSeconds = widget.settingsService.defaultRestSeconds;
    _soundEnabled = widget.settingsService.countdownSoundEnabled;
    _beepFrom = widget.settingsService.countdownBeepFrom;
  }

  void _saveAndPop() {
    widget.settingsService.defaultRestSeconds = _restSeconds;
    widget.settingsService.countdownSoundEnabled = _soundEnabled;
    widget.settingsService.countdownBeepFrom = _beepFrom;
    Navigator.pop(context);
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
          // Sección: Temporizador de descanso
          Text(
            'Temporizador de descanso',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
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
          Text(
            'Sonido',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
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

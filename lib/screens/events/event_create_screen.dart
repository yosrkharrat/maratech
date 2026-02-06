import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/accessibility/a11y.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/event_provider.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

class EventCreateScreen extends ConsumerStatefulWidget {
  const EventCreateScreen({super.key});

  @override
  ConsumerState<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends ConsumerState<EventCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  DateTime _date = DateTime.now().add(const Duration(days: 7));
  DateTime? _endDate;
  EventType _type = EventType.race;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _distanceCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isEnd) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isEnd ? (_endDate ?? _date) : _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isEnd ? (_endDate ?? _date) : _date),
      );
      final dt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? 8,
        time?.minute ?? 0,
      );
      setState(() {
        if (isEnd) {
          _endDate = dt;
        } else {
          _date = dt;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = ref.read(eventServiceProvider);
      final lat = double.tryParse(_latCtrl.text.trim());
      final lng = double.tryParse(_lngCtrl.text.trim());
      final event = EventModel(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        type: _type,
        status: EventStatus.upcoming,
        date: _date,
        endDate: _endDate,
        locationName: _locationCtrl.text.trim(),
        location: (lat != null && lng != null)
            ? GeoPoint(lat, lng)
            : null,
        distance: double.tryParse(_distanceCtrl.text.trim()),
        createdBy: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await service.createEvent(event);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('event_created'))),
        );
        context.go('/events');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      appBar: AppBar(title: Text(tr('new_event'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: tr('event_title'),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? tr('required') : null,
              ),
              const SizedBox(height: 16),

              // Type
              DropdownButtonFormField<EventType>(
                value: _type,
                decoration: InputDecoration(
                  labelText: tr('event_type'),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: EventType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _type = v);
                },
              ),
              const SizedBox(height: 16),

              // Date
              _DateField(
                label: tr('date'),
                date: _date,
                onTap: () => _pickDate(false),
              ),
              const SizedBox(height: 16),

              // End date (optional)
              _DateField(
                label: tr('end_date'),
                date: _endDate,
                onTap: () => _pickDate(true),
                isOptional: true,
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: tr('venue'),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? tr('required') : null,
              ),
              const SizedBox(height: 16),

              // Distance
              TextFormField(
                controller: _distanceCtrl,
                decoration: InputDecoration(
                  labelText: '${tr('distance')} (km)',
                  prefixIcon: const Icon(Icons.straighten),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                decoration: InputDecoration(
                  labelText: tr('description'),
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? tr('required') : null,
              ),
              const SizedBox(height: 16),

              // GPS (optional)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latCtrl,
                      decoration: InputDecoration(
                        labelText: tr('latitude'),
                        prefixIcon: const Icon(Icons.my_location),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngCtrl,
                      decoration: InputDecoration(
                        labelText: tr('longitude'),
                        prefixIcon: const Icon(Icons.my_location),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit
              A11y.touchTarget(
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _submit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add),
                  label: Text(tr('create_event')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final bool isOptional;

  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return A11y.touchTarget(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label + (isOptional ? ' (optionnel)' : ''),
            prefixIcon: const Icon(Icons.calendar_today),
            suffixIcon: const Icon(Icons.edit_calendar),
          ),
          child: Text(
            date != null
                ? '${date!.day}/${date!.month}/${date!.year} ${date!.hour.toString().padLeft(2, '0')}:${date!.minute.toString().padLeft(2, '0')}'
                : '—',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}

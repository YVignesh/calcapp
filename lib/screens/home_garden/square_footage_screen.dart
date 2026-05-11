import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/calc_scaffold.dart';
import '../../widgets/result_card.dart';

class SquareFootageScreen extends StatefulWidget {
  const SquareFootageScreen({super.key});

  @override
  State<SquareFootageScreen> createState() => _SquareFootageScreenState();
}

class _SquareFootageScreenState extends State<SquareFootageScreen> {
  final List<_Room> _rooms = [
    _Room(
      name: TextEditingController(text: 'Room 1'),
      length: TextEditingController(),
      width: TextEditingController(),
    ),
  ];
  String _unit = 'feet';
  String? _total;
  String? _totalMetric;

  static const _units = ['feet', 'meters', 'yards', 'inches'];

  void _calculate() {
    double total = 0;
    for (final r in _rooms) {
      final l = double.tryParse(r.length.text) ?? 0;
      final w = double.tryParse(r.width.text) ?? 0;
      total += l * w;
    }
    double totalM2;
    switch (_unit) {
      case 'feet':
        totalM2 = total * 0.092903;
      case 'meters':
        totalM2 = total;
      case 'yards':
        totalM2 = total * 0.836127;
      case 'inches':
        totalM2 = total * 0.00064516;
      default:
        totalM2 = total;
    }
    final suffix = _unit == 'meters' ? 'm²' : 'sq $_unit';
    setState(() {
      _total = '${total.toStringAsFixed(2)} $suffix';
      _totalMetric = _unit != 'meters'
          ? '${totalM2.toStringAsFixed(2)} m²'
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalcScaffold(
      title: 'Square Footage',
      description:
          'Calculate the square footage or square meters of a rectangular room or area.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('UNIT'),
          Wrap(
            spacing: 8,
            children: _units
                .map(
                  (u) => ChoiceChip(
                    label: Text(u),
                    selected: _unit == u,
                    onSelected: (_) => setState(() => _unit = u),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const SectionLabel('ROOMS / AREAS'),
          ..._rooms.asMap().entries.map(
            (e) => _RoomRow(
              room: e.value,
              index: e.key,
              unit: _unit,
              onRemove: _rooms.length > 1
                  ? () => setState(() {
                      e.value.dispose();
                      _rooms.removeAt(e.key);
                    })
                  : null,
            ),
          ),
          TextButton.icon(
            onPressed: () => setState(
              () => _rooms.add(
                _Room(
                  name: TextEditingController(
                    text: 'Room ${_rooms.length + 1}',
                  ),
                  length: TextEditingController(),
                  width: TextEditingController(),
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Add room',
              style: GoogleFonts.ibmPlexSans(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            child: Text(
              'Calculate',
              style: GoogleFonts.ibmPlexSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          if (_total != null) ...[
            const SizedBox(height: 24),
            ResultCard(
              label: 'TOTAL AREA',
              value: _total!,
              color: const Color(0xFF14B8A6),
              rows: [
                if (_totalMetric != null)
                  InfoRow('In square meters', _totalMetric!),
                InfoRow('Number of rooms', '${_rooms.length}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final r in _rooms) {
      r.dispose();
    }
    super.dispose();
  }
}

class _Room {
  final TextEditingController name;
  final TextEditingController length;
  final TextEditingController width;
  _Room({required this.name, required this.length, required this.width});
  void dispose() {
    name.dispose();
    length.dispose();
    width.dispose();
  }
}

class _RoomRow extends StatelessWidget {
  final _Room room;
  final int index;
  final String unit;
  final VoidCallback? onRemove;

  const _RoomRow({
    required this.room,
    required this.index,
    required this.unit,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: room.name,
                  decoration: const InputDecoration(hintText: 'Room name'),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: cs.error,
                  ),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: room.length,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Length',
                    suffixText: unit,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.close_rounded, size: 16),
              ),
              Expanded(
                child: TextField(
                  controller: room.width,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Width',
                    suffixText: unit,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FlightSimulatorScreen extends StatefulWidget {
  const FlightSimulatorScreen({super.key});

  @override
  State<FlightSimulatorScreen> createState() => _FlightSimulatorScreenState();
}

class _FlightSimulatorScreenState extends State<FlightSimulatorScreen> {
  int _selectedAircraft = 0;

  final List<Map<String, dynamic>> _aircrafts = [
    {
      'name': 'Cessna 172',
      'type': 'Tek Motorlu',
      'image': 'assets/aeroplanes/1.png',
    },
    {
      'name': 'Boeing 737',
      'type': 'Yolcu Uçağı',
      'image': 'assets/aeroplanes/2.png',
    },
    {
      'name': 'F-16',
      'type': 'Savaş Uçağı',
      'image': 'assets/aeroplanes/3.png',
    },
    {
      'name': 'Airbus A320',
      'type': 'Yolcu Uçağı',
      'image': 'assets/aeroplanes/4.png',
    },
    {
      'name': 'Piper PA-28',
      'type': 'Tek Motorlu',
      'image': 'assets/aeroplanes/5.png',
    },
    {
      'name': 'Embraer E190',
      'type': 'Bölgesel Jet',
      'image': 'assets/aeroplanes/6.png',
    },
    {
      'name': 'Gulfstream G650',
      'type': 'İş Jeti',
      'image': 'assets/aeroplanes/7.png',
    },
  ];

  void _showARDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AR Özelliği'),
        content: const Text('AR özelliği bu sürümde devre dışı.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A237E), // Koyu mavi
                  Color(0xFF000051), // Lacivert
                ],
              ),
            ),
          ),
          // Animasyonlu yıldızlar
          ...List.generate(50, (index) {
            return Positioned(
              left: (index * 100.0) % MediaQuery.of(context).size.width,
              top: (index * 50.0) % MediaQuery.of(context).size.height,
              child: const Icon(
                Icons.star,
                color: Colors.white,
                size: 2,
              ).animate(
                onPlay: (controller) => controller.repeat(),
              ).fade(
                duration: 2.seconds,
                begin: 0.2,
                end: 1.0,
              ).scale(
                duration: 2.seconds,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
              ),
            );
          }),
          // Ana içerik
          SafeArea(
            child: Column(
              children: [
                // Üst bilgi paneli
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Uçak Modelleri',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 40), // Dengeleme için boşluk
                    ],
                  ),
                ),
                // Grid görünümü
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _aircrafts.length,
                    itemBuilder: (context, index) {
                      final aircraft = _aircrafts[index];
                      return _buildAircraftCard(
                        aircraft: aircraft,
                        isSelected: index == _selectedAircraft,
                        onTap: () {
                          setState(() {
                            _selectedAircraft = index;
                          });
                        },
                      ).animate(
                        delay: (index * 100).milliseconds,
                      ).fadeIn(
                        duration: 600.milliseconds,
                      ).slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 600.milliseconds,
                        curve: Curves.easeOutQuad,
                      );
                    },
                  ),
                ),
                // AR Başlat butonu (işlevsiz)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _showARDisabledDialog,
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text('AR Modunu Başlat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftCard({
    required Map<String, dynamic> aircraft,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isSelected ? Colors.blue.withOpacity(0.3) : Colors.white.withOpacity(0.1),
            isSelected ? Colors.blue.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Uçak Resmi
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Arka plan gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Uçak resmi
                      Image.asset(
                        aircraft['image'],
                        fit: BoxFit.contain,
                      ),
                      // Seçili durumda parıltı efekti
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Bilgi Paneli
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            aircraft['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.blue : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aircraft['type'],
                      style: TextStyle(
                        color: isSelected ? Colors.blue.withOpacity(0.8) : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

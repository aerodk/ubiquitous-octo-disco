import 'package:flutter/material.dart';

/// Screen to display and select from three logo options
/// Shows comic-style padel logos with vibrant colors
class LogoSelectionScreen extends StatelessWidget {
  const LogoSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Padel Tournament Logos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade400,
              Colors.deepPurple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '🎾 Choose Your Logo 🎾',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black45,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Three comic-style logos with vibrant colors',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFD700), // Gold
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Logo Option 1
                _buildLogoCard(
                  context,
                  logoPath: 'assets/logos/logo_option_1.svg',
                  title: 'Option 1: Playful Racket',
                  style: 'Dynamic and Energetic',
                  description: 'Features a bold comic-style padel racket with vibrant orange gradients, '
                      'a teal ball with motion lines, and energetic "PADEL!" text.',
                  colors: [
                    const Color(0xFFFF6B35), // Orange
                    const Color(0xFFFF9F1C), // Light Orange
                    const Color(0xFF2EC4B6), // Teal
                    const Color(0xFFFFD23F), // Yellow
                  ],
                  bestFor: 'Main app icon, splash screen, energetic branding',
                ),
                
                const SizedBox(height: 20),
                
                // Logo Option 2
                _buildLogoCard(
                  context,
                  logoPath: 'assets/logos/logo_option_2.svg',
                  title: 'Option 2: Champion Trophy',
                  style: 'Celebratory and Prestigious',
                  description: 'A golden trophy with crossed padel rackets, complete with confetti, '
                      'stars, and "CHAMPION" text celebrating achievement and victory.',
                  colors: [
                    const Color(0xFFFFD700), // Gold
                    const Color(0xFF2EC4B6), // Teal
                    const Color(0xFFE63946), // Red
                    const Color(0xFFFF6B35), // Orange
                  ],
                  bestFor: 'Achievement badges, tournament completion, winners',
                ),
                
                const SizedBox(height: 20),
                
                // Logo Option 3
                _buildLogoCard(
                  context,
                  logoPath: 'assets/logos/logo_option_3.svg',
                  title: 'Option 3: Action Scene',
                  style: 'Active and Social',
                  description: 'Dynamic players in action on a teal court with comic-style "POW!" and '
                      '"SMASH!" effects capturing the social, competitive nature of padel.',
                  colors: [
                    const Color(0xFF4ECDC4), // Teal Court
                    const Color(0xFFFF6B6B), // Red Player
                    const Color(0xFFFFD700), // Yellow Ball
                    const Color(0xFFFF6B35), // Orange
                  ],
                  bestFor: 'Social sharing, tournament promotion, marketing',
                ),
                
                const SizedBox(height: 30),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'All logos created as SVG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Perfect scaling at any size • Small file size • Crisp on all devices',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCard(
    BuildContext context, {
    required String logoPath,
    required String title,
    required String style,
    required String description,
    required List<Color> colors,
    required String bestFor,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo display area
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade100,
                    Colors.grey.shade300,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Image.asset(
                  logoPath,
                  height: 220,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback if SVG package not available
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_tennis, size: 100, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          logoPath.split('/').last,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            
            const SizedBox(height: 5),
            
            // Style
            Text(
              style,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Color swatches
            Row(
              children: colors
                  .map((color) => Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            
            const SizedBox(height: 15),
            
            // Best for
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: Color(0xFF4CAF50), width: 4),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Best for: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bestFor,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

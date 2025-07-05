import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CrisisResourcesCard extends StatelessWidget {
  const CrisisResourcesCard({super.key});

  Future<void> _launchPhone(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchWebsite(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE17055),
            Color(0xFFD63031),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE17055).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emergency,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crisis Resources',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Emergency support when you need it most',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Emergency Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'If you\'re having thoughts of self-harm, please reach out immediately.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Crisis Hotlines
          const Text(
            'Emergency Hotlines',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildCrisisResource(
            icon: Icons.phone,
            title: 'National Suicide Prevention Lifeline',
            subtitle: '24/7 Free & Confidential',
            actionText: '988',
            onTap: () {
              HapticFeedback.lightImpact();
              _launchPhone('988');
            },
          ),
          const SizedBox(height: 8),
          _buildCrisisResource(
            icon: Icons.chat,
            title: 'Crisis Text Line',
            subtitle: 'Text with a crisis counselor',
            actionText: 'Text HOME to 741741',
            onTap: () {
              HapticFeedback.lightImpact();
              _launchPhone('741741');
            },
          ),
          const SizedBox(height: 8),
          _buildCrisisResource(
            icon: Icons.local_hospital,
            title: 'Emergency Services',
            subtitle: 'Immediate medical emergency',
            actionText: '911',
            onTap: () {
              HapticFeedback.heavyImpact();
              _launchPhone('911');
            },
          ),
          
          const SizedBox(height: 16),
          
          // Online Resources
          Row(
            children: [
              Expanded(
                child: _buildOnlineResource(
                  icon: Icons.web,
                  title: 'SAMHSA',
                  subtitle: 'Treatment finder',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _launchWebsite('https://www.samhsa.gov/find-treatment');
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOnlineResource(
                  icon: Icons.support,
                  title: 'NAMI',
                  subtitle: 'Support groups',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _launchWebsite('https://www.nami.org/support');
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'This app is not a substitute for professional mental health care. If you\'re experiencing a mental health crisis, please contact emergency services or a mental health professional.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisResource({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                actionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineResource({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

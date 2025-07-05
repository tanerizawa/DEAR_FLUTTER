import 'package:flutter/material.dart';
import 'dart:math';

import '../models/tree_state.dart';

class TreePainter extends CustomPainter {
  final TreeStage stage;
  final double health;
  final double animationValue;

  TreePainter({
    required this.stage,
    required this.health,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.85; // Tree base at 85% height
    
    // Draw ground
    _drawGround(canvas, size);
    
    // Draw tree based on stage and health
    switch (stage) {
      case TreeStage.seed:
        _drawSeed(canvas, centerX, centerY);
        break;
      case TreeStage.sprout:
        _drawSprout(canvas, centerX, centerY);
        break;
      case TreeStage.young:
        _drawYoungTree(canvas, centerX, centerY, size);
        break;
      case TreeStage.mature:
        _drawMatureTree(canvas, centerX, centerY, size);
        break;
      case TreeStage.wise:
        _drawWiseTree(canvas, centerX, centerY, size);
        break;
    }
    
    // Add particles for healthy trees
    if (health > 0.7) {
      _drawParticles(canvas, size);
    }
  }

  void _drawGround(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.lerp(
        const Color(0xFF3D2914), // Brown
        const Color(0xFF5D8233), // Green-brown
        health,
      )!
      ..style = PaintingStyle.fill;

    final groundRect = Rect.fromLTWH(
      0,
      size.height * 0.85,
      size.width,
      size.height * 0.15,
    );
    
    canvas.drawRect(groundRect, paint);
  }

  void _drawSeed(Canvas canvas, double centerX, double centerY) {
    final paint = Paint()
      ..color = _getHealthColor()
      ..style = PaintingStyle.fill;

    // Small sprout with 1-2 leaves
    final stemPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Stem
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX, centerY - 20),
      stemPaint,
    );

    // Leaves
    final leafPath = Path()
      ..moveTo(centerX, centerY - 20)
      ..quadraticBezierTo(centerX - 8, centerY - 25, centerX - 6, centerY - 18)
      ..quadraticBezierTo(centerX + 8, centerY - 25, centerX + 6, centerY - 18);

    canvas.drawPath(leafPath, paint);
  }

  void _drawSprout(Canvas canvas, double centerX, double centerY) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = _getHealthColor()
      ..style = PaintingStyle.fill;

    // Trunk
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX, centerY - 40),
      trunkPaint,
    );

    // Simple branches
    canvas.drawLine(
      Offset(centerX, centerY - 30),
      Offset(centerX - 15, centerY - 35),
      trunkPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - 30),
      Offset(centerX + 15, centerY - 35),
      trunkPaint,
    );

    // Leaves
    _drawLeaf(canvas, centerX - 15, centerY - 35, leafPaint);
    _drawLeaf(canvas, centerX + 15, centerY - 35, leafPaint);
  }

  void _drawYoungTree(Canvas canvas, double centerX, double centerY, Size size) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = _getHealthColor()
      ..style = PaintingStyle.fill;

    // Trunk
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX, centerY - 80),
      trunkPaint,
    );

    // Multiple branches
    _drawBranch(canvas, centerX, centerY - 60, -30, 25, trunkPaint);
    _drawBranch(canvas, centerX, centerY - 60, 30, 25, trunkPaint);
    _drawBranch(canvas, centerX, centerY - 70, -20, 20, trunkPaint);
    _drawBranch(canvas, centerX, centerY - 70, 20, 20, trunkPaint);

    // Foliage
    _drawFoliage(canvas, centerX, centerY - 80, 40, leafPaint);
  }

  void _drawMatureTree(Canvas canvas, double centerX, double centerY, Size size) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF4A2C17)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = _getHealthColor()
      ..style = PaintingStyle.fill;

    // Trunk
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX, centerY - 120),
      trunkPaint,
    );

    // Many branches
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) - 180;
      final branchLength = 35 - (i % 2) * 10;
      final startY = centerY - 80 - (i * 8);
      
      _drawBranch(canvas, centerX, startY, angle.toDouble(), branchLength.toDouble(), trunkPaint);
    }

    // Dense foliage
    _drawFoliage(canvas, centerX, centerY - 120, 60, leafPaint);
    
    // Add sway animation
    final swayOffset = sin(animationValue * 2 * pi) * 3;
    canvas.translate(swayOffset, 0);
  }

  void _drawWiseTree(Canvas canvas, double centerX, double centerY, Size size) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = _getWiseTreeColor()
      ..style = PaintingStyle.fill;

    final flowerPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    // Trunk
    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(centerX, centerY - 150),
      trunkPaint,
    );

    // Extensive branch system
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) - 180;
      final branchLength = 45 - (i % 3) * 10;
      final startY = centerY - 90 - (i * 6);
      
      _drawBranch(canvas, centerX, startY, angle.toDouble(), branchLength.toDouble(), trunkPaint);
    }

    // Magnificent foliage
    _drawFoliage(canvas, centerX, centerY - 150, 80, leafPaint);
    
    // Flowers
    for (int i = 0; i < 6; i++) {
      final flowerX = centerX + (sin(i * pi / 3) * 40);
      final flowerY = centerY - 130 + (cos(i * pi / 3) * 20);
      _drawFlower(canvas, flowerX, flowerY, flowerPaint);
    }

    // Gentle sway with sparkle effect
    final swayOffset = sin(animationValue * 2 * pi) * 2;
    canvas.translate(swayOffset, 0);
  }

  void _drawBranch(Canvas canvas, double startX, double startY, double angle, double length, Paint paint) {
    final radians = angle * pi / 180;
    final endX = startX + cos(radians) * length;
    final endY = startY + sin(radians) * length;
    
    canvas.drawLine(
      Offset(startX, startY),
      Offset(endX, endY),
      paint,
    );
  }

  void _drawLeaf(Canvas canvas, double x, double y, Paint paint) {
    final leafPath = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(x - 5, y - 8, x, y - 10)
      ..quadraticBezierTo(x + 5, y - 8, x, y);
    
    canvas.drawPath(leafPath, paint);
  }

  void _drawFoliage(Canvas canvas, double centerX, double centerY, double radius, Paint paint) {
    final foliageRadius = radius * health; // Shrink with poor health
    
    // Main foliage circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      foliageRadius,
      paint,
    );
    
    // Additional foliage clusters for fullness
    canvas.drawCircle(
      Offset(centerX - foliageRadius * 0.5, centerY + foliageRadius * 0.3),
      foliageRadius * 0.7,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + foliageRadius * 0.5, centerY + foliageRadius * 0.3),
      foliageRadius * 0.7,
      paint,
    );
  }

  void _drawFlower(Canvas canvas, double x, double y, Paint paint) {
    // Simple flower with petals
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * pi / 5;
      final petalX = x + cos(angle) * 3;
      final petalY = y + sin(angle) * 3;
      
      canvas.drawCircle(Offset(petalX, petalY), 2, paint);
    }
    
    // Center
    canvas.drawCircle(Offset(x, y), 1.5, paint);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Floating particles for healthy trees
    for (int i = 0; i < 8; i++) {
      final x = size.width * 0.2 + (i * size.width * 0.1);
      final y = size.height * 0.3 + sin(animationValue * 2 * pi + i) * 20;
      
      canvas.drawCircle(Offset(x, y), 1.5, particlePaint);
    }
  }

  Color _getHealthColor() {
    if (health >= 0.9) return const Color(0xFF2E7D32); // Deep green
    if (health >= 0.7) return const Color(0xFF4CAF50); // Medium green
    if (health >= 0.4) return const Color(0xFF8BC34A); // Light green
    if (health >= 0.2) return const Color(0xFFFFC107); // Yellow
    return const Color(0xFF795548); // Brown (dormant)
  }

  Color _getWiseTreeColor() {
    // Wise trees have golden-green foliage
    return Color.lerp(
      const Color(0xFF2E7D32),
      const Color(0xFFFFD700),
      health * 0.3,
    )!;
  }

  @override
  bool shouldRepaint(TreePainter oldDelegate) {
    return oldDelegate.stage != stage ||
           oldDelegate.health != health ||
           oldDelegate.animationValue != animationValue;
  }
}

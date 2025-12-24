import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

class ParticleFactory {
  static final Random _rnd = Random();

  static ParticleSystemComponent createMatchBurst({
    required Vector2 position,
    required Color color,
    int count = 10,
  }) {
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: count,
        lifespan: 0.6,
        generator: (i) => AcceleratedParticle(
          speed: Vector2(
            _rnd.nextDouble() * 200 - 100,
            _rnd.nextDouble() * 200 - 100,
          ),
          acceleration: Vector2(0, 200), // Gravity
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()
                ..color = color.withOpacity(1 - particle.progress);
              canvas.drawCircle(
                Offset.zero,
                3 * (1 - particle.progress),
                paint,
              );
            },
          ),
        ),
      ),
    );
  }

  static ParticleSystemComponent createSkillExplosion({
    required Vector2 position,
    required Color color,
    int count = 20,
  }) {
    return ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: count,
        lifespan: 0.8,
        generator: (i) {
          final angle = _rnd.nextDouble() * 2 * pi;
          final speed = _rnd.nextDouble() * 150 + 50;
          return AcceleratedParticle(
            speed: Vector2(cos(angle), sin(angle)) * speed,
            child: RotatingParticle(
              to: _rnd.nextDouble() * pi * 2,
              child: CustomParticle(
                lifespan: 0.8,
                renderer: (canvas, particle) {
                  final paint = Paint()
                    ..color = color.withOpacity(1 - particle.progress);
                  canvas.drawRect(
                    Rect.fromCenter(center: Offset.zero, width: 6, height: 6),
                    paint,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomParticle extends Particle {
  final void Function(Canvas, Particle) renderer;

  CustomParticle({required this.renderer, super.lifespan});

  @override
  void render(Canvas canvas) {
    renderer(canvas, this);
  }
}

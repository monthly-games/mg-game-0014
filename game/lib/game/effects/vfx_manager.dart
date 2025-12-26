import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

/// VFX Manager for Witch's Lab: Experimental Puzzle (MG-0014)
/// Puzzle + Roguelike + Skill Build 게임 전용 이펙트 관리자
class VfxManager extends Component with HasGameRef {
  VfxManager();
  final Random _random = Random();

  // Puzzle Effects
  void showPuzzleMatch(Vector2 position, Color matchColor, {int chainCount = 1}) {
    final intensity = chainCount.clamp(1, 5);
    gameRef.add(_createBurstEffect(position: position, color: matchColor, count: 12 * intensity, speed: 70.0 * intensity, lifespan: 0.5));
    if (chainCount >= 3) gameRef.add(_createSparkleEffect(position: position, color: Colors.white, count: 10));
  }

  void showChainReaction(Vector2 position, int chainLevel) {
    gameRef.add(_ChainText(position: position, chain: chainLevel));
    for (int i = 0; i < chainLevel.clamp(1, 5); i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (!isMounted) return;
        gameRef.add(_createSparkleEffect(position: position + Vector2((_random.nextDouble() - 0.5) * 60, (_random.nextDouble() - 0.5) * 40), color: Colors.amber, count: 8));
      });
    }
  }

  // Skill/Synergy Effects
  void showSkillSelect(Vector2 position, Color skillColor) {
    gameRef.add(_createConvergeEffect(position: position, color: skillColor));
    gameRef.add(_createGroundCircle(position: position, color: skillColor));
  }

  void showSynergyActivation(Vector2 position, Color synergyColor) {
    gameRef.add(_createExplosionEffect(position: position, color: synergyColor, count: 30, radius: 65));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.white, count: 15));
    gameRef.add(_SynergyText(position: position));
  }

  void showExperimentSuccess(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.green, count: 25, radius: 60));
    gameRef.add(_createSparkleEffect(position: position, color: Colors.lightGreen, count: 12));
    showNumberPopup(position, 'SUCCESS!', color: Colors.green);
  }

  void showExperimentFailure(Vector2 position) {
    gameRef.add(_createSmokeEffect(position: position, count: 15, color: Colors.grey.shade700));
    gameRef.add(_createBurstEffect(position: position, color: Colors.red.shade300, count: 10, speed: 50, lifespan: 0.4));
  }

  // Meta/Upgrade Effects
  void showMetaUpgrade(Vector2 position) {
    gameRef.add(_createExplosionEffect(position: position, color: Colors.purple, count: 35, radius: 70));
    gameRef.add(_createRisingEffect(position: position, color: Colors.purple.shade200, count: 15, speed: 80));
    gameRef.add(_UpgradeText(position: position));
  }

  void showRunStart(Vector2 centerPosition) {
    gameRef.add(_createSparkleEffect(position: centerPosition, color: Colors.cyan, count: 25));
    gameRef.add(_RunStartText(position: centerPosition));
  }

  void showNumberPopup(Vector2 position, String text, {Color color = Colors.white}) {
    gameRef.add(_NumberPopup(position: position, text: text, color: color));
  }

  // Private generators
  ParticleSystemComponent _createBurstEffect({required Vector2 position, required Color color, required int count, required double speed, required double lifespan}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: lifespan, generator: (i) {
      final angle = (i / count) * 2 * pi;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * (speed * (0.5 + _random.nextDouble() * 0.5)), acceleration: Vector2(0, 150), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 4 * (1.0 - particle.progress * 0.5), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createExplosionEffect({required Vector2 position, required Color color, required int count, required double radius}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.7, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = radius * (0.4 + _random.nextDouble() * 0.6);
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 100), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 5 * (1.0 - particle.progress * 0.3), Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createConvergeEffect({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 12, lifespan: 0.5, generator: (i) {
      final startAngle = (i / 12) * 2 * pi; final startPos = Vector2(cos(startAngle), sin(startAngle)) * 45;
      return MovingParticle(from: position + startPos, to: position.clone(), child: ComputedParticle(renderer: (canvas, particle) {
        canvas.drawCircle(Offset.zero, 4, Paint()..color = color.withOpacity((1.0 - particle.progress * 0.5).clamp(0.0, 1.0)));
      }));
    }));
  }

  ParticleSystemComponent _createSparkleEffect({required Vector2 position, required Color color, required int count}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.5, generator: (i) {
      final angle = _random.nextDouble() * 2 * pi; final speed = 50 + _random.nextDouble() * 40;
      return AcceleratedParticle(position: position.clone(), speed: Vector2(cos(angle), sin(angle)) * speed, acceleration: Vector2(0, 40), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0); final size = 3 * (1.0 - particle.progress * 0.5);
        final path = Path(); for (int j = 0; j < 4; j++) { final a = (j * pi / 2); if (j == 0) {
          path.moveTo(cos(a) * size, sin(a) * size);
        } else {
          path.lineTo(cos(a) * size, sin(a) * size);
        } } path.close();
        canvas.drawPath(path, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createRisingEffect({required Vector2 position, required Color color, required int count, required double speed}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.9, generator: (i) {
      final spreadX = (_random.nextDouble() - 0.5) * 35;
      return AcceleratedParticle(position: position.clone() + Vector2(spreadX, 0), speed: Vector2(0, -speed), acceleration: Vector2(0, -20), child: ComputedParticle(renderer: (canvas, particle) {
        final opacity = (1.0 - particle.progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 3, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createSmokeEffect({required Vector2 position, required int count, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: count, lifespan: 0.8, generator: (i) {
      return AcceleratedParticle(position: position.clone() + Vector2((_random.nextDouble() - 0.5) * 25, 0), speed: Vector2((_random.nextDouble() - 0.5) * 15, -30 - _random.nextDouble() * 20), acceleration: Vector2(0, -10), child: ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (0.5 - progress * 0.5).clamp(0.0, 1.0);
        canvas.drawCircle(Offset.zero, 6 + progress * 10, Paint()..color = color.withOpacity(opacity));
      }));
    }));
  }

  ParticleSystemComponent _createGroundCircle({required Vector2 position, required Color color}) {
    return ParticleSystemComponent(particle: Particle.generate(count: 1, lifespan: 0.6, generator: (i) {
      return ComputedParticle(renderer: (canvas, particle) {
        final progress = particle.progress; final opacity = (1.0 - progress).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(position.x, position.y), 15 + progress * 30, Paint()..color = color.withOpacity(opacity * 0.4)..style = PaintingStyle.stroke..strokeWidth = 2);
      });
    }));
  }
}

class _ChainText extends TextComponent {
  _ChainText({required Vector2 position, required int chain}) : super(text: 'x$chain CHAIN!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 18 + chain * 2.0, fontWeight: FontWeight.bold, color: chain >= 5 ? Colors.red : (chain >= 3 ? Colors.orange : Colors.yellow), shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.2, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -30), EffectController(duration: 0.8, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.8, startDelay: 0.3))); add(RemoveEffect(delay: 1.1)); }
}

class _SynergyText extends TextComponent {
  _SynergyText({required Vector2 position}) : super(text: 'SYNERGY!', position: position + Vector2(0, -40), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.cyan, shadows: [Shadow(color: Colors.blue, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.25, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.4))); add(RemoveEffect(delay: 1.4)); }
}

class _UpgradeText extends TextComponent {
  _UpgradeText({required Vector2 position}) : super(text: 'UPGRADE!', position: position + Vector2(0, -40), anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple, shadows: [Shadow(color: Colors.purple, blurRadius: 10)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.5); add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.elasticOut))); add(MoveByEffect(Vector2(0, -20), EffectController(duration: 1.0, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.0, startDelay: 0.5))); add(RemoveEffect(delay: 1.5)); }
}

class _RunStartText extends TextComponent {
  _RunStartText({required Vector2 position}) : super(text: 'RUN START!', position: position, anchor: Anchor.center, textRenderer: TextPaint(style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2, shadows: [Shadow(color: Colors.cyan, blurRadius: 12)])));
  @override Future<void> onLoad() async { await super.onLoad(); scale = Vector2.all(0.3); add(ScaleEffect.to(Vector2.all(1.1), EffectController(duration: 0.4, curve: Curves.elasticOut))); add(OpacityEffect.fadeOut(EffectController(duration: 1.5, startDelay: 0.8))); add(RemoveEffect(delay: 2.3)); }
}

class _NumberPopup extends TextComponent {
  _NumberPopup({required Vector2 position, required String text, required Color color}) : super(text: text, position: position, anchor: Anchor.center, textRenderer: TextPaint(style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color, shadows: const [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))])));
  @override Future<void> onLoad() async { await super.onLoad(); add(MoveByEffect(Vector2(0, -25), EffectController(duration: 0.6, curve: Curves.easeOut))); add(OpacityEffect.fadeOut(EffectController(duration: 0.6, startDelay: 0.2))); add(RemoveEffect(delay: 0.8)); }
}

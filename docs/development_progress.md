# MG-0014 개발 진척도

**게임명**: 마녀의 연구소: 실험형 퍼즐
**장르**: 퍼즐 + 스킬 빌드 + 로그라이크
**시작일**: 2025-12-17
**현재 진척도**: 15%

---

## 🎯 핵심 게임플레이

### 게임 루프
1. **퍼즐 해결**: Match-3 퍼즐로 원소 마나 획득
2. **스킬 획득**: 마나로 스킬 구매 및 강화
3. **시너지 구축**: 스킬 조합으로 강력한 효과 생성
4. **적 처치**: 스킬로 적을 처치하고 다음 스테이지 진행
5. **보상 획득**: 승리 시 새로운 스킬/아이템 선택

### 핵심 차별점
- **퍼즐 매칭과 전투의 실시간 연계**: 퍼즐을 풀면서 바로 적에게 데미지
- **스킬 빌드 자유도**: 18개 스킬 중 자유롭게 조합
- **시너지 시스템**: 특정 스킬 조합 시 보너스 효과
- **로그라이크 진행**: 한 판이 15-20분, 죽으면 처음부터

---

## ✅ 완료된 기능

### 1. 기본 퍼즐 시스템 (100%)
- ✅ 8x6 그리드 생성
- ✅ 4가지 타일 타입 (Fire, Water, Earth, Poison)
- ✅ 타일 스왑 기능
- ✅ Match-3 감지 (가로/세로)
- ✅ 타일 제거 및 리필
- ✅ 연쇄 매치 처리

**파일**:
- [grid_manager.dart](../game/lib/features/puzzle/grid_manager.dart)
- [tile_component.dart](../game/lib/features/puzzle/tile_component.dart)

### 2. 기본 전투 시스템 (60%)
- ✅ 적 생성 및 렌더링
- ✅ 적 HP 바 표시
- ✅ 적 공격 타이머 (5초마다 공격)
- ✅ 플레이어 HP 시스템
- ✅ 퍼즐 매치 → 적 데미지 연계
- ⬜ 다양한 적 타입
- ⬜ 적 AI 패턴
- ⬜ 보스전

**파일**:
- [enemy_component.dart](../game/lib/game/components/enemy_component.dart)
- [player_data.dart](../game/lib/features/player/player_data.dart)

### 3. 기본 이펙트 (70%)
- ✅ 파티클 시스템 (SimpleParticle)
- ✅ 매치 시 파티클 생성
- ✅ 타일 타입별 색상 구분
- ⬜ 스킬 이펙트 애니메이션
- ⬜ 화면 흔들림 (Screen shake)
- ⬜ 타격 이펙트

**파일**:
- [simple_particle.dart](../game/lib/game/components/simple_particle.dart)

### 4. 게임 구조 (80%)
- ✅ Flame 엔진 통합
- ✅ Provider 상태 관리
- ✅ GetIt DI 설정
- ✅ AudioManager 통합 (mg_common_game)
- ✅ AppColors 테마 통합
- ⬜ 화면 전환 시스템
- ⬜ 저장/불러오기

**파일**:
- [main.dart](../game/lib/main.dart)
- [lab_game.dart](../game/lib/game/lab_game.dart)

---

## 🚧 진행 중 작업

### 1. 스킬 시스템 (0%)
현재 퍼즐 매치가 바로 적에게 데미지를 주지만, GDD에 따르면:
- 매치 → **마나 획득**
- 마나 소모 → **스킬 발동**
- 스킬 → 적 데미지/힐/버프 등

**구현 필요 항목**:
```dart
// 1. SkillData 모델
class SkillData {
  String id;
  String name;
  String description;
  TileType element;      // 필요한 원소
  double manaCost;       // 마나 소비량
  SkillType type;        // damage, heal, buff, debuff
  double baseValue;      // 기본 효과량
  double cooldown;       // 재사용 대기시간
  List<String> tags;     // 시너지 태그 ["fire", "aoe", "burn"]
}

enum SkillType { damage, heal, buff, debuff, special }

// 2. SkillManager (Provider)
class SkillManager extends ChangeNotifier {
  List<SkillData> acquiredSkills = [];  // 보유 스킬
  List<SkillData> activeSkills = [];    // 장착 스킬 (최대 6개?)
  Map<String, double> cooldowns = {};   // 쿨다운 추적

  bool canUseSkill(SkillData skill);
  void useSkill(SkillData skill, PlayerData player, EnemyComponent enemy);
  void updateCooldowns(double dt);
}

// 3. 18개 기본 스킬 정의
// 화염: 불덩이, 화염 폭풍, 용암 장판
// 물: 냉기 화살, 빙결, 물 방패
// 독: 독안개, 맹독 주사, 부식
// 대지: 돌 투척, 지진, 재생
// 복합: 증기 폭발, 전기 충격, 빙독 화살
```

### 2. 시너지 시스템 (0%)
GDD의 핵심 메커니즘. 특정 스킬 조합 시 강력한 보너스.

**예시 시너지**:
1. **화염 마스터**: 화염 스킬 3개 이상 → 모든 화염 데미지 +30%
2. **빙결 술사**: 물 스킬 + 독 스킬 → 적 감속 효과
3. **연쇄 반응**: AOE 스킬 2개 → 적 하나 처치 시 주변 적 데미지

**구현 필요 항목**:
```dart
class SynergyData {
  String id;
  String name;
  String description;
  List<String> requiredTags;  // ["fire", "fire", "fire"]
  SynergyEffect effect;
}

enum SynergyEffect {
  damageBoost,      // 데미지 증가
  manaCostReduction, // 마나 소비 감소
  cooldownReduction, // 쿨다운 감소
  specialEffect,     // 특수 효과 (빙결, 화상 등)
}

class SynergyManager extends ChangeNotifier {
  List<SynergyData> activeSynergies = [];

  void checkSynergies(List<SkillData> skills) {
    // 보유 스킬로 시너지 체크
  }
}
```

---

## 📋 우선순위별 작업 목록

### 우선순위 1: 핵심 게임 루프 완성 (현재 진행)
1. ⬜ **get_it 버전 업그레이드** (7.6.6 → 9.2.0) - mg_common_game 호환성
2. ⬜ **스킬 시스템 구현**
   - SkillData 모델 생성
   - 18개 기본 스킬 정의
   - SkillManager 구현
   - 스킬 사용 UI (버튼 또는 드래그)
   - 마나 시스템 연계 (퍼즐 매치 → 마나 획득 → 스킬 사용)
3. ⬜ **시너지 시스템 구현**
   - SynergyData 모델
   - 10개 기본 시너지 정의
   - 시너지 감지 로직
   - 시너지 효과 적용
   - UI에 활성 시너지 표시
4. ⬜ **로그라이크 진행 시스템**
   - 스테이지 매니저
   - 적 처치 후 다음 스테이지
   - 승리 시 보상 화면 (스킬 선택)
   - 게임 오버 화면
   - 재시작 기능

### 우선순위 2: 컨텐츠 확장
1. ⬜ **다양한 적 타입** (5종 이상)
   - 일반 몬스터
   - 엘리트 몬스터
   - 보스
   - 각 적별 특수 패턴
2. ⬜ **스킬 밸런스 및 추가**
   - 18개 → 30개 스킬 확장
   - 레어 스킬 추가
3. ⬜ **아이템/유물 시스템**
   - 영구 효과 아이템
   - 스테이지마다 아이템 선택
4. ⬜ **UI/UX 개선**
   - 스킬 북 화면
   - 시너지 도감
   - 튜토리얼

### 우선순위 3: 메타 게임 및 진행
1. ⬜ **언락 시스템**
   - 플레이로 새 스킬 언락
   - 성취 시스템
2. ⬜ **저장/불러오기**
   - 언락 진행도 저장
   - 통계 기록
3. ⬜ **일일 도전**
   - 특정 시너지 강제
   - 특수 보상

### 우선순위 4: 라이브 서비스
1. ⬜ Firebase 백엔드 연동
2. ⬜ 리더보드 (최고 스테이지)
3. ⬜ 시즌 시스템

---

## 🎨 리소스 필요 항목

### 그래픽
- [ ] 적 스프라이트 (5종)
- [ ] 스킬 아이콘 (18개 → 30개)
- [ ] 스킬 이펙트 애니메이션 (18개)
- [ ] 시너지 엠블럼 (10개)
- [ ] 배경 이미지 (연구소 테마)
- [ ] UI 요소 (버튼, 패널)

### 사운드
- [ ] 퍼즐 매치 효과음 (4종 원소별)
- [ ] 스킬 사용 효과음 (18개)
- [ ] 적 피격/사망 효과음
- [ ] 배경 음악 (전투/보상 화면)

---

## 📊 진척도 요약

| 시스템 | 진척도 | 상태 |
|--------|--------|------|
| 퍼즐 시스템 | 100% | ✅ 완료 |
| 전투 시스템 (기본) | 60% | 🚧 진행 중 |
| 이펙트 시스템 | 70% | 🚧 진행 중 |
| 스킬 시스템 | 0% | ⬜ 미착수 |
| 시너지 시스템 | 0% | ⬜ 미착수 |
| 로그라이크 진행 | 0% | ⬜ 미착수 |
| UI/UX | 20% | ⬜ 미착수 |
| 메타 게임 | 0% | ⬜ 미착수 |

**전체 진척도**: 15%

---

## 🐛 알려진 이슈

1. **get_it 버전 충돌**: pubspec.yaml에 7.6.6이지만 mg_common_game은 9.2.0 요구
2. **퍼즐 매치가 바로 데미지**: 스킬 시스템 없이 임시로 직접 데미지 처리 중
3. **적 다양성 부족**: 현재 1종류의 적만 존재
4. **게임 오버 처리 미흡**: HP 0이 되어도 게임이 계속됨

---

## 📝 다음 작업

1. **get_it 버전 업그레이드** (의존성 해결)
2. **스킬 시스템 설계 및 구현**
   - SkillData 모델
   - 18개 기본 스킬 정의
   - SkillManager 구현
   - 마나 → 스킬 사용 플로우 구현
3. **스킬 UI 추가**
   - 보유 스킬 표시
   - 스킬 사용 버튼
   - 쿨다운 표시

---

**작성일**: 2025-12-17
**버전**: 1.0

# MG-0014 개발 진척도

**게임명**: 마녀의 연구소: 실험형 퍼즐
**장르**: 퍼즐 + 스킬 빌드 + 로그라이크
**시작일**: 2025-12-17
**현재 진척도**: 75%

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

### 2. 기본 전투 시스템 (100%)
- ✅ 적 생성 및 렌더링
- ✅ 적 HP 바 표시
- ✅ 적 공격 타이머 (스테이지별 조정 가능)
- ✅ 플레이어 HP 시스템
- ✅ 퍼즐 매치 → 마나 획득 연계
- ✅ 스킬 → 적 데미지 연계
- ✅ 적 스탯 스케일링 (스테이지별)
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

없음

---

## ✅ 최근 완료 작업

### 1. 스킬 시스템 (100%)
✅ **완료 날짜**: 2025-12-17

**구현 완료 항목**:
- ✅ SkillData 모델 (id, name, description, element, manaCost, type, baseValue, cooldown, tags)
- ✅ SkillManager (Provider) - 획득/장착/쿨다운 관리
- ✅ 18개 기본 스킬 정의
  - 화염: Fireball, Flame Storm, Lava Zone, Meteor Strike
  - 물: Ice Arrow, Freeze, Water Shield, Tidal Wave, Frost Nova
  - 독: Poison Cloud, Toxic Injection, Corrosion, Venom Strike
  - 대지: Rock Throw, Earthquake, Regeneration, Stone Armor, Nature's Wrath
- ✅ 마나 시스템 (퍼즐 매치 → 마나 획득 → 스킬 사용)
- ✅ 스킬 UI (하단 버튼, 쿨다운 표시)
- ✅ 시너지 시스템과 연동

**파일**:
- [skill_data.dart](../game/lib/features/skill/skill_data.dart)
- [skill_manager.dart](../game/lib/features/skill/skill_manager.dart)

### 2. 시너지 시스템 (100%)
✅ **완료 날짜**: 2025-12-17

**구현 완료 항목**:
- ✅ SynergyData 모델 (태그 기반 감지)
- ✅ SynergyManager (Provider) - 자동 감지 및 보너스 적용
- ✅ 10개 시너지 정의
  - **원소 마스터**: Fire/Water/Earth/Poison Master (각 원소 3개 → 데미지/마나/쿨다운 보너스)
  - **플레이 스타일**: Spell Barrage (데미지 스킬 4개 → +20% 데미지), Glass Cannon (데미지 스킬 5개 → +10% 크리티컬)
  - **방어형**: Survivor (힐/버프 2개 → 15% 흡혈), Tank (버프 3개 → 처치 시 실드)
  - **특수**: AoE Master (AoE 3개 → 범위 확장), DoT Specialist (지속딜 2개 → +50% DOT)
- ✅ 8가지 효과 타입 (damageBoost, manaCostReduction, cooldownReduction, criticalChance, lifeSteal, areaExpansion, dotAmplify, shieldOnKill)
- ✅ 시너지 UI 배지 (상단 표시)
- ✅ SkillManager와 완전 통합

**파일**:
- [synergy_data.dart](../game/lib/features/synergy/synergy_data.dart)
- [synergy_manager.dart](../game/lib/features/synergy/synergy_manager.dart)

### 3. 로그라이크 진행 시스템 (100%)
✅ **완료 날짜**: 2025-12-17

**구현 완료 항목**:
- ✅ StageManager (Provider) - 게임 상태 및 스테이지 관리
- ✅ 게임 상태: playing, victory, defeat, rewarding
- ✅ 적 스탯 스케일링 (HP: 50 + stage * 15, Damage: 10 + stage * 2, AttackSpeed: 5→2초)
- ✅ 보상 시스템 (스킬/회복/최대HP 증가)
- ✅ 보상 선택 화면 (RewardScreen)
- ✅ 게임 오버 화면 (GameOverScreen - 통계/재시작)
- ✅ 스테이지 표시 (난이도 이모지 🟢🟡🟠🔴🟣)
- ✅ 무한 스테이지 진행

**파일**:
- [stage_manager.dart](../game/lib/features/stage/stage_manager.dart)
- [reward_screen.dart](../game/lib/screens/reward_screen.dart)
- [game_over_screen.dart](../game/lib/screens/game_over_screen.dart)

---

## 📋 우선순위별 작업 목록

### 우선순위 1: 핵심 게임 루프 완성 ✅
1. ✅ **get_it 버전 업그레이드** (7.6.6 → 9.2.0) - mg_common_game 호환성
2. ✅ **스킬 시스템 구현**
   - ✅ SkillData 모델 생성
   - ✅ 18개 기본 스킬 정의
   - ✅ SkillManager 구현
   - ✅ 스킬 사용 UI (버튼 + 쿨다운 표시)
   - ✅ 마나 시스템 연계 (퍼즐 매치 → 마나 획득 → 스킬 사용)
3. ✅ **시너지 시스템 구현**
   - ✅ SynergyData 모델
   - ✅ 10개 기본 시너지 정의
   - ✅ 시너지 감지 로직
   - ✅ 시너지 효과 적용
   - ✅ UI에 활성 시너지 표시
4. ✅ **로그라이크 진행 시스템**
   - ✅ 스테이지 매니저
   - ✅ 적 처치 후 다음 스테이지
   - ✅ 승리 시 보상 화면 (스킬 선택)
   - ✅ 게임 오버 화면
   - ✅ 재시작 기능

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
| 전투 시스템 (기본) | 100% | ✅ 완료 |
| 이펙트 시스템 | 70% | 🚧 진행 중 |
| 스킬 시스템 | 100% | ✅ 완료 |
| 시너지 시스템 | 100% | ✅ 완료 |
| 로그라이크 진행 | 100% | ✅ 완료 |
| UI/UX | 60% | 🚧 진행 중 |
| 메타 게임 | 0% | ⬜ 미착수 |

**전체 진척도**: 75%

---

## 🐛 알려진 이슈

1. ~~**get_it 버전 충돌**~~: ✅ 해결됨 (9.2.0으로 업그레이드)
2. ~~**퍼즐 매치가 바로 데미지**~~: ✅ 해결됨 (마나 시스템 구현)
3. **적 다양성 부족**: 현재 1종류의 적만 존재 (추후 확장 예정)
4. ~~**게임 오버 처리 미흡**~~: ✅ 해결됨 (GameOverScreen 구현)

---

## 📝 다음 작업

### 현재 상태
- MG-0014의 핵심 게임플레이 완성 (75%)
- 게임은 완전히 플레이 가능한 상태
- 처음부터 게임오버까지 전체 루프 작동

### 추천 다음 작업 (우선순위 2)
1. **다양한 적 타입 추가**
   - 일반 몬스터 (현재 1종 → 3-5종)
   - 엘리트 몬스터 (특수 패턴)
   - 보스 전투 (매 10스테이지마다?)
2. **스킬 확장 및 밸런스**
   - 18개 → 30개 스킬
   - 레어/유니크 스킬 추가
   - 스킬 밸런스 조정
3. **UI/UX 개선**
   - 스킬 북 화면 (보유 스킬 확인)
   - 시너지 도감 (시너지 효과 확인)
   - 튜토리얼 추가
4. **이펙트 개선**
   - 스킬 사용 애니메이션
   - 파티클 효과 강화
   - 화면 흔들림/타격감

---

**작성일**: 2025-12-17
**버전**: 1.0

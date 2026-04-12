# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

workflow-plugin: 네이티브 개발부서의 워크플로우를 구조적으로 조형하는 Claude Code 플러그인.

핵심 원칙:
- Spec = SOT. 소스코드의 단일 진실 공급원.
- 구조적 조형. 워크플로우의 형태를 강제한다.
- 고정 구조, 가변 깊이. 압축은 가능, 스킵은 불가.

## Architecture

Claude Code 플러그인 규격을 따른다:
- `.claude-plugin/plugin.json` — 플러그인 메타���이터
- `skills/feature/SKILL.md` — feature 파이프라인 (메인)
- `skills/debug/SKILL.md` — debug 파이프라인 (가설 기반 디버깅)
- `skills/spec-writing/SKILL.md` — Spec 작성 skill
- `templates/spec-template.md` — Spec 형식 템플릿
- `specs/` — 프로젝트 Spec 파일 저장소
- `debug-logs/` — 디버깅 기록 저장소 (DEBUG-XXX.md)

Spec 형식: 15개 섹션, 계약 기반 4그룹 (정의 → 계약 → 실현 → 보증).
feature 파이프라인: Spec 작성 → 승인 → 계획 → TDD 판단 → 구현 → 검증 → 완료.
debug 파이프라인: 증상 기록 → Spec 확인 → 가설 수립 ⇄ 검증 → 원인 확정 → 수정 → 회귀 테스트 → 완료.

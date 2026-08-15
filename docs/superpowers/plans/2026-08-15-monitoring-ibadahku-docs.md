# Monitoring IbadahKu — Documentation & Legal (Plan D)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Supporting docs: language neutrality guidelines, privacy policy, terms of use, Google Play submission checklist, release notes template.

## Spec

`./PRD.md` §15 §20 §24 §26, Google Play Families Policy.

## Files

- Create `docs/language-guidelines.md`
- Create `docs/privacy-policy.md`
- Create `docs/terms-of-use.md`
- Create `docs/play-store-checklist.md`
- Create `docs/release-notes.md`

## Tasks

### Task 1: Language neutrality guidelines

- [ ] Extract neutral vs. punitive words from `PRD.md` §19.2 into copy-paste table.
- [ ] Example strings for common statuses: "Belum tercatat", "Tercatat sebagai qadha", etc.
- [ ] Review checklist for copywriters.

### Task 2: Privacy policy

- [ ] Data collected by guardian app, child app, backend.
- [ ] Family relationship & consent flow described.
- [ ] Retention: invitations retained 6 months; relationships retained until revoked; audit logs retained 90 days for security.
- [ ] Child data deletion: when child under 13 deletes account, all family data erased within 24h (gated by age gate feature flag — MVP states age not verified).

### Task 3: Terms of use

- [ ] Disclaimer that relationships are user-declared, not legally verified.
- [ ] Guardian responsibilities: use only for own children or with explicit permission.
- [ ] Prohibited: scraping, selling data, minors under 13 without parent consent (gated).

### Task 4: Play Store checklist

- [ ] Families policy declaration: yes (users self-declare family relationship).
- [ ] Data safety form: precise ✓, contacts ✗, location ✗, personal info ✓, financial ✗, health ✗.
- [ ] Target API 34 by Aug 2026.

### Task 5: Release notes template

- [ ] Changelog format with privacy/security highlights visible to users.

## Definition of Done

- [ ] Privacy policy published at `https://monitor-ibadahku.com/privacy`.
- [ ] Docs stored in repo `docs/`.
- [ ] Legal review placeholder noted for production release.

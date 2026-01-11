## Summary

Brief description of what this PR does (2-3 sentences).

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update
- [ ] Refactoring (no functional changes)
- [ ] Performance improvement
- [ ] Dependency update

## Related Issues

Closes #(issue number)
Related to #(issue number)

## Changes Made

Detailed list of changes:
- Change 1
- Change 2
- Change 3

## Technical Details

### Backend Changes (if applicable)
- API endpoints added/modified
- Database schema changes
- New dependencies

### Frontend Changes (if applicable)
- Components added/modified
- UI/UX changes
- New libraries

## Testing

### Unit Tests
- [ ] Added unit tests for new functionality
- [ ] Updated existing tests
- [ ] All unit tests pass (`npm test`)
- [ ] Coverage ≥60% overall, ≥20% per file

### Integration Tests
- [ ] Added integration tests
- [ ] API endpoints tested with supertest
- [ ] Database operations tested

### Manual Testing
- [ ] Tested in development environment
- [ ] Tested on different browsers (if frontend)
- [ ] Tested with different screen sizes (if frontend)
- [ ] Tested error scenarios
- [ ] Tested edge cases

### Test Coverage

```bash
# Paste test coverage summary here
npm test -- --coverage
```

## Security Checklist

- [ ] No hardcoded secrets or API keys
- [ ] Input validation added for new endpoints
- [ ] Authentication checks present
- [ ] Authorization checks present (users can only access own data)
- [ ] No SQL/NoSQL injection vulnerabilities
- [ ] XSS prevention measures in place
- [ ] Dependencies audited (`npm audit`)

## Code Quality Checklist

- [ ] ESLint passes (`npm run lint`)
- [ ] Code formatted (`npm run format`)
- [ ] Type checking passes (if TypeScript)
- [ ] Build succeeds (`npm run build`)
- [ ] JSDoc comments on all new functions
- [ ] No `console.log` or `debugger` statements
- [ ] Follows architecture patterns (routes → controllers → services)
- [ ] Error handling for async operations

## Documentation

- [ ] README updated (if user-facing changes)
- [ ] API documentation updated (if endpoints changed)
- [ ] Code comments explain non-obvious logic
- [ ] `.env.example` updated (if new environment variables)
- [ ] Migration guide included (if breaking changes)

## Database Changes

- [ ] Migration scripts included
- [ ] Rollback procedure documented
- [ ] Tested migration up and down
- [ ] Backwards compatible (or migration path provided)
- [ ] Indexes added for new queries

## Performance Considerations

- [ ] No N+1 query issues
- [ ] Database queries optimized
- [ ] React components memoized where appropriate
- [ ] No unnecessary re-renders
- [ ] Large lists paginated or virtualized

## Accessibility (if frontend changes)

- [ ] Keyboard navigation works
- [ ] Screen reader compatible
- [ ] ARIA labels added where needed
- [ ] Color contrast meets WCAG standards
- [ ] Focus states visible

## Breaking Changes

List any breaking changes and migration instructions:

```
None
```

Or:

```
- API endpoint `/api/users` now requires authentication
- Migration: Update frontend to include auth token in headers
- Backwards compatibility: 2 week deprecation period
```

## Deployment Notes

- [ ] Requires environment variable changes (document in PR)
- [ ] Requires database migration (document order)
- [ ] Requires configuration updates
- [ ] Has rollback procedure documented

### Deployment Steps

1. Run database migration: `npm run migrate`
2. Set new environment variables: `API_KEY=xyz`
3. Deploy application
4. Run smoke tests
5. Monitor for errors

### Rollback Procedure

```bash
# If deployment fails, rollback:
git revert <commit-hash>
npm run migrate:down
# Restore environment variables
```

## Screenshots / Recordings

If UI changes, include:
- Before/After screenshots
- Screen recording of new functionality
- Mobile view screenshots

## Checklist Before Requesting Review

- [ ] Self-review completed
- [ ] Code follows project style guidelines (see `.claude/rules/coding-standards.md`)
- [ ] Changes aligned with `.claude/CLAUDE.md` guidelines
- [ ] Commit messages follow conventional commits format (see `.claude/rules/commit-policy.md`)
- [ ] No merge conflicts
- [ ] CI/CD passing
- [ ] Ready for code review

## Reviewer Guidelines

Reviewers should check:
1. **Code Review Guide**: Follow `.claude/rules/coding-standards.md` → Code Review Guide section
2. **Security**: Verify security checklist above
3. **Testing**: Confirm test coverage and quality
4. **Architecture**: Verify patterns from `.claude/CLAUDE.md`
5. **Documentation**: Ensure docs are updated

### Review Focus Areas

Please pay special attention to:
- [ ] Security implications
- [ ] Performance impact
- [ ] Breaking changes
- [ ] Test coverage
- [ ] Documentation completeness

## Additional Notes

Any other context, screenshots, or information reviewers should know:

-
-
-

---

## Post-Merge Actions

After this PR is merged:
- [ ] Update changelog
- [ ] Notify stakeholders (if needed)
- [ ] Monitor production for 24-48 hours (for critical changes)
- [ ] Create follow-up issues for identified improvements
- [ ] Update project board

---

🤖 Created following guidelines in `.claude/rules/`
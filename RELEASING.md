# Releasing

Releases are run by the `release` agent skill in [`.agents/skills/release`](.agents/skills/release/SKILL.md). In Claude Code, run `/release`. Other agents can be pointed at the skill file.

The skill picks the version from the `Unreleased` changelog entries, bumps it, runs the tests, and commits. It then stops for your approval before pushing and tagging. You run `mix hex.publish` yourself, since it needs your Hex credentials. After you confirm the publish, the skill creates the GitHub release.

## Manual

If you're releasing without the skill, follow these steps:

1. Make sure `main` is clean and up to date, CI is passing, and every user-facing change since the last tag is under `## Unreleased` in `CHANGELOG.md`
2. Pick the version. zonex is pre-1.0, so use a minor bump for breaking changes, new features, dependency swaps, or CLDR data updates, and a patch bump for fixes and performance improvements only
3. Update the `## Unreleased` heading in `CHANGELOG.md` to `## #{@version}`
4. Update the `@version` variable in `mix.exs`
5. Update the version under Installation in `README.md`
6. Run `mix test` and commit as `Version #{@version}`
7. Push `main`, then create and push an annotated tag named `v#{@version}` with the message `Version #{@version}`
8. Run `mix hex.publish`
9. Create a GitHub release for the tag, titled `Version #{@version}`, with that version's `CHANGELOG.md` section as the notes

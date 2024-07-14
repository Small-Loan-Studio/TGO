# The Tūn-Gāst of Oakshaw

Welcome to the TGO repository! This document attempts to hit the high points of
contributing to the codebase and should help you figure out how work through
any confusion that might arise during the devoplment process.

- [The Tūn-Gāst of Oakshaw](#the-tūn-gāst-of-oakshaw)
  - [I'm not on the engineering team, does this matter to me?](#im-not-on-the-engineering-team-does-this-matter-to-me)
  - [People](#people)
    - [Questions?](#questions)
  - [Process](#process)
    - [Conventions: Ownership](#conventions-ownership)
    - [Coventions: Code](#coventions-code)
    - [Conventions: Git](#conventions-git)
      - [`release`](#release)
      - [`tgo_dev`](#tgo_dev)
      - [Code Review](#code-review)
        - [For non-engineering submissions](#for-non-engineering-submissions)
      - [Release Candidate branches / bug fixes](#release-candidate-branches--bug-fixes)
      - [Feature / Personal branches](#feature--personal-branches)
  - [What next?](#what-next)

## I'm not on the engineering team, does this matter to me?
Kind of!

You should definitely understand the golden rules:
1. Don't commit to `release` branch
2. Don't force push to `release` or `tgo_dev`

Otherwise mostly check out [this section](#for-non-engineering-submissions) and chat
with your lead to understand any discipline specific guidance.

If you or your lead have any questions drop by #tgo-programming. We're friendly and
would love to help.

> TODO: Does it make sense to break stuff&mdash;including all the eng-focused
> commentary&mdash;into pillar specific onboarding docs at this point?
 
## People
This is a large project! a full org chart is [available here][orgchart] but some
the relevant leads:
  - Ahria (discord: `katamahri`) &mdash; Engineering (that's us!)
  - Stephen &mdash; Technical Narrative
  - Mario &mdash; Game Design
  - Keumars &mdash; Creative Director
  - Marlo &mdash; Technical Producer

### Questions?
If something is unclear at any point in time feel free to ask around
#tgo-programming or contact a lead to help guide you to the correct person/place
for more info.

## Process
While the whole TGO team is large our engineering team is small and it's likely
we'll each end up owning major parts of the game _and_ working in each other's
domains if we want to make good time.

In order to maintain awareness of what's going on outside our eng focus we:
- have a weekly sync meeting. Notes are kept [here][team-standup]
- track active work on a [kanban board in Notion][kanban]
- communicate regularly in the #tgo-programming channel

### Conventions: Ownership

We hint at this above but it is likely each one of us will end up being the single
biggest voice in the room for a one or more section of the code. Currently it looks
like that will be:

- Den: UI
- Lent: Dialogic integration
- Luke: Level loading / implementation & grayboxing
- Envy: Player interaction mechanics

This list is neither exhaustive nor final. You will always have an opportunity to
change this and it explicitly **does not** mean that you will have to do all the
related work on your own.

It only means you are the person most likely to have a full understanding of the
related systems and when we need more hands on a specific system it may fall to
you to help understand how to decompose the problem or debug a particularly tricky
issue.

As a team we should aim to:
1. Never let somebody own something by accident or implicitly;
2. Not silently abandon something that we own;
3. Understand when something doesn't have an owner.

### Coventions: Code
- GDScript should pass lint before merge. We have the repo set up to run a CI job
  and check validity using `gdlint`. More info can be found about the errors it
  reports and how to set up exclusions on [the wiki][gdlint-wiki]. Pre-commit hooks
  to run locally on merge or a docker file to run locally should be coming "soon"
  but are not in place yet
- GDScript should format tests cleanly before merge. In order to reduce merge issues
  we use an automated tool `gdformat` to ensure our code conforms to a consistent
  formatting spec. Details on this are available on [the wiki][gdformat-wiki].
  Pre-commit / docker jobs to run thees locally should be available "soon" but are
  not in place yet.  
  **_TODO:_ We also do not have this CI job configured yet so this is an optimistic plan**
- We currently require [static typing][static-typing-docs] and non-typed variable
  declarations will be reported as an error. There are several benefits of this
    - Code maintainability &mdash; static typing is a compiler-enforced contract of
      your intent. Its accuracy will never decay and it tells the future reader what
      to expect without requiring them to fully understand function internals;
    - Transferability &mdash; a secret power of staticly typed codebases is the reduced
      cognitive load when trying to modify or contribute to code that you did not
      write. This is highly related to maintainability but is not the same;
    - Reduced reliance on tests &mdash; building with a dynamically typed codebase means
      you can take many more liberties with your functions, how they're used, and how
      they behave. This means that the surface area for bugs / mistakes is larger
      and that the factors you need to consider when making changes is significantly
      higher and (often) not obvious. This can be totally fine but in order to have
      high confidence in behavior it requires an extremely solid test suite. Using
      a statically typed language helps ameliorate the surface area and means we
      can maintain high confidence on function behavior without as aggressive of a test
      suite;
    - Performance &mdash; using statically typed gdscript is between [5 and 150% faster][static-typed-perf]
      than dynamically typed code. And it can get better as VM optimizations are done
      by the Godot team.

### Conventions: Git

At the moment all these are guidelines and will be enforced via honor system.
Locking the repo down would be a lot of headache and require paying to upgrade
to GH enterprise or moving the repo to a personal account which complicates team
management. So let's be honorable and save that effort :heart:.

The most important rule, everything else we can mostly fix after the fact:

**Do not force push changes to `release` or `tgo_dev`.**

#### `release`
Generally we will not be merging into the `release` branch going forward. It is
reserved for near release quality code that has passed basic testing and will
be going through a QA process for approval.

#### `tgo_dev`
Sprint / feature work will be merged into this branch and it's where most active
development will happen. A merge to tgo_dev should:

- first be presented as a PR with a meaningful description that will help reviewers
  understand the changes being made and provide meaningful commentary
- pass any CI tests that have been configured
- once approved the **PR should be squashed** instead of standard merge. This helps keep
  the `tgo_dev` branch clean and orderly

#### Code Review
We understand this is a volunteer project and it may not always be possible for
a PR to receive a full and thorough review in a timely manner. The suggested
process when trying to merge new code to tgo_dev will be:

1. Initiate the PR and do a self-review: re-read the code with an eye for things that
   may be done better, ensure CI passes, and provide a write-up for the changes being
   merged.
2. Post a link to your PR in #tgo-programming and give folks ~48 hours to get a chance
   to read through it and provide feedback.
3. If you haven't seen anybody indicate they've started looking at your review within 48h
   feel free to post a note in channel and squash-merge it into `tgo_dev`.

**Notes / exceptions:**  
- For PRs that need an expedited review tag Ahria or envy in #tgo-programming when you
have a PR ready and we'll try to help make sure we can keep things speedy without
compromising code quality.
- For minor changes (an, admittedly, subjective assessment) include a `[minor]`
indicator in your PR title and feel free to merge without the 48h waiting period
but do go through the PR process & writeup so that we have a full history of what
got merged and why
- For particularly complicated / expansive changes please do not merge without review. If
you need attention on the PR tag Ahria or envy in #tgo-programming.

##### For non-engineering submissions
Most of above process is focused on **GDScript and technical changes** but
at least initially the repository contains work including assets, dialogue,
etc.

Those changes should be considered out of scope for this document and should
follow a process appropriate for that discipline and defined by the corresponding
lead.

#### Release Candidate branches / bug fixes
This is not super well defined but when we merge a release candidate to `release`
any bugs found will be fixed in a RC branch cut off release.

As changes are made in that RC branch they should be back ported to tgo_dev.
RC branches **should not** be merged back into release or subsequent tgo_dev->release
merges will be problematic.

#### Feature / Personal branches

When doing development on a specific feature you should start your branch off the
most recent `tgo_dev` commit. As time passes your branch will fall "behind" the
`tgo_dev` branch off which it was based. As that happens it's suggested you
pull `tgo_dev` and then merge that into your branch. This helps reduce conflict
when it's time for your feature to be submitted to `tgo_dev`.

Generally speaking you should cut a new branch for each new feature and retire that
branch when you have completed the work you were doing. For example if I wanted to
implement a new feature for a level I would:

1. branch off `tgo_dev` and give my branch the name `envy-feature-name`
2. do the work making commits as needed
3. occasionally update my local view of `tgo_dev` and merge that into `envy-feature-name`
4. When I'm done I would create a new PR to merge `envy-feature-name` into `tgo_dev`
5. Once I have completed any PR feedback and gotten an approval to merge I would
   squash-merge that back into tgo_dev
6. I would then delete the branch `envy-feature-name` because it's all been submitted

If I wanted to do a new bit of development I would repeat the process but use a new branch
name that accurately reflects what I'm working on.

There are essentially no rules on what you can do on your own branch.

## What next?

The `./docs` directory has a deep dive on various systems as well as broader
structural decisions.

Start [here](./docs/README.md).

[orgchart]: https://miro.com/app/board/uXjVK-8EE4Y=/
[team-standup]: https://www.notion.so/najmetender/38e72706e6ce4bdeb977e9f4e70bfae0?v=0f1a78091b19463baf1c21d8987063bd&pvs=4
[kanban]: https://www.notion.so/najmetender/ce42775084b1437d94e334a5c46bc3ad?v=57c5260f242e45729fe4ebb09089d645
[gdlint-wiki]: https://github.com/Scony/godot-gdscript-toolkit/wiki/3.%20Linter
[gdformat-wiki]: https://github.com/Scony/godot-gdscript-toolkit/wiki/4.%20Formatter
[static-typing-docs]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html
[static-typed-perf]: https://godotengine.org/article/gdscript-progress-report-typed-instructions/
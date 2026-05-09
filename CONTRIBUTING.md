# Contributing Guidelines

Pull requests, bug reports, and all other forms of contributions to make Jottre even better are welcomed and highly encouraged!

## Installation

Contributions occur on the premise that getting the project working with little effort.  Initially there are a few tools to install that make recurring contributions much simpler.

See [README.md](README.md#development) for installation details.

## Creating an issue

Take a look at the [existing issues](https://github.com/antonlorani/jottre/issues), maybe your concern is already addressed.  If not, use the provided issue templates for [feature requests](https://github.com/antonlorani/jottre/issues/new?template=feature_request.yml) or [bug reports](https://github.com/antonlorani/jottre/issues/new?template=bug_report.yml).

> [!IMPORTANT]
> For security related issues, see [Security Policy](SECURITY_POLICY.md) first!

## Working on an issue

Any form of active contribution requires an associated Github issue. See [Creating an issue](#creating-an-issue).  

Issues that are in the *todo* status and have no assignee yet can be freely taken.  If no contribution occurs for the issue, the issue assignee MAY be reset. 

Do ONLY work on things that are part of the issue's scope. 

Create your working branch by branching from `master`, ensure that the working branch is prefixed with the issue-key.

```
42-zoom-state-not-restored
```

Commit messages SHOULD be suffixed the issue keys as well.

```
Adds zoom scale to scene restoration (#42)
```

Other than making sure that the commit messages communicates the intent clearly, no specific guidelines exist onto how to write a commit message.

Before raising a pull request, run the following command for test verification.

```
bundle exec fastlane test
```

## Finalizing your contribution

### Certificate of origin

BY OPENING A PULL REQUEST, YOU CERTIFY THAT:

1. THE CONTRIBUTION WAS WRITTEN IN WHOLE OR IN PART BY YOU, AND YOU HAVE THE RIGHT TO SUBMIT IT UNDER THE [PROJECT'S LICENSE](LICENSE).
2. THE CONTRIBUTION IS BASED ON PREVIOUS WORK THAT, TO THE BEST OF YOUR KNOWLEDGE, IS COVERED UNDER AN APPROPRIATE OPEN SOURCE LICENSE - AND YOU HAVE THE RIGHT TO SUBMIT IT WITH MODIFICATIONS UNDER THE SAME LICENSE.
3. THE CONTRIBUTION WAS PROVIDED DIRECTLY TO YOU BY SOME OTHER PERSON WHO CERTIFIED (1) OR (2), AND YOU HAVE NOT MODIFIED IT.

### Raise a pull request

Once your work is ready, raise a pull request.  Every pull request undergoes a formal code review.  Code reviews fall under the [Code of Conduct](CODE_OF_CONDUCT.md).

Once your pull request is approved, the owner of this project takes care of merging your contribution into upstream `master` and schedule the changes into the next app store release.

## Policy on coding agents

Contributions via coding agents are accepted and expected.  Your coding agent SHOULD adopt the projects conventions and retain the projects code quality.  It's the operators responsibility to align their coding agent with those.

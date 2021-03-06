# PRepos

## What is this?

A simple command-line Ruby script that outputs a very essential JSON that tells you if your team's PRs are ready for review/merge.

It can be put behind a proxy and cached in order to be consumed by an external service (bot?).

## Ok, but why?

Github *sllooowwllyyyyyy.....* released their Pull Request Reviews API, which are still not exactly "production ready" (as of 22 May 2017).

This made them almost incomplete/unreliable to build any internal tool that could help taking track of the PRs that can be reviewed, approved and merged, in an automated way.

Once, you could have just counted the number of "LGTM" comments on a PR... and that was it.

The Pull Request Reviews functionality is changing the review process (for good!), and we all love it. <3

**Long story short: This script is an attempt at providing you with an "approved" value on the summary of every PR you want to take track of because this functionality is so WOW that we need to use it now!**

## Usage:

`bundle install`, then:

```
Usage: prepos [options]
    -t, --gh-token TOKEN             Set Github token
    -a, --gh-author AUTHOR           Set Github author
    -r COMMA,SEPARATED,REPOS,        Set Github author's repos
        --gh-repos
    -m, --min-approvals INTEGER      Set minimum approvals required (default: 2)
    -s COMMA,SEPARATED,LABELS,       Set labels to skip PRs with (default: 'wip')
        --skip-labels
    -p, --prettify                   Prettify JSON output (console only)
    -h, --help                       Print this help
```

Example:

```
bin/prepos \
  --gh-token TOKEN \
  --gh-owner author \
  --gh-repos repo1,repo2,repo3 \
  --min-approvals 1 \
  --prettify
```

Output:

```json
{
  "pulls": [
    {
      "repo": "author/repo1",
      "number": 1,
      "title": "Test PR",
      "body": "Nothing special.\n",
      "approved": true,
      "mergeable": true
    },
    {
      "repo": "author/repo3",
      "number": 1,
      "title": "Added specs",
      "body": null,
      "approved": false,
      "mergeable": true
    }
  ]
}
```

OR:

```json
{
  "error": "error description"
}
```

Note: you are advised to not use `--prettify` when calling the script for consumption from an external service (it would add unwanted spaces that are not exactly easy to parse from any standard JSON library).

## LICENSE
The MIT License (MIT)

Copyright (c) 2017 Giuseppe Lobraico

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

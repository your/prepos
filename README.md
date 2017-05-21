# PRepos

## What is this?

A simple command-line Ruby script that outputs a very essential JSON that tells you if your team's PRs are ready for review/merge.

It can be put behind a proxy and cached in order to be consumed by an external service (bot?).

## Usage:

`bundle install`, then:

```
Usage: prepos [options]
    -t, --gh-token TOKEN             Set Github token
    -a, --gh-author AUTHOR           Set Github author
    -r COMMA,SEPARATED,REPOS,        Set Github author's repos
        --gh-repos
    -p, --prettify                   Prettify JSON output (console only)
    -h, --help                       Print this help
```

Example:

```
bin/prepos \
  --gh-token TOKEN \
  --gh-owner author \
  --gh-repos repo1,repo2,repo3 \
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
      "approved": false,
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

## Achievement system for Android Academy Global 2020

Achievement system is just a static content, hosted on the [github pages](https://pages.github.com/).
Web site is generated by [Jekyll](https://jekyllrb.com/) based on the data from google sheets.

### Contribution

To contribute open or find an issue.
Discuss with maintainers what you want to do, and then just open PR.

### Building

It's recommended to use [VS Code](https://code.visualstudio.com/),
because [config file is already present](/.vscode/launch.json).
Then follow the [Jekyll's guide](https://jekyllrb.com/docs/) to setup dev environment.

Logic that calculates achievement implemented as a [plugin](https://jekyllrb.com/docs/plugins/generators/),
see achievements directory.
Plugin gets data from [csv files in _data directory](/tree/main/_data).
Before deplayment build machine runs [synchronization script](/sync-docs.sh) before deployment to download student's data from google sheet and save as a scv file.

Building and deployment is based on [github actions](/.github/workflows/jekyll-build.yml).
To see deployment logic see the [script](/deploy.sh).

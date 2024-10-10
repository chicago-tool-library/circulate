# Repo Analysis

This directory holds some scripts used to fetch repository data from Github
and extract it in various forms. It's useful for generating a list of PRs
recently merges, or a list of who has contributed, etc.

Fetching the data requires Python and some Python libraries.

To use:

1. Install the dependencies using `pip3 install -r requirements.in'.
2. Setup a github access token [and configure github-to-sqlite to use it](https://github.com/dogsheep/github-to-sqlite?tab=readme-ov-file#authentication).
3. Run `sync.sh` to fetch the data.
4. Run `datasette github.db` to investigate the data in a nice web-based UI (optional but sometimes handy).
5. Edit/run `rake` to extract the data in a specific format.

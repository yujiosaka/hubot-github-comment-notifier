# hubot-github-comment-notifier

A GitHub pull request and issue comment notifier for hubot

See [`src/hubot-github-pull-request.coffee`](src/github-pull-request.coffee) for full documentation.

## Conventions

`hubot-github-comment-notifier` makes the following assumptions:

- Pull request and issue comments should be notified with mentions when specified
- Pull request and issue comments may be notified in different rooms
- Other GitHub events than pull request and issue comment should be supported in other modules
  - Use [hubot-github-repo-event-notifier](https://github.com/hubot-scripts/hubot-github-repo-event-notifier), for example, if you need support for other events
- Only sends notifications when
  - pull request
    - pull request is (re)opened
    - comment is added to pull request
    - pull request is closed
  - issue (commint soon)

## Installation

In hubot project repo, run:

`npm install hubot-seen --save`

Then add **hubot-github-comment-notifier** to your `external-scripts.json`:

```json
["hubot-github-comment-notifier"]
```

## Configuration

| Variable | Description |
| -------- | ----------- |
| `HUBOT_TEAM_PATH` | *(Optional)* If you want to convert GitHub's `@` mention to another services's (Slack and etc.) mention, you can specify a json file to describe the conversion rule. |

### HUBOT_TEAM_PATH

The json file should looks like this:

```
{
  "@github_mention": "<@slack_mention>"
}
```

See [`_team.json`](_team.json) for its example

### [Webhooks](https://developer.github.com/webhooks/)

#### Pull Request

You need to add HUBOT_URL/hubot/github-pull-request?room=ROOM[&only-mentioned=1]

| Parameter | Description |
| -------- | ----------- |
| `HUBOT_URL` | Your Hubot server's url |
| `ROOM` | To which room you want to send notification |

When `&only-commented=1` is added, it sends notifications only when there are `@` mentions

#### Issue

Comming soon
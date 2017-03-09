# hubot-github-comment-notifier

A GitHub pull request and issue comment notifier for hubot

See following for full documentation.

- [`src/hubot-github-pull-request.coffee`](src/github-pull-request.coffee)
- [`src/hubot-github-issue.coffee`](src/github-issue.coffee)

## Assumptions

`hubot-github-comment-notifier` makes the following assumptions:

- Pull request and issue comments should be notified with assignee and mentions when they are specified
- Pull request and issue comments may be notified in different rooms
- May limit notifications only when there are mentions in comments
  - Currently other conditions like labels and milestones are not supported to limit notifications
  - Your pull requests are welcomed to add more control to the notification limitation
- Other GitHub events than pull request and issue comment should be supported in other modules
  - Use [hubot-github-repo-event-notifier](https://github.com/hubot-scripts/hubot-github-repo-event-notifier), for example, if you need support for other events
- Only sends notifications when
  - pull request
    - pull request is (re)opened
    - comment is added to pull request
    - pull request is closed
  - issue
    - issue is (re)opened
    - comment is added to issue
    - issue is closed

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

You need to add `HUBOT_URL/hubot/github-pull-request?room=ROOM[&only-mentioned=1][&randm-mention=1][&ignore-author=1]` to your repository's webhooks.

| Parameter | Description |
| -------- | ----------- |
| `HUBOT_URL` | Your Hubot server's url |
| `ROOM` | To which room you want to send notification |

- When `&only-mentioned=1` is added, it sends notifications only when there are `@` mentions.
- When `&random-mention=1` is added, it picks-up a user from team.json and send notification.
  - You can specify more than `2` in the value to pick-up more than two users.
- When `&ignore-author=1` is added, it hide user name from notification sentence.

#### Issue

You need to add `HUBOT_URL/hubot/github-issue?room=ROOM[&only-mentioned=1][&ignore-author=1]` to your repository's webhooks.

| Parameter | Description |
| -------- | ----------- |
| `HUBOT_URL` | Your Hubot server's url |
| `ROOM` | To which room you want to send notification |

- When `&only-mentioned=1` is added, it sends notifications only when there are `@` mentions.
- When `&ignore-author=1` is added, it hide user name from notification sentence.

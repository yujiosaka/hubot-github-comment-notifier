# Description:
#   A GitHub pull request comment notifier for hubot
#
# Configuration:
#   HUBOT_TEAM_PATH - (Optional) If you want to convert GitHub's `@` mention to another services's (Slack and etc.) mention, you can specify a json file to describe the conversion rule.
#
#   You need to add `HUBOT_URL/hubot/github-pull-request?room=ROOM[&only-mentioned=1]` to your repository's webhooks.
#     HUBOT_URL: Your Hubot server's url
#     ROOM` To which room you want to send notification
# 
#     When `&only-commented=1` is added, it sends notifications only when there are `@` mentions.
# 
# Author:
#   yujiosaka

url = require 'url'
querystring = require 'querystring'
lib = require '../lib'

PATH = "/hubot/github-pull-request"


module.exports = (robot) ->
  robot.router.post PATH, (req, res) ->
    query = querystring.parse url.parse(req.url).query
    opts =
      only_mentioned: query["only-mentioned"]
      random_mention: +query["random-mention"]
      mention_team: query["mention-team"]
      hidden_user_name: query["hidden-user-name"]
    parts = parseBody req.body
    message = lib.buildMessage parts, opts
    robot.send {room: query.room}, message if message
    res.end ""

parseBody = (data) ->
  parts = null
  # when pull request is opened
  if ['opened', 'reopened'].indexOf(data.action) > -1 and data.pull_request
    parts =
      repository: data.repository.full_name
      action: "Pull request opened"
      number: data.pull_request.number
      title: data.pull_request.title
      user: data.sender.login
      url: data.pull_request.html_url
      mentions: lib.extractMentions data.pull_request.body
      random: true
  # when pull request is closed
  else if data.action is 'closed' and data.pull_request
    parts =
      repository: data.repository.full_name
      action: "Pull request closed"
      number: data.pull_request.number
      title: data.pull_request.title
      user: data.sender.login
      url: data.pull_request.html_url
      mentions: lib.extractMentions data.pull_request.body
  # when review comment is added to pull request
  else if data.action is 'created' and data.pull_request
    parts =
      repository: data.repository.full_name
      action: "New comment on pull request"
      number: data.pull_request.number
      title: data.pull_request.title
      user: data.sender.login
      url: data.comment.html_url
      body: data.comment.body
      mentions: lib.extractMentions data.comment.body
  # comments on issues and those on pull requests are same except the latter has data.issue.pull_request
  else if data.action is 'created' and data.issue?.pull_request
    parts =
      repository: data.repository.full_name
      action: "New comment on pull request"
      number: data.issue.number
      title: data.issue.title
      user: data.sender.login
      url: data.comment.html_url
      body: data.comment.body
      mentions: lib.extractMentions data.comment.body
  parts

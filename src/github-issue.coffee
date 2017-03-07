# Description:
#   A GitHub issue comment notifier for hubot
#
# Configuration:
#   HUBOT_TEAM_PATH - (Optional) If you want to convert GitHub's `@` mention to another services's (Slack and etc.) mention, you can specify a json file to describe the conversion rule.
#
#   You need to add `HUBOT_URL/hubot/github-issue?room=ROOM[&only-mentioned=1]` to your repository's webhooks.
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

PATH = "/hubot/github-issue"


module.exports = (robot) ->
  robot.router.post PATH, (req, res) ->
    query = querystring.parse url.parse(req.url).query
    opts =
      only_mentioned: query["only-mentioned"]
      hidden_user_name: query["hidden-user-name"]
    parts = parseBody req.body
    message = lib.buildMessage parts, opts
    robot.send {room: query.room}, message if message
    res.end ""

parseBody = (data) ->
  parts = null
  # when issue is opened
  if ['opened', 'reopened'].indexOf(data.action) > -1 and data.issue
    parts =
      repository: data.repository.full_name
      action: "Issue opened"
      number: data.issue.number
      title: data.issue.title
      user: data.sender.login
      url: data.issue.html_url
      mentions: lib.extractMentions data.issue.body
  # when issue is closed
  else if data.action is 'closed' and data.issue
    parts =
      repository: data.repository.full_name
      action: "Issue closed"
      number: data.issue.number
      title: data.issue.title
      user: data.sender.login
      url: data.issue.html_url
      mentions: lib.extractMentions data.issue.body
  # comments on issues and those on pull requests are same except the latter has data.issue.pull_request
  else if data.action is 'created' and data.issue and not data.issue.pull_request
    parts =
      repository: data.repository.full_name
      action: "New comment on issue"
      number: data.issue.number
      title: data.issue.title
      user: data.sender.login
      url: data.comment.html_url
      body: data.comment.body
      mentions: lib.extractMentions data.comment.body
  parts

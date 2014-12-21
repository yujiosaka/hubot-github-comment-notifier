# Description:
#   A GitHub pull request comment notifier for hubot
#
# Configuration:
#   HUBOT_TEAM_PATH - (Optional) If you want to convert GitHub's `@` mention to another services's (Slack and etc.) mention, you can specify a json file to describe the conversion rule.
#
#   You need to add HUBOT_URL/hubot/github-pull-request?room=ROOM[&only-mentioned=1]
#     HUBOT_URL: Your Hubot server's url
#     ROOM` To which room you want to send notification
# 
#     When `&only-commented=1` is added, it sends notifications only when there are `@` mentions
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
    message = parseBody req.body, opts
    robot.send {room: query.room}, message if message
    res.end ""

parseBody = (data, opts) ->
  msg = ""
  # when pull request is opened
  if ['opened', 'reopened'].indexOf(data.action) > -1 and data.pull_request
    mentions = lib.extractMentions data.pull_request.body
    unless opts.only_mentioned and not mentions
      msg += "[#{data.repository.full_name}] Pull request opened: ##{data.pull_request.number} #{data.pull_request.title} by #{data.pull_request.user.login}\n"
      msg += "#{data.pull_request.html_url}\n"
      msg += "#{lib.mentionLine(mentions)}\n" if mentions
  # when pull request is closed
  else if data.action is 'closed' and data.pull_request
    mentions = lib.extractMentions data.pull_request.body
    unless opts.only_mentioned and not mentions
      msg += "[#{data.repository.full_name}] Pull request closed: ##{data.pull_request.number} #{data.pull_request.title} by #{data.pull_request.user.login}\n"
      msg += "#{data.pull_request.html_url}\n"
      msg += "#{lib.mentionLine(mentions)}\n" if mentions
  # when review comment is added to pull request
  else if data.action is 'created' and data.pull_request
    mentions = lib.extractMentions data.comment.body
    unless opts.only_mentioned and not mentions
      commit_id = data.comment.commit_id.slice 0, 6
      msg += "[#{data.repository.full_name}] New comment on commit #{commit_id} by #{data.comment.user.login}\n"
      msg += "#{data.comment.html_url}\n"
      msg += "#{data.comment.body}\n"
      msg += "#{lib.mentionLine(mentions)}\n" if mentions
  # comments on issues and those on pull requests are same except the latter has data.issue.pull_request
  else if data.action is 'created' and data.issue?.pull_request
    mentions = lib.extractMentions data.comment.body
    unless opts.only_mentioned and not mentions
      msg += "[#{data.repository.full_name}] New comment on pull request ##{data.issue.number} #{data.issue.title} by #{data.comment.user.login}\n"
      msg += "#{data.issue.html_url}\n"
      msg += "#{data.comment.body}\n"
      msg += "#{lib.mentionLine(mentions)}\n" if mentions
  msg

_ = require 'underscore'
team = try require process.env.HUBOT_TEAM_PATH

exports.extractMentions = (body) ->
  return null unless body
  mentions = body.match /(^|\s)(@[\w\-\/]+)/g
  if mentions
    mentions = _.uniq mentions
    mentions = (mention.trim() for mention in mentions)
  mentions

exports.mentionLine = (mentions) ->
  mentions = convertMentions mentions
  "Mentions: #{mentions.join(", ")}"

convertMentions = (github_mentions) ->
  return github_mentions unless team
  mentions = []
  for github_mention in github_mentions
    if team[github_mention]
      mention = team[github_mention]
    else
      mention = github_mention
      for name, converter of team
        if _.isObject(converter) and converter[github_mention]
          mention = converter[github_mention]
    mentions.push mention
  mentions
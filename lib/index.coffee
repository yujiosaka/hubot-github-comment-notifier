_ = require 'underscore'
team = try require process.env.HUBOT_TEAM_PATH

exports.extractMentions = (body) ->
  mentions = []
  match = body.match /(^|\s)(@[\w\-\/]+)/g
  if match
    mentions = _.uniq match
    mentions = (mention.trim() for mention in mentions)
  mentions

exports.buildMessage = (parts, opts) ->
  return null unless parts
  return null if opts.only_mentioned and not parts.mentions.length
  mentions = convert parts.mentions
  random_mentions = random mentions, opts.random_mention, opts.mention_team
  msg = ""
  msg += "[#{parts.repository}] #{parts.action}: ##{parts.number} #{parts.title} by #{parts.user}\n"
  msg += "#{parts.url}\n"
  msg += "#{parts.body}\n" if parts.body
  msg += "Mentions: #{mentions.join(", ")}\n" if mentions.length
  msg += "Congratulations! You are assigned: #{random_mentions.join(", ")}\n" if parts.random and random_mentions.length
  msg

convert = (github_mentions) ->
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

random = (mentions, random_mention, mention_team) ->
  return [] unless team and random_mention
  num = random_mention - mentions.length
  return [] unless num
  sample = team[mention_team] or team
  _.chain(sample).values().difference(mentions).sample(num).value()

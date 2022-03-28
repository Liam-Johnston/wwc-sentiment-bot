const logger = require('../utils/logger')
const slack = require('../repositories/slack')


exports.analyseMessage = async ({text, channel, ts}) => {
  logger.info("New message in channel", {
    text,
    channel,
    ts
  })

  await slack.replyToMessage("hello :)", channel, ts)
}

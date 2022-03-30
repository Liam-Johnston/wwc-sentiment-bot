const logger = require('../utils/logger')
const tools = require('../utils/tools')
const slack = require('../repositories/slack')
const language = require('../repositories/language')
const eventLease = require('../repositories/eventLease')

exports.analyseMessage = async ({text}) => {
  logger.info("New message in channel", {
    text
  })

  return "Success"
}

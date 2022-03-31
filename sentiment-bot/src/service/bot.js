const logger = require('../utils/logger')
const tools = require('../utils/tools')
const slack = require('../repositories/slack')
const language = require('../repositories/language')
const eventLease = require('../repositories/eventLease')

const simulateFunctionTimeout = async () => {
  await tools.wait(process.env.LEASE_DURATION * 1000)
}

exports.analyseMessage = async ({text, channel, ts, eventID}) => {
  logger.info("New message in channel", {
    text
  })

  const lease = await eventLease.createLease(eventID)

  if (lease === null) return "Already Processed"

  // Uncomment the line below this if you would like to simulate a function timeout and observe
  // what happens to the lease
  // if (Math.random() > 0.5) await simulateFunctionTimeout()

  const sentiment = await language.getSentiment(text)

  await slack.replyToMessage(`Sentiment analysed \nscore: ${sentiment.score}\nmagnitude:${sentiment.magnitude}`, channel, ts)

  await eventLease.markEventHandled(lease)

  return "Success"
}

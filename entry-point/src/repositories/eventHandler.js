const pubSub = require('./adaptors/pubsub')
const logger = require('../utils/logger')

const isPrimitive = (ref) => ref !== Object(ref)


const getEventAttributes = (event, slackEventId) => {
  const attributes = {
    slackEventId
  }
  for (const [key, value] of Object.entries(event)) {
    if (isPrimitive(value)) attributes[key] = value.toString()
  }
  return attributes
}


exports.publish = async (event, eventId) => {
  logger.info('Received event from slack, publishing to event stream')

  const attributes = getEventAttributes(event, eventId)

  const result = await pubSub.publishEvent(
    JSON.stringify(event),
    attributes
  )

  logger.info('Published message', {
    result
  })

  return result
}

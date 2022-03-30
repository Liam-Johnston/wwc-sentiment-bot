const pubSub = require('./adaptors/pubsub')
const logger = require('../utils/logger')

const isPrimitive = (ref) => ref !== Object(ref)


const getEventAttributes = (event, slackEventID) => {
  const attributes = {
    slackEventID
  }
  for (const [key, value] of Object.entries(event)) {
    if (isPrimitive(value)) attributes[key] = value.toString()
  }
  return attributes
}


exports.publish = async (event, eventID) => {
  logger.info('Received event from slack, publishing to event stream')

  const attributes = getEventAttributes(event, eventID)

  event.eventID = eventID

  const result = await pubSub.publishEvent(
    JSON.stringify(event),
    attributes
  )

  logger.info('Published message', {
    result
  })

  return result
}

const pubSub = require('./adaptors/pubsub')
const logger = require('../utils/logger')

const isPrimitive = (ref) => ref !== Object(ref)


const getMessageAttributes = (event, slackEventId) => {
  const attributes = {
    slackEventId
  }
  for (const [key, value] of Object.entries(event)) {
    if (isPrimitive(value)) attributes[key] = value
  }
}


exports.publish = async (event, eventId) => {
  const topic = event.type

  logger.info('received message from slack to put message on a topic', {
    topic
  })

  const attributes = getMessageAttributes(event, eventId)

  const result = await pubSub.publishMessage(
    topic,
    JSON.stringify(event),
    attributes
  )

  logger.info('Published message', {
    result
  })

  return result
}

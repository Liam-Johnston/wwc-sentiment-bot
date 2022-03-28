const {PubSub} = require('@google-cloud/pubsub')

const getClient = (projectId) => {
  if (projectId !== undefined) return new PubSub({projectId})

  return new PubSub()
}

const pubSubClient = getClient(process.env.GCP_PROJECT_ID)

exports.publishEvent = async (data, attributes) => {
  const dataBuffer = Buffer.from(data)

  return await pubSubClient
    .topic(process.env.SLACK_EVENT_TOPIC)
    .publish(dataBuffer, attributes)
}

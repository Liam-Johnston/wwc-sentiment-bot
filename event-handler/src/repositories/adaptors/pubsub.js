const {PubSub} = require('@google-cloud/pubsub')

const getClient = (projectId) => {
  if (projectId !== undefined) return new PubSub({projectId})

  return new PubSub()
}

const pubSubClient = getClient(process.env.GCP_PROJECT_ID)


const createTopic = async (topic) => {
  const [topics] = await pubSubClient.getTopics()

  if (topics.find(t => t.name === `projects/${process.env.GCP_PROJECT_ID}/topics/${topic}`) === undefined) {
    await pubSubClient.createTopic(topic)
  }
}

exports.publishMessage = async (topic, data, attributes) => {
  if (process.env.NODE_ENV === 'development') await createTopic(topic)

  const dataBuffer = Buffer.from(data)

  return await pubSubClient
    .topic(`slack-event-${topic}`)
    .publish(dataBuffer, attributes)
}

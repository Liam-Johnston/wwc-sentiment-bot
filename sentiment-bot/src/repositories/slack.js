const {WebClient} = require('@slack/web-api')

const client = new WebClient(process.env.SLACK_OAUTH_TOKEN)

exports.replyToMessage = async (text, channel, thread_ts) => {
  return await client.chat.postMessage({
    channel,
    text,
    thread_ts
  })
}

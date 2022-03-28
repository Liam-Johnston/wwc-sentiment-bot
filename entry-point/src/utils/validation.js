const { createHmac } = require('crypto')
const timingSafeCompare = require('tsscmp')

const logger = require('./logger')

const slackSigningSecret = process.env.SLACK_SIGNING_SECRET

exports.isValidSlackRequest = (timestamp, signature, stringifiedBody) => {
  // Slack sends timestamp in seconds not milliseconds
  const current = Date.now() / 1000

  // // 5 minutes * 60 seconds
  if ((current - timestamp) > ( 5 * 60)) {
    logger.error(
      'The timestamp on the request is older than 5 minutes',
      {
        current,
        timestamp
      }
    )
    return false
  }

  const sigBaseString = `v0:${timestamp}:${stringifiedBody}`

  const digest = 'v0=' + createHmac('sha256', slackSigningSecret)
                          .update(sigBaseString)
                          .digest('hex')

  if (!timingSafeCompare(digest, signature)) {
    logger.error(
      'Failed to validate that the request originated from Slack',
      {
        digest,
        signature
      }
    )
    return false
  }

  return true
}

const errors = require('../exceptions/error-definitions')
const logger = require('./logger')


exports.getSafeTimestamp = (headers) => {
  const timestamp = parseInt(headers['x-slack-request-timestamp'])
  const d = new Date(timestamp * 1000)

  if (d.getTime() > 0) return timestamp

  logger.error('Invalid Timestamp', {
    timestamp
  })

  throw new errors.InvalidRequestParameters('Invalid timestamp format')
}

exports.getSafeSignature = (headers) => {
  const signature = headers['x-slack-signature']

  if (/^v0=[A-Fa-f0-9]{64}$/.test(signature)) return signature

  logger.error('Invalid signature', {
    signature
  })

  throw new errors.InvalidRequestParameters('Invalid signature format')
}

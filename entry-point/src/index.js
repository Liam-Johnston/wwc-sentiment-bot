const validation = require('./utils/validation')
const logger = require('./utils/logger')
const eventHandler = require('./repositories/eventHandler')
const sanitation = require('./utils/sanitation')
const errors = require('./exceptions/error-definitions')


const resolveURLVerification = ({challenge}) => {
  logger.info('Request to verify URL')

  return {
    challenge
  }
}

const resolveEventCallBack = async (body) => {
  return await eventHandler.publish(body.event, body.event_id.toString())
}

const attachDefaultLoggingAttributes = (body) => {
  logger.setLoggingAttribute('slackEventId', body.event_id)
  logger.setLoggingAttribute('eventType', body.type)
}

const main = async (req, res) => {
  const {headers, body, rawBody} = req
  attachDefaultLoggingAttributes(body)

  logger.info(
    'Received slack request',
    {
      body,
      headers
    }
  )

  const isValidSlackRequest = validation.isValidSlackRequest(
    sanitation.getSafeTimestamp(headers),
    sanitation.getSafeSignature(headers),
    sanitation.getSafeRawBody(rawBody)
  )

  if (!isValidSlackRequest) {
    throw new errors.VerificationError('Invalid Request')
  }

  if (body.type === "url_verification") {
    return {
      response: resolveURLVerification(body),
      status: 200
    }
  }

  return {
    response: await resolveEventCallBack(body),
    status: 202
  }
}

exports.entryPoint = async (req, res) => {
  await main(req, res)
    .then( ({response, status}) => {
      res
        .status(status)
        .send(response)
    })
    .catch(e => {
      logger.error(
        'Internal Server Error',
        {
        stack: e.stack,
        errorMessage: e.message
        }
      )
      res
        .status(e.status || 500)
        .send(e.name || 'Internal Server Error')
    })
}

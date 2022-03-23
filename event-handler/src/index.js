const validation = require('./utils/validation')
const logger = require('./utils/logger')
const eventHandler = require('./repositories/eventHandler')
const sanitation = require('./utils/sanitation')


const resolveURLVerification = ({challenge}) => {
  logger.info('Request to verify URL')

  return {
    challenge
  }
}

const resolveEventCallBack = async (body) => {
  return await eventHandler.publish(body.event, body.event_id)
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
    rawBody.toString()
  )

  if (!isValidSlackRequest) {
    res
      .status(403)
      .send('Invalid Request')
    return
  }

  let response = {}
  let status = 404

  if (body.type === "url_verification") {
    response = resolveURLVerification(body)
    status = 200
  }

  if (body.type === "event_callback") {
    response = await resolveEventCallBack(body)
    status = 202
  }

  res
    .status(status)
    .send(response);
}

exports.entryPoint = async (req, res) => {
  await main(req, res).
    catch(e => {
      logger.error(
        'Internal Server Error',
        {
        stack: e.stack,
        errorMessage: e.message
        }
      )
      res
        .status(500)
        .send('Internal Server Error')
    })
}

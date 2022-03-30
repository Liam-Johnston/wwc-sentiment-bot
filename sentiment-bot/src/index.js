const bot = require('./service/bot')
const logger = require('./utils/logger')


const main = async (req) => {
  const body = JSON.parse(Buffer.from(req.body.message.data, 'base64').toString('utf-8'))

  logger.setLoggingAttribute('slackEventId', body.eventID)

  logger.info("Request Received", {
    body
  })

  const response = await bot.analyseMessage(body)
  const status = 200

  return {
    response,
    status
  }
}

exports.entryPoint = async (req, res) => {
  await main(req)
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

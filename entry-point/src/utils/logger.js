var defaultLoggingAttributes = {}

exports.setLoggingAttribute = (attribute, value) => {
  defaultLoggingAttributes[attribute] = value
}

const log = (lvl, message, attributes) => {
  if (process.env.NODE_ENV === 'development') {
    console[lvl]({
      severity: lvl,
      message,
      ...attributes
    })
    return
  }

  console[lvl](
    JSON.stringify({
      message,
      ...attributes,
      severity: lvl.toUpperCase(),
      'timestamp': new Date(),
      ...defaultLoggingAttributes
    })
  )
}

exports.error = (message, attributes) => log('error', message, attributes)
exports.info = (message, attributes) => log('info', message, attributes)
exports.warn = (message, attributes) => log('warn', message, attributes)

exports.VerificationError = class extends Error {
  constructor(message) {
    super(message)
    this.name = 'Unauthorized'
    this.message = message
    this.status = 401
  }
}

exports.InvalidRequestParameters = class extends Error {
  constructor(message) {
    super(message)
    this.name = 'InvalidRequestParameters'
    this.message = message
    this.status = 400
  }
}

const {Firestore} = require('@google-cloud/firestore');
const logger = require('../utils/logger')


const firestore = new Firestore();

const leaseCollection = process.env.LEASE_FIRESTORE_COLLECTION
const leaseDuration = parseInt(process.env.LEASE_DURATION) * 1000


const alreadyHandled = async (lease) => {
  return await firestore.runTransaction(async transaction => {
    const leaseDoc = await transaction.get(lease)

    if (leaseDoc.exists) {
      logger.info("Lease exists", leaseDoc.data())
    }

    if (leaseDoc.exists && Date.now() < leaseDoc.data().leaseExpiration) throw Error('Lease already taken')

    if (leaseDoc.exists && leaseDoc.data().handled){
      logger.info("Event already handled")
      return true
    }

    const leaseExpiration = Date.now() + leaseDuration
    transaction.set(
      lease,
      {
        leaseExpiration
      }
    )
    logger.info("Event not yet hanlded", {
      leaseExpiration,
      currentTime: Date.now()
    })
    return false
  })
}

exports.createLease = async (slackEventID) => {
  const lease = firestore.collection(leaseCollection).doc(slackEventID)

  if (await alreadyHandled(lease)) return null

  return lease
}

exports.markEventHandled = async (lease) => {
  return await lease.set({handled: true})
}

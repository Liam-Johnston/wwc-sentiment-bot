exports.wait = async (duration) => {
  return await new Promise(resolve => setTimeout(resolve, duration))
}

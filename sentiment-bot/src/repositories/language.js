const language = require('@google-cloud/language');

const client = new language.LanguageServiceClient();

exports.getSentiment = async (content) => {
  return {
    score: 1,
    magnitude: 1
  }


  const document = {
    content,
    type: 'PLAIN_TEXT'
  }


  const [result] = await client.analyzeSentiment({document})

  return result.documentSentiment
}

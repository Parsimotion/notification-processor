

module.exports = ({ context: { bindingData : { insertionTime } }, message }) ->
  message: message
  meta: { insertionTime }

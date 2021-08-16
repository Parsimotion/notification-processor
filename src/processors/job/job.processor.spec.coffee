NonRetryable = require("../../exceptions/non.retryable")

NOTIFICATIONS_URL = "http://unhost/notifications/api"
API_URL = "http://unhost/api"
JOB_ID = 1

process.env.MAX_DEQUEUE_COUNT = 5

_ = require "lodash"
nock = require "nock"
should = require "should"
JobProcessor = require "./index"

mockFailedNotificationWith = (badStatusCode) ->
  errorMessage = "it's a trap!"
  bodyExpected =
    statusCode: badStatusCode
    message: errorMessage
    success: no

  _nockAPI badStatusCode, errorMessage
  _notificationsApiNock bodyExpected


_notificationsApiNock = (bodyExpected) ->
  nock NOTIFICATIONS_URL
    .post "/jobs/#{JOB_ID}/operations", (body) -> _.omit(body, "request").should.be.eql bodyExpected
    .reply 200

_notificationsApiGetJob = (response) ->
  nock NOTIFICATIONS_URL
    .get "/jobs/#{JOB_ID}"
    .reply 200, response or { stopped: false }

describe "JobProcessor", ->

  afterEach ->
    nock.cleanAll()

  context "when API response with bad status code", ->
    it "and dequeue counter is lower than MAX_DEQUEUE_COUNT, should throw an exception", ->
      _nockAPI(500, "something went wrong!")
      _notificationsApiGetJob()
      _processJob().should.be.rejected()

    it "and dequeue counter is greater than MAX_DEQUEUE_COUNT, should notify for fail to notificationsApi", ->
      _notificationsApiGetJob()
      mockFailedNotificationWith 500
      _processJob { dequeueCount: 6 }
      .tap -> nock.isDone().should.be.ok()
      .should.be.rejectedWith NonRetryable

    it "equal to 400 then is success but should notify for fail to notificationsApi", ->
      _notificationsApiGetJob()
      mockFailedNotificationWith 400

      _processJob()
      .tap -> nock.isDone().should.be.ok()
      .should.be.rejectedWith NonRetryable

  context "when API response with good status code", ->
    it "and dequeue counter is lower than MAX_DEQUEUE_COUNT, should notify for success to notificationsApi", ->
      _nockAPI()
      _notificationsApiGetJob()

      _notificationsApiNock = nock NOTIFICATIONS_URL
      .post "/jobs/#{JOB_ID}/operations"
      .reply 200

      _processJob()
      .tap -> _notificationsApiNock.done()

message =
  "Method":"POST"
  "Resource":"/products/sync"
  "Body":"{\"notes\":\"<font color=\\\"orange\\\"><b>SKU: 02-1966</b></font><br><br>Lector de Códigos de Barras conexión PS2<br><br><div><strong>Lector de Códigos de Barras SYMBOL LS5004i PS2<br><div style=\\\"text-align: justify\\\"><br></div></strong></div><div style=\\\"text-align: justify\\\">Incorpora un láser de 650 nm que proporciona una línea de escaneo brillante que garantiza apuntar fácilmente incluso en condiciones de luz ambiental.</div><div style=\\\"text-align: justify\\\">Reducción de la fatiga del dedo, incluso durante períodos prolongados de uso, que se consigue con un gatillo patentado de dos dedos.&nbsp;</div><div style=\\\"text-align: justify\\\">Diseño ergonómico.</div><div style=\\\"text-align: justify\\\">Gatillo de dos dedos.</div><div style=\\\"text-align: justify\\\">Construcción resistente</div><div style=\\\"text-align: justify\\\">Láser de 650nm.</div><div style=\\\"text-align: justify\\\">Tasa de lectura: 100 lecturas por segundo (aprox).</div><div style=\\\"text-align: justify\\\">Ideal para &nbsp;aplicaciones UPC WAN/JAN.</div><div style=\\\"text-align: justify\\\">Conectividad PS2.</div><div style=\\\"text-align: justify\\\">RECERTIFICADO</div><div><br><strong>Garantía: 6 Meses.</strong></div>\",\"category\":\"Control de acceso, Código de Barras y POS\",\"name\":\"Lector de Códigos de Barras SYMBOL LS5004i PS2 Ref.\",\"sku\":\"02-1966\",\"dimensions\":{\"pieces\":null},\"stocks\":[{\"warehouse\":\"Default\",\"quantity\":2}],\"prices\":[{\"priceList\":\"Default\",\"amount\":35.38,\"currency\":\"Usd\"}],\"pictures\":[{\"url\":\"http://okcomputers.com.uy/imgs/productos/productos7_4880.jpg?7128\"},{\"url\":\"http://okcomputers.com.uy/imgs/productos/productos7_4881.jpg?3880\"}],\"buyingPrice\":14.5}","HasQueueName":true,"IsJob":false,"QueueName":"syncer-api","JobId":"#{JOB_ID}","Token":"Bearer fd64c7defcda5c8eba49a683fea4069c4e56bdee"
  "HeadersForRequest": [
    {"Key":"Accept","Value":"application/json","IsJob":false,"IsValidForRequest":true,"IsAuthorization":false}
    {"Key":"Authorization","Value":"Bearer fd64c7defcda5c8eba49a683fea4069c4e56bdee","IsJob":false,"IsValidForRequest":true,"IsAuthorization":true}
    {"Key":"Max-Forwards","Value":"10","IsJob":false,"IsValidForRequest":true,"IsAuthorization":false}
    {"Key":"createifitdoesntexist","Value":"true","IsJob":false,"IsValidForRequest":true,"IsAuthorization":false}
    {"Key":"queue","Value":"syncer-api","IsJob":false,"IsValidForRequest":true,"IsAuthorization":false}
    {"Key":"Content-Length","Value":"1661","IsJob":false,"IsValidForRequest":true,"IsAuthorization":false}
    {"Key":"Content-Type","Value":"application/json","IsJob":false,"IsValidForRequest":true,"IsAuthorization":false}
  ]

_createJobNotification = (meta) -> { message, meta }

_processJob = (meta = { dequeueCount: 1 }) ->
  processor = JobProcessor { apiUrl: API_URL, notificationApiUrl: NOTIFICATIONS_URL }
  processor _createJobNotification meta

_nockAPI = (statusCode = 200, errorMessage = "") ->
  nock API_URL
  .post "/products/sync"
  .reply statusCode, { message: errorMessage }
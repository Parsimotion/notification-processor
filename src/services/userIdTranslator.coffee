_ = require("lodash")
Promise = require("bluebird")
axios = require("axios")
retry = require("bluebird-retry")
NodeCache = require("node-cache")
translatedCache = new NodeCache { stdTTL: 0, checkperiod: 0 }
MERCADOLIBRE_API_CORE_URL = process.env.MERCADOLIBRE_API_CORE_URL or "https://apps.producteca.com/mercadolibre-api"
MERCADOLIBRE_API_MASTER_TOKEN = process.env.MERCADOLIBRE_API_MASTER_TOKEN

module.exports = class UserIdTranslator
    constructor: () ->
        @translatedCache = translatedCache
        @translate = @translate.bind(this)

    translate: (userId) =>
        return Promise.resolve(null) if not MERCADOLIBRE_API_MASTER_TOKEN
        @getCompanyId(userId)

    getCompanyId: (userId) =>
        companyId = @translatedCache.get(userId)
        if companyId then Promise.resolve(companyId) else @_translateUserId(userId)

    _setInCache: (userId, userInfo) =>
        success = @translatedCache.set(userId, userInfo)
        if success
            console.log("UserId %s ===> %s was stored in cache successfully", userId, JSON.stringify(userInfo))
        Promise.resolve(success)

    _translateUserId: (userId) =>
        console.log("Making request to translate", userId)
        retry((() => @_fetchUser(userId)), { max_tries: 3, throw_original: true, predicate: (err) => err.response?.status != 401 })
        .then (userInformation) => { app: userInformation.app, companyId: userInformation.tenantId or userInformation.companyId }
        .tap ({ companyId }) => console.log("UserId translated %s ==> %s", userId, companyId)
        .catch (reason) =>
            return "Unknown" if _.includes([ 401, 500 ], reason.response?.status)
            throw reason
        .tap (companyId) => @_setInCache(userId, companyId)

    _fetchUser: (userId) =>
        axios.get("#{MERCADOLIBRE_API_CORE_URL}/users/me", {
            params: { authenticationType: "mercadolibre" }
            auth: {
                username: "#{userId}"
                password: MERCADOLIBRE_API_MASTER_TOKEN
            }
        }).then (response) -> response.data

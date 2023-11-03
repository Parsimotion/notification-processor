_ = require("lodash")
Promise = require("bluebird")
request = require("request-promise")
errors = require("request-promise/errors")
retry = require("bluebird-retry")
NodeCache = require("node-cache")
translatedCache = new NodeCache { stdTTL: 0, checkperiod: 0 }

module.exports = class UserIdTranslater
    constructor: (@appsToTranslate) ->
        @translatedCache = translatedCache
        @translate = @translate.bind(this)

    translate: (userId, app) =>
        if _.includes(@appsToTranslate, app) then @getCompanyId(userId) else Promise.resolve(userId)

    getCompanyId: (userId) =>
        companyId = @translatedCache.get(userId)
        if companyId then Promise.resolve(companyId) else @_translateUserId(userId)

    _setInCache: (userId, CompanyId) =>
        success = @translatedCache.set(userId, CompanyId)
        if success
            console.log("UserId %s ===> %s was stored in cache successfully", userId, CompanyId)
        Promise.resolve(success)

    _translateUserId: (userId) =>
        console.log("Making request to translate", userId)
        retry () => request.get({
            url: "#{meliApi.url}/users/me",
            json: true,
            qs: { authenticationType: "mercadolibre" },
            auth: {
                user: "#{userId}",
                password: meliApi.masterToken
            }
        })
        .promise()
        .then (userInformation) => userInformation.tenantId || userInformation.companyId
        .tap (companyId) => console.log("UserId translated %s ==> %s", userId, companyId)
        .then (companyId) => companyId.toString()
        .catch (reason) =>
            return "Unknown" if _.includes([ 401, 500 ], reason.statusCode)
            throw reason
        .tap (companyId) => @_setInCache(userId, companyId)

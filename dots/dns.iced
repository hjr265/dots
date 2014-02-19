_ = require 'underscore'
dns = require 'native-dns'


SERVERS = process.env.NAMESERVERS.split ','


exports.lookup = (type, addr, done) ->
  req = new dns.Request
    question: new dns.Question
      type: type
      name: addr
    server: _.sample SERVERS
    timeout: 5000

  timedout = no
  errored = no

  req.on 'timeout', ->
    timedout = yes
    req.cancel()
    done dns.TIMEOUT

  req.on 'end', ->
    if errored or timedout
      return

    done null, records

  # accumulate records
  records = []
  req.on 'message', (err, message) ->
    if err
      errored = yes
      req.cancel()
      done err
      return

    for record in message.answer
      delete record['name']
      delete record['type']
      delete record['class']
      records.push record

  req.send()